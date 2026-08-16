import Foundation
import Security

enum SecureTokenStoreError: Error {
    case unhandledStatus(OSStatus)
    case invalidData
}

final class KeychainAccessTokenStore {
    private let service: String
    private let account: String

    init(
        service: String = "rs.nuwora.Nuwora-Mobile",
        account: String = "api-access-token"
    ) {
        self.service = service
        self.account = account
    }

    func load() throws -> String? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess else {
            throw SecureTokenStoreError.unhandledStatus(status)
        }
        guard let data = result as? Data,
              let token = String(data: data, encoding: .utf8)
        else {
            throw SecureTokenStoreError.invalidData
        }
        return token
    }

    func save(_ token: String) throws {
        try? remove()
        var query = baseQuery
        query[kSecValueData as String] = Data(token.utf8)
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw SecureTokenStoreError.unhandledStatus(status)
        }
    }

    func remove() throws {
        let status = SecItemDelete(baseQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecureTokenStoreError.unhandledStatus(status)
        }
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}

struct AnonymousAuthRequest: Codable, Equatable {
    let deviceID: UUID
}

struct AnonymousAuthResponse: Codable, Equatable {
    struct AuthenticatedUser: Codable, Equatable {
        let id: UUID
        let isNewUser: Bool
    }

    let accessToken: String
    let user: AuthenticatedUser
}

final class AnonymousAuthSession {
    private let configuration: APIConfiguration
    private let urlSession: URLSession
    private let tokenStore: KeychainAccessTokenStore
    private let userDefaults: UserDefaults
    private let deviceIDKey = "nuwora.auth.device-id"
    private var cachedToken: String?
    private var didLoadStoredToken = false

    init(
        configuration: APIConfiguration,
        urlSession: URLSession = .shared,
        tokenStore: KeychainAccessTokenStore = KeychainAccessTokenStore(),
        userDefaults: UserDefaults = .standard
    ) {
        self.configuration = configuration
        self.urlSession = urlSession
        self.tokenStore = tokenStore
        self.userDefaults = userDefaults
    }

    func accessToken() async throws -> String {
        if didLoadStoredToken == false {
            cachedToken = try tokenStore.load()
            didLoadStoredToken = true
        }
        if let cachedToken, cachedToken.isEmpty == false {
            return cachedToken
        }
        do {
            let token = try await authenticate()
            cachedToken = token
            try tokenStore.save(token)
            return token
        } catch {
            throw error
        }
    }

    func invalidate() async {
        cachedToken = nil
        didLoadStoredToken = true
        try? tokenStore.remove()
    }

    /// Adopts a token obtained from a different auth path (e.g. email/password
    /// login or registration), persisting it the same way an anonymous token
    /// would be. Subsequent `accessToken()` calls return this token without
    /// re-triggering anonymous authentication.
    func setAccessToken(_ token: String) async throws {
        cachedToken = token
        didLoadStoredToken = true
        try tokenStore.save(token)
    }

    private func authenticate() async throws -> String {
        let url = configuration.baseURL.appendingPathComponent("auth/anonymous")
        var request = URLRequest(url: url, timeoutInterval: configuration.requestTimeout)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try APICoding.makeEncoder().encode(AnonymousAuthRequest(deviceID: deviceID))

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            throw AppError(code: .network, message: "Could not connect to the Nuwora API.", retryHint: "Start the local backend and try again.")
        }

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode)
        else {
            throw AppError(code: .accessDenied, message: "Could not start an anonymous session.")
        }

        do {
            let response = try APICoding.makeDecoder().decode(AnonymousAuthResponse.self, from: data)
            guard response.accessToken.isEmpty == false else {
                throw AppError(code: .invalidResponse, message: "The API returned an empty access token.")
            }
            return response.accessToken
        } catch let appError as AppError {
            throw appError
        } catch {
            throw AppError(code: .invalidResponse, message: "The anonymous authentication response is invalid.")
        }
    }

    private var deviceID: UUID {
        if let stored = userDefaults.string(forKey: deviceIDKey),
           let id = UUID(uuidString: stored) {
            return id
        }
        let id = UUID()
        userDefaults.set(id.uuidString, forKey: deviceIDKey)
        return id
    }
}
