import Foundation
import SwiftData

/// The single composition root: builds every concrete dependency once and
/// hands out protocol-typed use cases to Views/ViewModels via explicit
/// constructor injection (never a global singleton reached into from a
/// View), per §2's "Protocol-based Dependency Injection" requirement.
@MainActor
final class AppDependencyContainer {
    private let authService: FirebaseAuthService
    private let apiClient: APIClient
    private let keychain: KeychainServiceProtocol
    private let authenticationRepository: AuthenticationRepository
    private let universityRepository: UniversityRepository
    private let studentVerificationRepository: StudentVerificationRepository
    private let documentValidator: StudentDocumentValidating

    init() {
        let environment = AppEnvironment.current
        let authService = FirebaseAuthService()
        let tokenProvider = FirebaseIDTokenProvider(authService: authService)
        let apiClient = URLSessionAPIClient(baseURL: environment.apiBaseURL, tokenProvider: tokenProvider)

        self.authService = authService
        self.apiClient = apiClient
        self.keychain = KeychainService()
        self.authenticationRepository = FirebaseAuthenticationRepository(
            authService: authService,
            apiClient: apiClient,
            appleSignInCoordinator: AppleSignInCoordinator(),
            googleSignInCoordinator: GoogleSignInCoordinator()
        )

        let modelContainer = try! ModelContainer(for: CachedUniversity.self)
        let universityCache = UniversityCacheStore(modelContainer: modelContainer)
        self.universityRepository = APIUniversityRepository(apiClient: apiClient, cache: universityCache)
        self.studentVerificationRepository = APIStudentVerificationRepository(apiClient: apiClient)
        self.documentValidator = PDFValidationService()
    }

    // MARK: - Session

    func makeObserveCurrentUserUseCase() -> ObserveCurrentUserUseCase {
        DefaultObserveCurrentUserUseCase(repository: authenticationRepository)
    }

    func makeSignOutUseCase() -> SignOutUseCase {
        DefaultSignOutUseCase(repository: authenticationRepository)
    }

    func currentUser() async -> User? {
        await authenticationRepository.currentUser()
    }

    // MARK: - Authentication

    func makeLoginViewModel(onSignedIn: @escaping (User) -> Void) -> LoginViewModel {
        LoginViewModel(
            signIn: DefaultSignInUseCase(repository: authenticationRepository),
            signInWithApple: DefaultSignInWithAppleUseCase(repository: authenticationRepository),
            signInWithGoogle: DefaultSignInWithGoogleUseCase(repository: authenticationRepository),
            onSignedIn: onSignedIn
        )
    }

    func makeRegisterViewModel(onRegistered: @escaping (User) -> Void) -> RegisterViewModel {
        RegisterViewModel(
            signUp: DefaultSignUpUseCase(repository: authenticationRepository),
            searchUniversitiesUseCase: DefaultSearchUniversitiesUseCase(repository: universityRepository),
            submitApplicationUseCase: DefaultSubmitVerificationApplicationUseCase(
                repository: studentVerificationRepository,
                documentValidator: documentValidator
            ),
            onRegistered: onRegistered
        )
    }

    func makeForgotPasswordViewModel() -> ForgotPasswordViewModel {
        ForgotPasswordViewModel(resetPassword: DefaultResetPasswordUseCase(repository: authenticationRepository))
    }

    // MARK: - Student Verification

    func makeStudentVerificationViewModel(
        user: User,
        onStatusChanged: @escaping (VerificationStatus) -> Void
    ) -> StudentVerificationViewModel {
        StudentVerificationViewModel(
            initialStatus: VerificationStatus(accountStatus: user.accountStatus, rejectionReason: user.rejectionReason),
            fetchStatus: DefaultFetchVerificationStatusUseCase(repository: studentVerificationRepository),
            resubmitDocument: DefaultResubmitStudentDocumentUseCase(
                repository: studentVerificationRepository,
                documentValidator: documentValidator
            ),
            signOut: DefaultSignOutUseCase(repository: authenticationRepository),
            onStatusChanged: onStatusChanged
        )
    }
}
