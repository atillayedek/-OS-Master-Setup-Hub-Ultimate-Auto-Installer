protocol UniversityRepository: Sendable {
    /// Empty query returns the full backend-sourced list (§17) — the client
    /// never hardcodes universities.
    func searchUniversities(query: String) async throws -> [University]
}
