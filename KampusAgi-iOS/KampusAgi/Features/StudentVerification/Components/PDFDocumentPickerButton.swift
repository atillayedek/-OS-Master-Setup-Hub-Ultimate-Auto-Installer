import SwiftUI
import UniformTypeIdentifiers

/// PDF-only file picker (§8, §9) — filters to `.pdf`, reads the picked file
/// under security-scoped access, and runs it through `PDFValidationService`
/// before ever calling `onPicked`, so the caller only ever receives bytes
/// that already look like a real PDF.
struct PDFDocumentPickerButton: View {
    let selectedFileName: String?
    let onPicked: (Data, String) -> Void
    let onValidationError: (String) -> Void

    @State private var isPresented = false
    private let validator: StudentDocumentValidating = PDFValidationService()

    var body: some View {
        Button {
            isPresented = true
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: selectedFileName == nil ? "doc.badge.plus" : "doc.fill.badge.checkmark")
                Text(selectedFileName ?? "PDF Öğrenci Belgesi Seç")
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
            }
        }
        .buttonStyle(.kaSecondary)
        .fileImporter(
            isPresented: $isPresented,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            handle(result)
        }
    }

    private func handle(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            do {
                let data = try SecurityScopedFileReader.readData(from: url)
                switch validator.validate(data: data) {
                case .valid:
                    onPicked(data, url.lastPathComponent)
                case .invalid(let reason):
                    onValidationError(PDFValidationPresenter.message(for: reason))
                }
            } catch {
                onValidationError("Dosya okunamadı. Lütfen tekrar deneyin.")
            }
        case .failure:
            onValidationError("Dosya seçilemedi. Lütfen tekrar deneyin.")
        }
    }
}
