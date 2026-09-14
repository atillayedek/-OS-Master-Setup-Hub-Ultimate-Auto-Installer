import Foundation

enum DocumentValidationFailureReason: Equatable, Sendable {
    case notPDF
    case tooLarge(maxBytes: Int)
    case empty
    case unreadable
}

enum DocumentValidationResult: Equatable, Sendable {
    case valid
    case invalid(DocumentValidationFailureReason)
}

/// Pure, offline validation — checked on-device before spending an upload,
/// but never trusted as the final word: the backend re-validates on receipt
/// (§7, client-side checks are a UX convenience, not the authorization).
protocol StudentDocumentValidating: Sendable {
    func validate(data: Data) -> DocumentValidationResult
}
