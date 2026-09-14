import FirebaseAuth
import Foundation

/// Implements `AuthenticationRepository` on top of Firebase Auth for
/// credential management plus the app's own backend for profile data
/// (`AccountStatus`, university, department) — Firebase never stores those,
/// they live in the backend's Postgres database (§14, §52).
final class FirebaseAuthenticationRepository: AuthenticationRepository {
    private let authService: FirebaseAuthService
    private let apiClient: APIClient
    private let appleSignInCoordinator: AppleSignInCoordinator
    private let googleSignInCoordinator: GoogleSignInCoordinator

    init(
        authService: FirebaseAuthService,
        apiClient: APIClient,
        appleSignInCoordinator: AppleSignInCoordinator,
        googleSignInCoordinator: GoogleSignInCoordinator
    ) {
        self.authService = authService
        self.apiClient = apiClient
        self.appleSignInCoordinator = appleSignInCoordinator
        self.googleSignInCoordinator = googleSignInCoordinator
    }

    func signIn(email: String, password: String) async throws -> User {
        _ = try await authService.signIn(email: email, password: password)
        return try await syncProfile(fullName: nil)
    }

    func signUp(email: String, password: String, fullName: String) async throws -> User {
        _ = try await authService.createUser(email: email, password: password)
        return try await syncProfile(fullName: fullName)
    }

    func signInWithApple() async throws -> User {
        let credential = try await appleSignInCoordinator.requestSignIn()
        _ = try await authService.signIn(with: credential)
        return try await syncProfile(fullName: nil)
    }

    func signInWithGoogle() async throws -> User {
        let credential = try await googleSignInCoordinator.requestSignIn()
        _ = try await authService.signIn(with: credential)
        return try await syncProfile(fullName: nil)
    }

    func resetPassword(email: String) async throws {
        try await authService.sendPasswordReset(email: email)
    }

    func signOut() async throws {
        try authService.signOut()
    }

    func currentUser() async -> User? {
        guard authService.currentUser != nil else { return nil }
        return try? await syncProfile(fullName: nil)
    }

    func observeAuthState() -> AsyncStream<User?> {
        let firebaseStream = authService.authStateStream()
        return AsyncStream { continuation in
            Task {
                for await firebaseUser in firebaseStream {
                    guard firebaseUser != nil else {
                        continuation.yield(nil)
                        continue
                    }
                    let user = try? await self.syncProfile(fullName: nil)
                    continuation.yield(user)
                }
                continuation.finish()
            }
        }
    }

    /// Idempotent — safe to call on every sign-in and every app launch
    /// without creating duplicate backend profiles (§14).
    private func syncProfile(fullName: String?) async throws -> User {
        let endpoint = try AuthAPIEndpoints.sync(fullName: fullName)
        let dto = try await apiClient.send(endpoint, as: UserDTO.self)
        return dto.toDomain()
    }
}
