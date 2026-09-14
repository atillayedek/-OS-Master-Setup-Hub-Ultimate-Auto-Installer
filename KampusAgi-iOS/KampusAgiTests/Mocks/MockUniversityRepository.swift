@testable import KampusAgi

final class MockUniversityRepository: UniversityRepository, @unchecked Sendable {
    var result: Result<[University], Error> = .success([])
    var lastQuery: String?

    func searchUniversities(query: String) async throws -> [University] {
        lastQuery = query
        return try result.get()
    }
}
