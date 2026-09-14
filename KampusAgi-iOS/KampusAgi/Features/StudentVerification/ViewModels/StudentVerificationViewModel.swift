import Foundation
import Observation

/// Drives the Pending Review / Rejected screens: refreshing status on demand
/// (§12) and letting a rejected user resubmit a new PDF (§13). The backend
/// stays authoritative — this view model only ever reflects what
/// `FetchVerificationStatusUseCase` / `ResubmitStudentDocumentUseCase` return.
@Observable
@MainActor
final class StudentVerificationViewModel {
    private(set) var status: VerificationStatus
    var isLoading = false
    var errorMessage: String?
    var resubmittedFileName: String?

    private let fetchStatusUseCase: FetchVerificationStatusUseCase
    private let resubmitDocumentUseCase: ResubmitStudentDocumentUseCase
    private let signOutUseCase: SignOutUseCase
    private let onStatusChanged: (VerificationStatus) -> Void

    init(
        initialStatus: VerificationStatus,
        fetchStatus: FetchVerificationStatusUseCase,
        resubmitDocument: ResubmitStudentDocumentUseCase,
        signOut: SignOutUseCase,
        onStatusChanged: @escaping (VerificationStatus) -> Void
    ) {
        self.status = initialStatus
        self.fetchStatusUseCase = fetchStatus
        self.resubmitDocumentUseCase = resubmitDocument
        self.signOutUseCase = signOut
        self.onStatusChanged = onStatusChanged
    }

    func refreshStatus() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let newStatus = try await fetchStatusUseCase()
            status = newStatus
            onStatusChanged(newStatus)
        } catch {
            errorMessage = AuthErrorPresenter.message(for: error)
        }
    }

    func resubmitDocument(data: Data, fileName: String) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let newStatus = try await resubmitDocumentUseCase(documentData: data, fileName: fileName)
            status = newStatus
            resubmittedFileName = fileName
            onStatusChanged(newStatus)
        } catch let error as VerificationSubmissionError {
            errorMessage = PDFValidationPresenter.message(for: error)
        } catch {
            errorMessage = AuthErrorPresenter.message(for: error)
        }
    }

    func handleValidationError(_ message: String) {
        errorMessage = message
    }

    func performSignOut() async {
        try? await signOutUseCase()
    }
}
