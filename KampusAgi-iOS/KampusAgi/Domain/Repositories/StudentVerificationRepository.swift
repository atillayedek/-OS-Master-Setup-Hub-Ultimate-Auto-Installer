import Foundation

protocol StudentVerificationRepository: Sendable {
    func submitApplication(
        universityId: UUID,
        department: String,
        documentData: Data,
        fileName: String
    ) async throws -> VerificationStatus

    func resubmitDocument(documentData: Data, fileName: String) async throws -> VerificationStatus

    func fetchStatus() async throws -> VerificationStatus
}
