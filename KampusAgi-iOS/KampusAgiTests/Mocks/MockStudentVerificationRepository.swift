import Foundation
@testable import KampusAgi

final class MockStudentVerificationRepository: StudentVerificationRepository, @unchecked Sendable {
    enum Call: Equatable {
        case submit(universityId: UUID, department: String, fileName: String)
        case resubmit(fileName: String)
        case fetchStatus
    }

    var calls: [Call] = []
    var submitResult: Result<VerificationStatus, Error> = .failure(TestError.unconfigured)
    var resubmitResult: Result<VerificationStatus, Error> = .failure(TestError.unconfigured)
    var fetchStatusResult: Result<VerificationStatus, Error> = .failure(TestError.unconfigured)

    func submitApplication(universityId: UUID, department: String, documentData: Data, fileName: String) async throws -> VerificationStatus {
        calls.append(.submit(universityId: universityId, department: department, fileName: fileName))
        return try submitResult.get()
    }

    func resubmitDocument(documentData: Data, fileName: String) async throws -> VerificationStatus {
        calls.append(.resubmit(fileName: fileName))
        return try resubmitResult.get()
    }

    func fetchStatus() async throws -> VerificationStatus {
        calls.append(.fetchStatus)
        return try fetchStatusResult.get()
    }
}
