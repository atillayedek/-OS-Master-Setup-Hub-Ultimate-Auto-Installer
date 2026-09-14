import AuthenticationServices
import SwiftUI

struct SocialSignInButtons: View {
    var onAppleTap: () -> Void
    var onGoogleTap: () -> Void

    var body: some View {
        VStack(spacing: Spacing.sm) {
            SignInWithAppleButton(.continue) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { _ in
                // Actual credential exchange happens in AppleSignInCoordinator;
                // this button is presentation-only, tapping triggers onAppleTap.
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: Spacing.minTapTarget)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .allowsHitTesting(false)
            .overlay(
                Button(action: onAppleTap) { Color.clear }
            )

            Button(action: onGoogleTap) {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "globe")
                    Text("Google ile devam et")
                }
            }
            .buttonStyle(.kaSecondary)
        }
    }
}
