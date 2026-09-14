import Foundation

protocol ResubmitStudentDocumentUseCase: Sendable {
    func callAsFunction(documentData: Data, fileName: String) async throws -> VerificationStatus
}

struct DefaultResubmitStudentDocumentUseCase: ResubmitStudentDocumentUseCase {
    let repository: StudentVerificationRepository
    let documentValidator: StudentDocumentValidating

    func callAsFunction(documentData: Data, fileName: String) async throws -> VerificationStatus {
        if case .invalid(let reason) = documentValidator.validate(data: documentData) {
            throw VerificationSubmissionError.invalidDocument(reason)
        }
        return try await repository.resubmitDocument(documentData: documentData, fileName: fileName)
    }
}
