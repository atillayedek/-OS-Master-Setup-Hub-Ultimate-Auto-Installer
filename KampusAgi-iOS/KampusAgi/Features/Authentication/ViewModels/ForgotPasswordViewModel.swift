import Observation

@Observable
@MainActor
final class ForgotPasswordViewModel {
    var email = ""
    var isLoading = false
    var errorMessage: String?
    var didSendReset = false

    private let resetPassword: ResetPasswordUseCase

    init(resetPassword: ResetPasswordUseCase) {
        self.resetPassword = resetPassword
    }

    var canSubmit: Bool { email.isValidEmail && !isLoading }

    func submit() async {
        guard email.isValidEmail else {
            errorMessage = "Geçerli bir e-posta adresi girin."
            return
        }

        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            try await resetPassword(email: email.trimmed)
            didSendReset = true
        } catch {
            errorMessage = AuthErrorPresenter.message(for: error)
        }
    }
}
