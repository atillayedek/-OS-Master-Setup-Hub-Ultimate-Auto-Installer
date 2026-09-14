protocol ObserveCurrentUserUseCase: Sendable {
    func callAsFunction() -> AsyncStream<User?>
}

struct DefaultObserveCurrentUserUseCase: ObserveCurrentUserUseCase {
    let repository: AuthenticationRepository

    func callAsFunction() -> AsyncStream<User?> {
        repository.observeAuthState()
    }
}
