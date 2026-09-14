import Foundation

final class APIStudentVerificationRepository: StudentVerificationRepository {
    private let apiClient: APIClient
    private static let pdfMimeType = "application/pdf"
    private static let documentFieldName = "document"

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func submitApplication(
        universityId: UUID,
        department: String,
        documentData: Data,
        fileName: String
    ) async throws -> VerificationStatus {
        let dto = try await apiClient.upload(
            VerificationAPIEndpoints.apply,
            fileData: documentData,
            fileName: fileName,
            mimeType: Self.pdfMimeType,
            fieldName: Self.documentFieldName,
            formFields: [
                "university_id": universityId.uuidString,
                "department": department
            ],
            as: VerificationStatusDTO.self
        )
        return dto.toDomain()
    }

    func resubmitDocument(documentData: Data, fileName: String) async throws -> VerificationStatus {
        let dto = try await apiClient.upload(
            VerificationAPIEndpoints.resubmit,
            fileData: documentData,
            fileName: fileName,
            mimeType: Self.pdfMimeType,
            fieldName: Self.documentFieldName,
            as: VerificationStatusDTO.self
        )
        return dto.toDomain()
    }

    func fetchStatus() async throws -> VerificationStatus {
        let dto = try await apiClient.send(VerificationAPIEndpoints.status, as: VerificationStatusDTO.self)
        return dto.toDomain()
    }
}
