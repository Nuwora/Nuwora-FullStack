import Foundation

struct RegisterRequest: Codable, Equatable {
    let email: String
    let password: String
}

struct LoginRequest: Codable, Equatable {
    let email: String
    let password: String
}

protocol CredentialAuthenticating {
    /// Creates a new email/password account. Returns `isNewUser` (always `true` on success).
    func register(email: String, password: String) async throws -> Bool
    /// Validates credentials against an existing account. Returns `isNewUser` (always `false` on success).
    func login(email: String, password: String) async throws -> Bool
    /// Clears the current session (however it was established — guest, login, or register).
    func logout() async
}

/// Talks to `POST auth/register` / `POST auth/login`, then hands the resulting
/// access token to the same `AnonymousAuthSession` instance the rest of the
/// app already authenticates through, so it's picked up transparently by
/// every subsequent authenticated request.
final class HTTPCredentialAuthClient: CredentialAuthenticating {
    private let client: APIClient
    private let authSession: AnonymousAuthSession

    init(client: APIClient, authSession: AnonymousAuthSession) {
        self.client = client
        self.authSession = authSession
    }

    func register(email: String, password: String) async throws -> Bool {
        let request = RegisterRequest(email: email, password: password)
        let response = try await client.send(
            AnonymousAuthResponse.self,
            method: .post,
            path: "auth/register",
            body: AnyEncodable(request),
            requiresAuthentication: false
        )
        try await authSession.setAccessToken(response.accessToken)
        return response.user.isNewUser
    }

    func login(email: String, password: String) async throws -> Bool {
        let request = LoginRequest(email: email, password: password)
        let response = try await client.send(
            AnonymousAuthResponse.self,
            method: .post,
            path: "auth/login",
            body: AnyEncodable(request),
            requiresAuthentication: false
        )
        try await authSession.setAccessToken(response.accessToken)
        return response.user.isNewUser
    }

    func logout() async {
        await authSession.invalidate()
    }
}

final class MockCredentialAuthClient: CredentialAuthenticating {
    func register(email: String, password: String) async throws -> Bool { true }
    func login(email: String, password: String) async throws -> Bool { false }
    func logout() async {}
}
