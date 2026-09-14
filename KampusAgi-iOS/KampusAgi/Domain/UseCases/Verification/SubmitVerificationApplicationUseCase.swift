import Foundation

enum VerificationSubmissionError: Error, Equatable {
    case invalidDocument(DocumentValidationFailureReason)
    case invalidDepartment
}

protocol SubmitVerificationApplicationUseCase: Sendable {
    func callAsFunction(
        universityId: UUID,
        department: String,
        documentData: Data,
        fileName: String
    ) async throws -> VerificationStatus
}

struct DefaultSubmitVerificationApplicationUseCase: SubmitVerificationApplicationUseCase {
    let repository: StudentVerificationRepository
    let documentValidator: StudentDocumentValidating

    func callAsFunction(
        universityId: UUID,
        department: String,
        documentData: Data,
        fileName: String
    ) async throws -> VerificationStatus {
        guard department.isValidDepartmentName else {
            throw VerificationSubmissionError.invalidDepartment
        }

        if case .invalid(let reason) = documentValidator.validate(data: documentData) {
            throw VerificationSubmissionError.invalidDocument(reason)
        }

        return try await repository.submitApplication(
            universityId: universityId,
            department: department.trimmed,
            documentData: documentData,
            fileName: fileName
        )
    }
}
