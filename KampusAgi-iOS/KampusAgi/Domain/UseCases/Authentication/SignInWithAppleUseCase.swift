protocol SignInWithAppleUseCase: Sendable {
    func callAsFunction() async throws -> User
}

struct DefaultSignInWithAppleUseCase: SignInWithAppleUseCase {
    let repository: AuthenticationRepository

    func callAsFunction() async throws -> User {
        try await repository.signInWithApple()
    }
}
