/// Supplies the bearer token attached to authenticated backend requests.
/// Implemented in Data/Remote/Firebase by wrapping the current Firebase user's
/// ID token — Core/Domain never import FirebaseAuth directly.
protocol AuthTokenProviding: Sendable {
    func currentIDToken() async throws -> String
}
