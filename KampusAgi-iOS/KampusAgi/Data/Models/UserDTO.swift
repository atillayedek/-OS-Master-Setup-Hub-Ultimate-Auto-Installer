import Foundation

/// Wire shape returned by POST /v1/auth/sync — see docs/BACKEND_API_CONTRACT.md.
struct UserDTO: Decodable {
    let id: String
    let email: String
    let fullName: String
    let accountStatus: AccountStatus
    let universityId: UUID?
    let department: String?
    let rejectionReason: String?

    func toDomain() -> User {
        User(
            id: id,
            email: email,
            fullName: fullName,
            accountStatus: accountStatus,
            universityId: universityId,
            department: department,
            rejectionReason: rejectionReason
        )
    }
}
