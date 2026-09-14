import Foundation
import SwiftData

@ModelActor
actor UniversityCacheStore {
    func replaceAll(with universities: [University]) throws {
        try modelContext.delete(model: CachedUniversity.self)
        for university in universities {
            modelContext.insert(CachedUniversity(university))
        }
        try modelContext.save()
    }

    func fetchAll(matching query: String) throws -> [University] {
        let descriptor = FetchDescriptor<CachedUniversity>(sortBy: [SortDescriptor(\.name)])
        let cached = try modelContext.fetch(descriptor)
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered = trimmed.isEmpty
            ? cached
            : cached.filter { $0.name.localizedCaseInsensitiveContains(trimmed) }
        return filtered.compactMap { $0.toDomain() }
    }
}
