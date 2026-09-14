final class FirebaseIDTokenProvider: AuthTokenProviding {
    private let authService: FirebaseAuthService

    init(authService: FirebaseAuthService) {
        self.authService = authService
    }

    func currentIDToken() async throws -> String {
        try await authService.idToken()
    }
}
