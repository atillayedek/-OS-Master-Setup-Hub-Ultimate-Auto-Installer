import Foundation

/// Sourced from the backend (§17) — never a hardcoded list baked into the UI.
struct University: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let name: String
    let officialName: String?
    let domain: String
    let city: String
    let type: UniversityType
}
