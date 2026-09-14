protocol SignInWithGoogleUseCase: Sendable {
    func callAsFunction() async throws -> User
}

struct DefaultSignInWithGoogleUseCase: SignInWithGoogleUseCase {
    let repository: AuthenticationRepository

    func callAsFunction() async throws -> User {
        try await repository.signInWithGoogle()
    }
}
