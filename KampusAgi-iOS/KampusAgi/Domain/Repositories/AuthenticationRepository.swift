/// Protocol-based per §3 — ViewModels depend on this, never on FirebaseAuth
/// directly, so authentication can be unit-tested with a mock and swapped
/// without touching Features/Authentication.
protocol AuthenticationRepository: Sendable {
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String, fullName: String) async throws -> User
    func signInWithApple() async throws -> User
    func signInWithGoogle() async throws -> User
    func resetPassword(email: String) async throws
    func signOut() async throws
    func currentUser() async -> User?

    /// Emits the current user whenever Firebase's auth state changes
    /// (sign-in, sign-out, token refresh), so the app can restore a session
    /// on launch and react to sign-out from any screen.
    func observeAuthState() -> AsyncStream<User?>
}
