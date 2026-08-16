import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

struct EmptyResponse: Codable, Equatable {
    init() {}
}

struct AnyEncodable: Encodable {
    private let encodeValue: (Encoder) throws -> Void

    init<Value: Encodable>(_ value: Value) {
        encodeValue = value.encode(to:)
    }

    func encode(to encoder: Encoder) throws {
        try encodeValue(encoder)
    }
}

enum APICoding {
    static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(ISO8601DateFormatter.apiFormatter.string(from: date))
        }
        return encoder
    }

    static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            guard let date = ISO8601DateFormatter.apiFormatter.date(from: rawValue)
                ?? ISO8601DateFormatter.apiFormatterWithoutFractions.date(from: rawValue)
            else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Expected an RFC3339/ISO-8601 UTC date."
                )
            }
            return date
        }
        return decoder
    }
}

private extension ISO8601DateFormatter {
    static let apiFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    static let apiFormatterWithoutFractions: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}

private struct BackendErrorEnvelope: Decodable {
    struct BackendError: Decodable {
        let code: String
        let message: String
        let requestID: String?
    }

    let error: BackendError
}

private enum APIClientFailure: Error {
    case unauthorized
}

final class APIClient {
    private let configuration: APIConfiguration
    private let urlSession: URLSession
    private let authSession: AnonymousAuthSession

    init(
        configuration: APIConfiguration,
        authSession: AnonymousAuthSession,
        urlSession: URLSession = .shared
    ) {
        self.configuration = configuration
        self.authSession = authSession
        self.urlSession = urlSession
    }

    func send<Response: Decodable>(
        _ responseType: Response.Type,
        method: HTTPMethod = .get,
        path: String,
        queryItems: [URLQueryItem] = [],
        body: AnyEncodable? = nil,
        requiresAuthentication: Bool = true
    ) async throws -> Response {
        do {
            return try await perform(
                responseType,
                method: method,
                path: path,
                queryItems: queryItems,
                body: body,
                requiresAuthentication: requiresAuthentication
            )
        } catch APIClientFailure.unauthorized where requiresAuthentication {
            await authSession.invalidate()
            do {
                return try await perform(
                    responseType,
                    method: method,
                    path: path,
                    queryItems: queryItems,
                    body: body,
                    requiresAuthentication: true
                )
            } catch APIClientFailure.unauthorized {
                throw AppError.accessDenied(message: "Your session has expired.", retryHint: "Restart the app and try again.")
            }
        }
    }

    private func perform<Response: Decodable>(
        _ responseType: Response.Type,
        method: HTTPMethod,
        path: String,
        queryItems: [URLQueryItem],
        body: AnyEncodable?,
        requiresAuthentication: Bool
    ) async throws -> Response {
        let request = try await makeRequest(
            method: method,
            path: path,
            queryItems: queryItems,
            body: body,
            requiresAuthentication: requiresAuthentication
        )

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            throw AppError(
                code: .network,
                message: "Could not connect to the Nuwora API.",
                retryHint: "Check that the backend is running at \(configuration.baseURL.absoluteString)."
            )
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError(code: .invalidResponse, message: "The API returned an invalid response.")
        }

        if httpResponse.statusCode == 401 {
            // For calls that don't carry a session token (e.g. login), a 401 means
            // "wrong credentials", not "session expired" — surface the backend's
            // message directly instead of triggering the anonymous-reauth retry.
            guard requiresAuthentication else {
                throw AppError.accessDenied(message: backendMessage(from: data) ?? "Invalid email or password.")
            }
            throw APIClientFailure.unauthorized
        }
        if httpResponse.statusCode == 403 {
            throw AppError.accessDenied(message: backendMessage(from: data) ?? "You do not have permission for this action.")
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw AppError(
                code: .invalidResponse,
                message: backendMessage(from: data) ?? "The API request failed with status \(httpResponse.statusCode).",
                retryHint: "Please retry. If the problem continues, check the backend logs."
            )
        }

        if data.isEmpty, responseType == EmptyResponse.self,
           let empty = EmptyResponse() as? Response {
            return empty
        }

        do {
            return try APICoding.makeDecoder().decode(responseType, from: data)
        } catch {
            throw AppError(
                code: .invalidResponse,
                message: "The API response does not match the mobile contract.",
                retryHint: "Validate the response against docs/backend_api_contract.md."
            )
        }
    }

    private func makeRequest(
        method: HTTPMethod,
        path: String,
        queryItems: [URLQueryItem],
        body: AnyEncodable?,
        requiresAuthentication: Bool
    ) async throws -> URLRequest {
        let cleanPath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let endpointURL = configuration.baseURL.appendingPathComponent(cleanPath)
        guard var components = URLComponents(url: endpointURL, resolvingAgainstBaseURL: false) else {
            throw AppError(code: .invalidResponse, message: "The API endpoint URL is invalid.")
        }
        if queryItems.isEmpty == false {
            components.queryItems = queryItems
        }
        guard let url = components.url else {
            throw AppError(code: .invalidResponse, message: "The API endpoint URL is invalid.")
        }

        var request = URLRequest(url: url, timeoutInterval: configuration.requestTimeout)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(UUID().uuidString, forHTTPHeaderField: "X-Request-ID")
        if let body {
            request.httpBody = try APICoding.makeEncoder().encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if requiresAuthentication {
            let token = try await authSession.accessToken()
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    private func backendMessage(from data: Data) -> String? {
        try? APICoding.makeDecoder().decode(BackendErrorEnvelope.self, from: data).error.message
    }
}
