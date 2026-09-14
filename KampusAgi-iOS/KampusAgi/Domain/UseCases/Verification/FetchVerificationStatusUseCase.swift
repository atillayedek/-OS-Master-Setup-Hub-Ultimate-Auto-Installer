protocol FetchVerificationStatusUseCase: Sendable {
    func callAsFunction() async throws -> VerificationStatus
}

struct DefaultFetchVerificationStatusUseCase: FetchVerificationStatusUseCase {
    let repository: StudentVerificationRepository

    func callAsFunction() async throws -> VerificationStatus {
        try await repository.fetchStatus()
    }
}
