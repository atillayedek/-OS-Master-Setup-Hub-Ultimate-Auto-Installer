import Foundation

struct User: Identifiable, Codable, Hashable, Sendable {
    let id: String // Firebase UID
    let email: String
    let fullName: String
    let accountStatus: AccountStatus
    let universityId: UUID?
    let department: String?
    let rejectionReason: String?
}
