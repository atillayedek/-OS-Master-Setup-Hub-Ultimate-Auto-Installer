import SwiftUI

struct LoginView: View {
    @State private var viewModel: LoginViewModel
    let onForgotPassword: () -> Void

    init(container: AppDependencyContainer, onSignedIn: @escaping (User) -> Void, onForgotPassword: @escaping () -> Void) {
        _viewModel = State(initialValue: container.makeLoginViewModel(onSignedIn: onSignedIn))
        self.onForgotPassword = onForgotPassword
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                VStack(spacing: Spacing.md) {
                    AuthTextField(
                        title: "E-posta",
                        text: $viewModel.email,
                        keyboardType: .emailAddress,
                        textContentType: .username,
                        autocapitalization: .never
                    )
                    AuthSecureField(title: "Şifre", text: $viewModel.password)

                    Button("Şifremi unuttum", action: onForgotPassword)
                        .font(.kaCaption)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }

                if let errorMessage = viewModel.errorMessage {
                    ErrorBanner(message: errorMessage)
                }

                Button {
                    Task { await viewModel.submit() }
                } label: {
                    Text("Giriş Yap")
                }
                .buttonStyle(.kaPrimary(isLoading: viewModel.isLoading, isDisabled: !viewModel.canSubmit))
                .disabled(!viewModel.canSubmit)

                Divider()

                SocialSignInButtons(
                    onAppleTap: { Task { await viewModel.continueWithApple() } },
                    onGoogleTap: { Task { await viewModel.continueWithGoogle() } }
                )
            }
            .padding(Spacing.lg)
        }
        .navigationTitle("Giriş Yap")
        .navigationBarTitleDisplayMode(.inline)
        .loadingOverlay(viewModel.isLoading)
    }
}
