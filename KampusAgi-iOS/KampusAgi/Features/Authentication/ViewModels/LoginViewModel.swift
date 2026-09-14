import Foundation
import Observation

@Observable
@MainActor
final class LoginViewModel {
    var email = ""
    var password = ""
    var isLoading = false
    var errorMessage: String?

    private let signIn: SignInUseCase
    private let signInWithApple: SignInWithAppleUseCase
    private let signInWithGoogle: SignInWithGoogleUseCase
    private let onSignedIn: (User) -> Void

    init(
        signIn: SignInUseCase,
        signInWithApple: SignInWithAppleUseCase,
        signInWithGoogle: SignInWithGoogleUseCase,
        onSignedIn: @escaping (User) -> Void
    ) {
        self.signIn = signIn
        self.signInWithApple = signInWithApple
        self.signInWithGoogle = signInWithGoogle
        self.onSignedIn = onSignedIn
    }

    var canSubmit: Bool {
        email.isValidEmail && !password.isEmpty && !isLoading
    }

    func submit() async {
        guard email.isValidEmail else {
            errorMessage = "Geçerli bir e-posta adresi girin."
            return
        }
        guard !password.isEmpty else {
            errorMessage = "Şifrenizi girin."
            return
        }

        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let user = try await signIn(email: email.trimmed, password: password)
            onSignedIn(user)
        } catch {
            errorMessage = AuthErrorPresenter.message(for: error)
        }
    }

    func continueWithApple() async {
        await performSocialSignIn { try await self.signInWithApple() }
    }

    func continueWithGoogle() async {
        await performSocialSignIn { try await self.signInWithGoogle() }
    }

    private func performSocialSignIn(_ action: @escaping () async throws -> User) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let user = try await action()
            onSignedIn(user)
        } catch {
            errorMessage = AuthErrorPresenter.message(for: error)
        }
    }
}
