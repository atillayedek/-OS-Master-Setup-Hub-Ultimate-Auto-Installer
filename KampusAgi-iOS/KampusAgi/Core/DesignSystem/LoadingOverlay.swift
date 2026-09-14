import SwiftUI

struct LoadingOverlay: View {
    var message: String?

    var body: some View {
        VStack(spacing: Spacing.md) {
            ProgressView()
                .controlSize(.large)
            if let message {
                Text(message)
                    .font(.kaSubheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(Spacing.lg)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

struct ErrorBanner: View {
    let message: String
    var onDismiss: (() -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            Text(message)
                .font(.kaSubheadline)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            if let onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                }
                .frame(width: Spacing.minTapTarget, height: Spacing.minTapTarget)
                .accessibilityLabel("Kapat")
            }
        }
        .padding(Spacing.sm)
        .background(Color.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
