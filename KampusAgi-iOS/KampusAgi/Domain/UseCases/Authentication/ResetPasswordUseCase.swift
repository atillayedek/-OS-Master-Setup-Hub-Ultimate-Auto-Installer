protocol ResetPasswordUseCase: Sendable {
    func callAsFunction(email: String) async throws
}

struct DefaultResetPasswordUseCase: ResetPasswordUseCase {
    let repository: AuthenticationRepository

    func callAsFunction(email: String) async throws {
        try await repository.resetPassword(email: email)
    }
}
