import SwiftUI

extension View {
    /// Applies a semi-transparent blocking overlay + `LoadingOverlay` while
    /// `isLoading` is true, disabling interaction underneath.
    @ViewBuilder
    func loadingOverlay(_ isLoading: Bool, message: String? = nil) -> some View {
        overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.15).ignoresSafeArea()
                    LoadingOverlay(message: message)
                }
                .transition(.opacity)
                .accessibilityAddTraits(.updatesFrequently)
            }
        }
        .disabled(isLoading)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }

    func kaCardStyle() -> some View {
        padding(Spacing.md)
            .background(Color.surfaceCard, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
