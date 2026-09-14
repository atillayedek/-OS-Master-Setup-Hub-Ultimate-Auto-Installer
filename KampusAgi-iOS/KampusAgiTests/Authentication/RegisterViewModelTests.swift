import XCTest
@testable import KampusAgi

@MainActor
final class RegisterViewModelTests: XCTestCase {
    private func makeSUT(
        authRepository: MockAuthenticationRepository = MockAuthenticationRepository(),
        universityRepository: MockUniversityRepository = MockUniversityRepository(),
        verificationRepository: MockStudentVerificationRepository = MockStudentVerificationRepository(),
        onRegistered: @escaping (User) -> Void = { _ in }
    ) -> RegisterViewModel {
        RegisterViewModel(
            signUp: DefaultSignUpUseCase(repository: authRepository),
            searchUniversitiesUseCase: DefaultSearchUniversitiesUseCase(repository: universityRepository),
            submitApplicationUseCase: DefaultSubmitVerificationApplicationUseCase(
                repository: verificationRepository,
                documentValidator: PDFValidationService()
            ),
            onRegistered: onRegistered
        )
    }

    func testCannotAdvancePastInvalidNameStep() {
        let sut = makeSUT()
        sut.fullName = "A"

        sut.goNext()

        XCTAssertEqual(sut.step, .name)
        XCTAssertNotNil(sut.errorMessage)
    }

    func testAdvancesThroughStepsWhenValid() {
        let sut = makeSUT()
        sut.fullName = "Ada Lovelace"
        sut.goNext()
        XCTAssertEqual(sut.step, .email)

        sut.email = "ada@example.com"
        sut.goNext()
        XCTAssertEqual(sut.step, .password)

        sut.password = "password123"
        sut.confirmPassword = "password123"
        sut.goNext()
        XCTAssertEqual(sut.step, .university)
    }

    func testMismatchedPasswordsBlockAdvancing() {
        let sut = makeSUT()
        sut.fullName = "Ada Lovelace"
        sut.goNext()
        sut.email = "ada@example.com"
        sut.goNext()

        sut.password = "password123"
        sut.confirmPassword = "different"
        sut.goNext()

        XCTAssertEqual(sut.step, .password)
        XCTAssertTrue(sut.passwordMismatch)
    }

    func testSubmitCreatesAccountAndSubmitsApplication() async {
        let authRepository = MockAuthenticationRepository()
        let university = University(id: UUID(), name: "ODTÜ", officialName: nil, domain: "metu.edu.tr", city: "Ankara", type: .state)
        let expectedUser = User(id: "u1", email: "ada@example.com", fullName: "Ada Lovelace", accountStatus: .pendingReview, universityId: university.id, department: "Bilgisayar Mühendisliği", rejectionReason: nil)
        authRepository.signUpResult = .success(expectedUser)

        let verificationRepository = MockStudentVerificationRepository()
        verificationRepository.submitResult = .success(VerificationStatus(accountStatus: .pendingReview, rejectionReason: nil))

        var registeredUser: User?
        let sut = makeSUT(authRepository: authRepository, verificationRepository: verificationRepository, onRegistered: { registeredUser = $0 })

        sut.fullName = "Ada Lovelace"
        sut.email = "ada@example.com"
        sut.password = "password123"
        sut.confirmPassword = "password123"
        sut.selectUniversity(university)
        sut.department = "Bilgisayar Mühendisliği"

        var pdfData = Data([0x25, 0x50, 0x44, 0x46])
        pdfData.append(Data(repeating: 0, count: 50))
        sut.setDocument(data: pdfData, fileName: "belge.pdf")
        sut.step = .document

        await sut.submit()

        XCTAssertEqual(registeredUser, expectedUser)
        XCTAssertEqual(authRepository.calls, [.signUp(email: "ada@example.com", password: "password123", fullName: "Ada Lovelace")])
        XCTAssertEqual(verificationRepository.calls, [.submit(universityId: university.id, department: "Bilgisayar Mühendisliği", fileName: "belge.pdf")])
    }

    func testSubmitWithInvalidDocumentSurfacesValidationMessage() async {
        let authRepository = MockAuthenticationRepository()
        authRepository.signUpResult = .success(User(id: "u1", email: "a@b.com", fullName: "Ada", accountStatus: .pendingDocument, universityId: nil, department: nil, rejectionReason: nil))
        let university = University(id: UUID(), name: "ODTÜ", officialName: nil, domain: "metu.edu.tr", city: "Ankara", type: .state)

        let sut = makeSUT(authRepository: authRepository)
        sut.fullName = "Ada Lovelace"
        sut.email = "ada@example.com"
        sut.password = "password123"
        sut.confirmPassword = "password123"
        sut.selectUniversity(university)
        sut.department = "Bilgisayar Mühendisliği"
        // Not a real PDF — magic bytes deliberately wrong.
        sut.setDocument(data: Data([0x00, 0x01, 0x02]), fileName: "fake.pdf")
        sut.step = .document

        await sut.submit()

        XCTAssertEqual(sut.errorMessage, "Yalnızca PDF formatında öğrenci belgesi kabul edilir. Ekran görüntüsü veya fotoğraf yükleyemezsiniz.")
    }
}
