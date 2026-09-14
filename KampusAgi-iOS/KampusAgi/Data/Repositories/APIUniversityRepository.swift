final class APIUniversityRepository: UniversityRepository {
    private let apiClient: APIClient
    private let cache: UniversityCacheStore

    init(apiClient: APIClient, cache: UniversityCacheStore) {
        self.apiClient = apiClient
        self.cache = cache
    }

    func searchUniversities(query: String) async throws -> [University] {
        do {
            let endpoint = VerificationAPIEndpoints.searchUniversities(query: query)
            let response = try await apiClient.send(endpoint, as: UniversityListResponseDTO.self)
            let universities = response.universities.map { $0.toDomain() }
            if query.trimmed.isEmpty {
                try? await cache.replaceAll(with: universities)
            }
            return universities
        } catch {
            AppLogger.network.error("University search failed, falling back to cache")
            let cached = try await cache.fetchAll(matching: query)
            guard !cached.isEmpty else { throw error }
            return cached
        }
    }
}
