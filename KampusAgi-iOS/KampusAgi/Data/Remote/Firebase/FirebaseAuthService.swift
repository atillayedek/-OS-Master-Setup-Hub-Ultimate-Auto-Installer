import FirebaseAuth
import Foundation

/// Thin wrapper over the FirebaseAuth SDK. Isolating the SDK calls here keeps
/// `FirebaseAuthenticationRepository` (and everything above it) free of
/// direct `Auth.auth()` calls scattered around, and gives us one seam to
/// mock in tests without linking FirebaseAuth into the test target.
final class FirebaseAuthService: Sendable {
    private var auth: Auth { Auth.auth() }

    func signIn(email: String, password: String) async throws -> FirebaseAuth.User {
        try await auth.signIn(withEmail: email, password: password).user
    }

    func createUser(email: String, password: String) async throws -> FirebaseAuth.User {
        try await auth.createUser(withEmail: email, password: password).user
    }

    func signIn(with credential: AuthCredential) async throws -> FirebaseAuth.User {
        try await auth.signIn(with: credential).user
    }

    func sendPasswordReset(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }

    func signOut() throws {
        try auth.signOut()
    }

    var currentUser: FirebaseAuth.User? {
        auth.currentUser
    }

    func idToken(forceRefresh: Bool = false) async throws -> String {
        guard let user = auth.currentUser else { throw APIError.unauthorized }
        return try await user.idToken(forcingRefresh: forceRefresh)
    }

    /// Bridges Firebase's callback-based listener to AsyncStream so the rest
    /// of the app can observe auth state with `for await`.
    func authStateStream() -> AsyncStream<FirebaseAuth.User?> {
        AsyncStream { continuation in
            let handle = auth.addStateDidChangeListener { _, user in
                continuation.yield(user)
            }
            continuation.onTermination = { _ in
                Auth.auth().removeStateDidChangeListener(handle)
            }
        }
    }
}
