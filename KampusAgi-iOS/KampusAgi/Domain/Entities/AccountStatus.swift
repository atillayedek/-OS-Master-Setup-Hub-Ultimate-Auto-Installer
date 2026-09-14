/// Backend-authoritative account lifecycle — the client never flips this
/// itself, it only reflects what the backend returns (§10, §11).
enum AccountStatus: String, Codable, Sendable {
    case pendingDocument = "PENDING_DOCUMENT"
    case pendingReview = "PENDING_REVIEW"
    case approved = "APPROVED"
    case rejected = "REJECTED"
    case suspended = "SUSPENDED"
    case deleted = "DELETED"

    /// Whether the app's main features (communities, matchmaking, chat) should
    /// be reachable. Everything else routes to a verification-status screen.
    var grantsFullAccess: Bool {
        self == .approved
    }
}
