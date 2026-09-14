import Foundation

/// Turkish, user-facing copy for validation failures — kept separate from
/// `PDFValidationService` so the pure validation logic stays trivially
/// testable without string assertions.
enum PDFValidationPresenter {
    static func message(for reason: DocumentValidationFailureReason) -> String {
        switch reason {
        case .notPDF:
            return "Yalnızca PDF formatında öğrenci belgesi kabul edilir. Ekran görüntüsü veya fotoğraf yükleyemezsiniz."
        case .tooLarge(let maxBytes):
            let maxMB = maxBytes / (1024 * 1024)
            return "Dosya çok büyük. Maksimum \(maxMB) MB boyutunda bir PDF yükleyin."
        case .empty:
            return "Seçilen dosya okunamadı. Lütfen tekrar deneyin."
        case .unreadable:
            return "Dosya okunamıyor veya bozuk. Lütfen geçerli bir PDF yükleyin."
        }
    }

    static func message(for error: VerificationSubmissionError) -> String {
        switch error {
        case .invalidDocument(let reason): return message(for: reason)
        case .invalidDepartment: return "Bölüm adı 2-150 karakter arasında olmalı."
        }
    }
}
