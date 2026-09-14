/// Body for POST /v1/auth/sync. `fullName` is only persisted by the backend
/// the first time a given Firebase UID is seen — the sync call is idempotent
/// per §14, so calling it again on every app launch never creates a
/// duplicate profile or overwrites data the user has since changed elsewhere.
struct AuthSyncRequestDTO: Encodable {
    let fullName: String?
}
