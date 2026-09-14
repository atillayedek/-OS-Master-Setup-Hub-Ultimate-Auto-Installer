import SwiftUI

/// §13 — shown when `AccountStatus == .rejected`; lets the user upload a new
/// PDF, which moves them back to `.pendingReview` (backend-driven).
struct RejectedView: View {
    @Bindable var viewModel: StudentVerificationViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                Text("❌")
                    .font(.system(size: 64))

                Text("Belgeniz Doğrulanamadı")
                    .font(.kaLargeTitle)
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Sebep:")
                        .font(.kaCaption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.status.rejectionReason ?? "Belge okunamıyor, geçersiz veya güncel değil.")
                        .font(.kaBody)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .kaCardStyle()

                Text("Lütfen yeni bir PDF yükleyin.")
                    .font(.kaSubheadline)
                    .foregroundStyle(.secondary)

                PDFDocumentPickerButton(
                    selectedFileName: viewModel.resubmittedFileName,
                    onPicked: { data, fileName in
                        Task { await viewModel.resubmitDocument(data: data, fileName: fileName) }
                    },
                    onValidationError: { viewModel.handleValidationError($0) }
                )

                if let errorMessage = viewModel.errorMessage {
                    ErrorBanner(message: errorMessage)
                }

                Button("Çıkış Yap") {
                    Task { await viewModel.performSignOut() }
                }
                .foregroundStyle(.red)
                .frame(minHeight: Spacing.minTapTarget)
            }
            .padding(Spacing.lg)
        }
        .loadingOverlay(viewModel.isLoading, message: "Belge gönderiliyor…")
    }
}
