import SwiftUI

/// §12 — shown while `AccountStatus` is `.pendingDocument` or `.pendingReview`.
struct PendingReviewView: View {
    @Bindable var viewModel: StudentVerificationViewModel

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            Text("⏳")
                .font(.system(size: 64))

            Text("Başvurunuz İnceleniyor")
                .font(.kaLargeTitle)
                .multilineTextAlignment(.center)

            Text("Öğrenci belgeniz admin ekibimiz tarafından kontrol ediliyor.\n\nBu işlem tamamlandığında bildirim alacaksınız.")
                .font(.kaBody)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let errorMessage = viewModel.errorMessage {
                ErrorBanner(message: errorMessage)
            }

            Spacer()

            VStack(spacing: Spacing.sm) {
                Button {
                    Task { await viewModel.refreshStatus() }
                } label: {
                    Text("Başvuru Durumunu Yenile")
                }
                .buttonStyle(.kaPrimary(isLoading: viewModel.isLoading))
                .disabled(viewModel.isLoading)

                Button("Çıkış Yap") {
                    Task { await viewModel.performSignOut() }
                }
                .foregroundStyle(.red)
                .frame(minHeight: Spacing.minTapTarget)
            }
        }
        .padding(Spacing.lg)
        .task {
            await viewModel.refreshStatus()
        }
    }
}
