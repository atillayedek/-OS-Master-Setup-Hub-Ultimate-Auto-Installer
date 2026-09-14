import SwiftUI

struct AuthTextField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var autocapitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(.kaCaption)
                .foregroundStyle(.secondary)
            TextField(title, text: $text)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled(keyboardType == .emailAddress)
                .padding(Spacing.md)
                .frame(minHeight: Spacing.minTapTarget)
                .background(Color.surfaceSecondary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .accessibilityElement(children: .combine)
    }
}

struct AuthSecureField: View {
    let title: String
    @Binding var text: String
    @State private var isRevealed = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(.kaCaption)
                .foregroundStyle(.secondary)
            HStack {
                Group {
                    if isRevealed {
                        TextField(title, text: $text)
                    } else {
                        SecureField(title, text: $text)
                    }
                }
                .textContentType(.password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

                Button {
                    isRevealed.toggle()
                } label: {
                    Image(systemName: isRevealed ? "eye.slash" : "eye")
                        .foregroundStyle(.secondary)
                }
                .frame(width: Spacing.minTapTarget, height: Spacing.minTapTarget)
                .accessibilityLabel(isRevealed ? "Şifreyi gizle" : "Şifreyi göster")
            }
            .padding(.horizontal, Spacing.md)
            .frame(minHeight: Spacing.minTapTarget)
            .background(Color.surfaceSecondary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .accessibilityElement(children: .combine)
    }
}
