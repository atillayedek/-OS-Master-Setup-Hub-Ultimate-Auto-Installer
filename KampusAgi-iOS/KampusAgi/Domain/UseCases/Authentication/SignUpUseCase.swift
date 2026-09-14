protocol SignUpUseCase: Sendable {
    func callAsFunction(email: String, password: String, fullName: String) async throws -> User
}

struct DefaultSignUpUseCase: SignUpUseCase {
    let repository: AuthenticationRepository

    func callAsFunction(email: String, password: String, fullName: String) async throws -> User {
        try await repository.signUp(email: email, password: password, fullName: fullName)
    }
}
