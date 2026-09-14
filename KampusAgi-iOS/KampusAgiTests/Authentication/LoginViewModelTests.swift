import XCTest
@testable import KampusAgi

@MainActor
final class LoginViewModelTests: XCTestCase {
    func testSuccessfulSignInInvokesCallback() async {
        let repository = MockAuthenticationRepository()
        let expectedUser = User(id: "1", email: "a@b.com", fullName: "Ada", accountStatus: .approved, universityId: nil, department: nil, rejectionReason: nil)
        repository.signInResult = .success(expectedUser)

        var receivedUser: User?
        let sut = LoginViewModel(
            signIn: DefaultSignInUseCase(repository: repository),
            signInWithApple: DefaultSignInWithAppleUseCase(repository: repository),
            signInWithGoogle: DefaultSignInWithGoogleUseCase(repository: repository),
            onSignedIn: { receivedUser = $0 }
        )
        sut.email = "a@b.com"
        sut.password = "password123"

        await sut.submit()

        XCTAssertEqual(receivedUser, expectedUser)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func testInvalidEmailBlocksSubmission() async {
        let repository = MockAuthenticationRepository()
        let sut = LoginViewModel(
            signIn: DefaultSignInUseCase(repository: repository),
            signInWithApple: DefaultSignInWithAppleUseCase(repository: repository),
            signInWithGoogle: DefaultSignInWithGoogleUseCase(repository: repository),
            onSignedIn: { _ in XCTFail("Should not sign in with invalid email") }
        )
        sut.email = "not-an-email"
        sut.password = "password123"

        await sut.submit()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(repository.calls.isEmpty)
    }

    func testFailedSignInSurfacesErrorMessage() async {
        let repository = MockAuthenticationRepository()
        repository.signInResult = .failure(APIError.unauthorized)

        let sut = LoginViewModel(
            signIn: DefaultSignInUseCase(repository: repository),
            signInWithApple: DefaultSignInWithAppleUseCase(repository: repository),
            signInWithGoogle: DefaultSignInWithGoogleUseCase(repository: repository),
            onSignedIn: { _ in XCTFail("Should not report success") }
        )
        sut.email = "a@b.com"
        sut.password = "wrong-password"

        await sut.submit()

        XCTAssertEqual(sut.errorMessage, "E-posta veya şifre hatalı.")
    }
}
