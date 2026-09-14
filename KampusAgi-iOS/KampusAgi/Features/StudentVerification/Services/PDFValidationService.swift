import Foundation

/// Real, offline PDF validation — magic bytes + size, per §7. This is the
/// concrete implementation the app ships; the backend independently
/// re-validates on receipt, this is only the client-side UX gate that stops
/// an obviously-wrong file before spending an upload.
struct PDFValidationService: StudentDocumentValidating {
    func validate(data: Data) -> DocumentValidationResult {
        guard !data.isEmpty else {
            return .invalid(.empty)
        }

        guard data.count <= AppConstants.Validation.maxDocumentSizeBytes else {
            return .invalid(.tooLarge(maxBytes: AppConstants.Validation.maxDocumentSizeBytes))
        }

        let magicBytes = AppConstants.PDF.magicBytes
        guard data.count >= magicBytes.count, data.prefix(magicBytes.count).elementsEqual(magicBytes) else {
            return .invalid(.notPDF)
        }

        return .valid
    }
}
