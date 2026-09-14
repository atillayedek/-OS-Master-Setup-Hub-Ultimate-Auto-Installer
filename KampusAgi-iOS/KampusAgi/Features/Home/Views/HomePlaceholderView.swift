import SwiftUI

/// Shown once an account is `.approved`. Deliberately minimal: Communities,
/// Matchmaking, Chat, etc. are future phases (see docs/PHASE1_AUDIT.md §4) —
/// this is not a placeholder pretending those features exist, it's the
/// confirmation that gating worked and a sign-out escape hatch.
struct HomePlaceholderView: View {
    let user: User
    let onSignOut: () -> Void

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.statusApproved)

            Text("Hoş geldin, \(user.fullName)")
                .font(.kaLargeTitle)
                .multilineTextAlignment(.center)

            Text("Hesabınız onaylandı. Topluluklar, eşleştirme ve sohbet özellikleri sonraki geliştirme fazlarında eklenecek.")
                .font(.kaBody)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Button("Çıkış Yap", action: onSignOut)
                .buttonStyle(.kaSecondary)
        }
        .padding(Spacing.lg)
        .navigationTitle("KampüsAğı")
    }
}
