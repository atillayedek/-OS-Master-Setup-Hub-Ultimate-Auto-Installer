import SwiftUI

struct EmailStepView: View {
    @Bindable var viewModel: RegisterViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("E-posta adresiniz nedir?")
                .font(.kaTitle)
            AuthTextField(
                title: "E-posta",
                text: $viewModel.email,
                keyboardType: .emailAddress,
                textContentType: .email,
                autocapitalization: .never
            )
        }
    }
}
