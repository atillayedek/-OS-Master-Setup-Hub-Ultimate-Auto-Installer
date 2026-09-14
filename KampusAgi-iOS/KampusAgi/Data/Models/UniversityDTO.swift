import Foundation

/// Wire shape for GET /v1/universities — see docs/BACKEND_API_CONTRACT.md.
struct UniversityDTO: Decodable {
    let id: UUID
    let name: String
    let officialName: String?
    let domain: String
    let city: String
    let type: UniversityType

    func toDomain() -> University {
        University(id: id, name: name, officialName: officialName, domain: domain, city: city, type: type)
    }
}

struct UniversityListResponseDTO: Decodable {
    let universities: [UniversityDTO]
}
