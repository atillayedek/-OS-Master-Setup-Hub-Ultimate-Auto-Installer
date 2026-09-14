import SwiftUI

struct PasswordStepView: View {
    @Bindable var viewModel: RegisterViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Bir şifre oluşturun")
                .font(.kaTitle)
            AuthSecureField(title: "Şifre", text: $viewModel.password)
            AuthSecureField(title: "Şifre Tekrar", text: $viewModel.confirmPassword)
            if viewModel.passwordMismatch {
                Text("Şifreler eşleşmiyor.")
                    .font(.kaCaption)
                    .foregroundStyle(.red)
            }
        }
    }
}
