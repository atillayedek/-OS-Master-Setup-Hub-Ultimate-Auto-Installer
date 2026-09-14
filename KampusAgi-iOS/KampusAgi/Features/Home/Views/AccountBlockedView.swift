import SwiftUI

struct AccountBlockedView: View {
    let title: String
    let message: String
    let onSignOut: () -> Void

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "exclamationmark.octagon.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.statusRejected)

            Text(title)
                .font(.kaLargeTitle)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.kaBody)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Button("Çıkış Yap", action: onSignOut)
                .buttonStyle(.kaPrimary())
        }
        .padding(Spacing.lg)
    }
}
