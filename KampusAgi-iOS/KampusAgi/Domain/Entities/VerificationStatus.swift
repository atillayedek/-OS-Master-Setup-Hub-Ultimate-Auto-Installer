struct VerificationStatus: Codable, Hashable, Sendable {
    let accountStatus: AccountStatus
    let rejectionReason: String?
}
