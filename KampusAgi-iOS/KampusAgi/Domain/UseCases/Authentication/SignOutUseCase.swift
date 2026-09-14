protocol SignOutUseCase: Sendable {
    func callAsFunction() async throws
}

struct DefaultSignOutUseCase: SignOutUseCase {
    let repository: AuthenticationRepository

    func callAsFunction() async throws {
        try await repository.signOut()
    }
}
