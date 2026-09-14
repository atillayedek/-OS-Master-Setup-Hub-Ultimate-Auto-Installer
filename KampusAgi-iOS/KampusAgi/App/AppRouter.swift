import Observation
import SwiftUI

/// Top-level session state: restores a session on launch (§4, "Session
/// Restore") and reacts to sign-in/sign-out from anywhere in the app via
/// `ObserveCurrentUserUseCase`'s Firebase-backed stream.
@Observable
@MainActor
final class AppRouter {
    private(set) var currentUser: User?
    private(set) var isRestoringSession = true

    private let container: AppDependencyContainer
    private let observeCurrentUser: ObserveCurrentUserUseCase
    private let signOutUseCase: SignOutUseCase

    init(container: AppDependencyContainer) {
        self.container = container
        self.observeCurrentUser = container.makeObserveCurrentUserUseCase()
        self.signOutUseCase = container.makeSignOutUseCase()
    }

    func start() async {
        currentUser = await container.currentUser()
        isRestoringSession = false

        for await user in observeCurrentUser() {
            currentUser = user
        }
    }

    func handleAuthenticated(_ user: User) {
        currentUser = user
    }

    func handleStatusChanged(_ user: User) {
        currentUser = user
    }

    func signOut() async {
        try? await signOutUseCase()
        currentUser = nil
    }
}

struct RootView: View {
    @State private var router: AppRouter
    private let container: AppDependencyContainer

    init(container: AppDependencyContainer) {
        self.container = container
        _router = State(initialValue: AppRouter(container: container))
    }

    var body: some View {
        Group {
            if router.isRestoringSession {
                SplashView()
            } else if let user = router.currentUser {
                RootGateView(
                    container: container,
                    user: user,
                    onSignedOut: { Task { await router.signOut() } },
                    onStatusChanged: { router.handleStatusChanged($0) }
                )
            } else {
                WelcomeView(container: container, onAuthenticated: { router.handleAuthenticated($0) })
            }
        }
        .task {
            await router.start()
        }
    }
}

private struct SplashView: View {
    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.brandPrimary)
            ProgressView()
        }
    }
}
