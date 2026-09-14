import XCTest
@testable import KampusAgi

@MainActor
final class StudentVerificationViewModelTests: XCTestCase {
    private func makeSUT(
        initialStatus: VerificationStatus = VerificationStatus(accountStatus: .pendingReview, rejectionReason: nil),
        verificationRepository: MockStudentVerificationRepository = MockStudentVerificationRepository(),
        authRepository: MockAuthenticationRepository = MockAuthenticationRepository(),
        onStatusChanged: @escaping (VerificationStatus) -> Void = { _ in }
    ) -> StudentVerificationViewModel {
        StudentVerificationViewModel(
            initialStatus: initialStatus,
            fetchStatus: DefaultFetchVerificationStatusUseCase(repository: verificationRepository),
            resubmitDocument: DefaultResubmitStudentDocumentUseCase(repository: verificationRepository, documentValidator: PDFValidationService()),
            signOut: DefaultSignOutUseCase(repository: authRepository),
            onStatusChanged: onStatusChanged
        )
    }

    func testRefreshStatusUpdatesStatusAndNotifies() async {
        let repository = MockStudentVerificationRepository()
        repository.fetchStatusResult = .success(VerificationStatus(accountStatus: .approved, rejectionReason: nil))

        var notified: VerificationStatus?
        let sut = makeSUT(verificationRepository: repository, onStatusChanged: { notified = $0 })

        await sut.refreshStatus()

        XCTAssertEqual(sut.status.accountStatus, .approved)
        XCTAssertEqual(notified?.accountStatus, .approved)
        XCTAssertNil(sut.errorMessage)
    }

    func testResubmitDocumentWithValidPDFUpdatesStatus() async {
        let repository = MockStudentVerificationRepository()
        repository.resubmitResult = .success(VerificationStatus(accountStatus: .pendingReview, rejectionReason: nil))

        let sut = makeSUT(initialStatus: VerificationStatus(accountStatus: .rejected, rejectionReason: "Belge okunamadı."), verificationRepository: repository)

        var data = Data([0x25, 0x50, 0x44, 0x46])
        data.append(Data(repeating: 0, count: 20))

        await sut.resubmitDocument(data: data, fileName: "yeni-belge.pdf")

        XCTAssertEqual(sut.status.accountStatus, .pendingReview)
        XCTAssertEqual(sut.resubmittedFileName, "yeni-belge.pdf")
        XCTAssertEqual(repository.calls, [.resubmit(fileName: "yeni-belge.pdf")])
    }

    func testResubmitDocumentWithInvalidPDFDoesNotCallRepository() async {
        let repository = MockStudentVerificationRepository()
        let sut = makeSUT(verificationRepository: repository)

        await sut.resubmitDocument(data: Data([0x00, 0x01]), fileName: "screenshot.pdf")

        XCTAssertTrue(repository.calls.isEmpty)
        XCTAssertNotNil(sut.errorMessage)
    }
}
