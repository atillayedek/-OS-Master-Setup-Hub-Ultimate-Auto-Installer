import SwiftUI

struct ForgotPasswordView: View {
    @State private var viewModel: ForgotPasswordViewModel

    init(container: AppDependencyContainer) {
        _viewModel = State(initialValue: container.makeForgotPasswordViewModel())
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            if viewModel.didSendReset {
                VStack(spacing: Spacing.sm) {
                    Image(systemName: "envelope.badge.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.brandPrimary)
                    Text("Sıfırlama bağlantısı gönderildi")
                        .font(.kaHeadline)
                    Text("\(viewModel.email) adresine bir şifre sıfırlama e-postası gönderdik.")
                        .font(.kaSubheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            } else {
                Text("Şifrenizi mi unuttunuz?")
                    .font(.kaTitle)
                AuthTextField(
                    title: "E-posta",
                    text: $viewModel.email,
                    keyboardType: .emailAddress,
                    textContentType: .username,
                    autocapitalization: .never
                )

                if let errorMessage = viewModel.errorMessage {
                    ErrorBanner(message: errorMessage)
                }

                Button {
                    Task { await viewModel.submit() }
                } label: {
                    Text("Sıfırlama Bağlantısı Gönder")
                }
                .buttonStyle(.kaPrimary(isLoading: viewModel.isLoading, isDisabled: !viewModel.canSubmit))
                .disabled(!viewModel.canSubmit)
            }
        }
        .padding(Spacing.lg)
        .navigationTitle("Şifre Sıfırla")
        .navigationBarTitleDisplayMode(.inline)
    }
}
