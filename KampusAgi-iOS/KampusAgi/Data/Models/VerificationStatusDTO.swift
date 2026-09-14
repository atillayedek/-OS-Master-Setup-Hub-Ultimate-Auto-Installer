/// Wire shape for the verification apply/resubmit/status endpoints — see
/// docs/BACKEND_API_CONTRACT.md.
struct VerificationStatusDTO: Decodable {
    let accountStatus: AccountStatus
    let rejectionReason: String?

    func toDomain() -> VerificationStatus {
        VerificationStatus(accountStatus: accountStatus, rejectionReason: rejectionReason)
    }
}
