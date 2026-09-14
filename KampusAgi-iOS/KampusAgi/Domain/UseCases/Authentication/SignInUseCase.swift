protocol SignInUseCase: Sendable {
    func callAsFunction(email: String, password: String) async throws -> User
}

struct DefaultSignInUseCase: SignInUseCase {
    let repository: AuthenticationRepository

    func callAsFunction(email: String, password: String) async throws -> User {
        try await repository.signIn(email: email, password: password)
    }
}
