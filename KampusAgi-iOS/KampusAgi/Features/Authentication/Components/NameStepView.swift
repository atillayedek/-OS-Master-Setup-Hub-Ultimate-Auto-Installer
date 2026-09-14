import SwiftUI

struct NameStepView: View {
    @Bindable var viewModel: RegisterViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Adınız ve soyadınız nedir?")
                .font(.kaTitle)
            AuthTextField(title: "Ad Soyad", text: $viewModel.fullName, textContentType: .name)
        }
    }
}
