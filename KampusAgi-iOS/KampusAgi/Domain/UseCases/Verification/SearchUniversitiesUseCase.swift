protocol SearchUniversitiesUseCase: Sendable {
    func callAsFunction(query: String) async throws -> [University]
}

struct DefaultSearchUniversitiesUseCase: SearchUniversitiesUseCase {
    let repository: UniversityRepository

    func callAsFunction(query: String) async throws -> [University] {
        try await repository.searchUniversities(query: query)
    }
}
