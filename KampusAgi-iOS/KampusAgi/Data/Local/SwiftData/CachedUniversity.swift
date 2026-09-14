import Foundation
import SwiftData

/// Offline cache for the university list (§33) so the picker still works
/// with previously-seen results when the network request fails.
@Model
final class CachedUniversity {
    @Attribute(.unique) var id: UUID
    var name: String
    var officialName: String?
    var domain: String
    var city: String
    var type: String
    var cachedAt: Date

    init(id: UUID, name: String, officialName: String?, domain: String, city: String, type: String, cachedAt: Date = .now) {
        self.id = id
        self.name = name
        self.officialName = officialName
        self.domain = domain
        self.city = city
        self.type = type
        self.cachedAt = cachedAt
    }
}

extension CachedUniversity {
    convenience init(_ university: University) {
        self.init(
            id: university.id,
            name: university.name,
            officialName: university.officialName,
            domain: university.domain,
            city: university.city,
            type: university.type.rawValue
        )
    }

    func toDomain() -> University? {
        guard let type = UniversityType(rawValue: type) else { return nil }
        return University(id: id, name: name, officialName: officialName, domain: domain, city: city, type: type)
    }
}
