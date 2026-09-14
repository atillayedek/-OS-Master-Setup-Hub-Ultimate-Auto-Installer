import Foundation
import Observation

@Observable
@MainActor
final class RegisterViewModel {
    var step: RegisterStep = .name

    var fullName = ""
    var email = ""
    var password = ""
    var confirmPassword = ""

    var universityQuery = ""
    var universityResults: [University] = []
    var selectedUniversity: University?
    var isSearchingUniversities = false

    var department = ""

    var documentData: Data?
    var documentFileName: String?

    var isLoading = false
    var errorMessage: String?

    private let signUp: SignUpUseCase
    private let searchUniversitiesUseCase: SearchUniversitiesUseCase
    private let submitApplicationUseCase: SubmitVerificationApplicationUseCase
    private let onRegistered: (User) -> Void

    init(
        signUp: SignUpUseCase,
        searchUniversitiesUseCase: SearchUniversitiesUseCase,
        submitApplicationUseCase: SubmitVerificationApplicationUseCase,
        onRegistered: @escaping (User) -> Void
    ) {
        self.signUp = signUp
        self.searchUniversitiesUseCase = searchUniversitiesUseCase
        self.submitApplicationUseCase = submitApplicationUseCase
        self.onRegistered = onRegistered
    }

    var isCurrentStepValid: Bool {
        switch step {
        case .name: return fullName.trimmed.count >= 2
        case .email: return email.isValidEmail
        case .password: return password.isValidPassword && password == confirmPassword
        case .university: return selectedUniversity != nil
        case .department: return department.isValidDepartmentName
        case .document: return documentData != nil
        }
    }

    var passwordMismatch: Bool {
        !confirmPassword.isEmpty && password != confirmPassword
    }

    func goNext() {
        guard isCurrentStepValid else {
            errorMessage = validationMessage(for: step)
            return
        }
        errorMessage = nil
        if let next = RegisterStep(rawValue: step.rawValue + 1) {
            step = next
        }
    }

    func goBack() {
        errorMessage = nil
        if let previous = RegisterStep(rawValue: step.rawValue - 1) {
            step = previous
        }
    }

    func searchUniversities() async {
        isSearchingUniversities = true
        defer { isSearchingUniversities = false }
        do {
            universityResults = try await searchUniversitiesUseCase(query: universityQuery)
        } catch {
            errorMessage = AuthErrorPresenter.message(for: error)
        }
    }

    func selectUniversity(_ university: University) {
        selectedUniversity = university
    }

    func setDocument(data: Data, fileName: String) {
        documentData = data
        documentFileName = fileName
        errorMessage = nil
    }

    func submit() async {
        guard isCurrentStepValid, let university = selectedUniversity, let documentData, let documentFileName else {
            errorMessage = "Öğrenci belgenizi yükleyin."
            return
        }

        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let user = try await signUp(email: email.trimmed, password: password, fullName: fullName.trimmed)
            _ = try await submitApplicationUseCase(
                universityId: university.id,
                department: department,
                documentData: documentData,
                fileName: documentFileName
            )
            onRegistered(user)
        } catch let error as VerificationSubmissionError {
            errorMessage = PDFValidationPresenter.message(for: error)
        } catch {
            errorMessage = AuthErrorPresenter.message(for: error)
        }
    }

    private func validationMessage(for step: RegisterStep) -> String {
        switch step {
        case .name: return "Ad soyad en az 2 karakter olmalı."
        case .email: return "Geçerli bir e-posta adresi girin."
        case .password: return password != confirmPassword ? "Şifreler eşleşmiyor." : "Şifre en az 8 karakter olmalı."
        case .university: return "Lütfen üniversitenizi seçin."
        case .department: return "Bölüm adı 2-150 karakter arasında olmalı."
        case .document: return "Öğrenci belgenizi yükleyin."
        }
    }
}
