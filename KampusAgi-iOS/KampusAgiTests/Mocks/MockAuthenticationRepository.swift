@testable import KampusAgi

final class MockAuthenticationRepository: AuthenticationRepository, @unchecked Sendable {
    enum Call: Equatable {
        case signIn(email: String, password: String)
        case signUp(email: String, password: String, fullName: String)
        case signInWithApple
        case signInWithGoogle
        case resetPassword(email: String)
        case signOut
    }

    var calls: [Call] = []

    var signInResult: Result<User, Error> = .failure(TestError.unconfigured)
    var signUpResult: Result<User, Error> = .failure(TestError.unconfigured)
    var signInWithAppleResult: Result<User, Error> = .failure(TestError.unconfigured)
    var signInWithGoogleResult: Result<User, Error> = .failure(TestError.unconfigured)
    var resetPasswordError: Error?
    var stubbedCurrentUser: User?

    func signIn(email: String, password: String) async throws -> User {
        calls.append(.signIn(email: email, password: password))
        return try signInResult.get()
    }

    func signUp(email: String, password: String, fullName: String) async throws -> User {
        calls.append(.signUp(email: email, password: password, fullName: fullName))
        return try signUpResult.get()
    }

    func signInWithApple() async throws -> User {
        calls.append(.signInWithApple)
        return try signInWithAppleResult.get()
    }

    func signInWithGoogle() async throws -> User {
        calls.append(.signInWithGoogle)
        return try signInWithGoogleResult.get()
    }

    func resetPassword(email: String) async throws {
        calls.append(.resetPassword(email: email))
        if let resetPasswordError { throw resetPasswordError }
    }

    func signOut() async throws {
        calls.append(.signOut)
    }

    func currentUser() async -> User? {
        stubbedCurrentUser
    }

    func observeAuthState() -> AsyncStream<User?> {
        AsyncStream { $0.finish() }
    }
}

enum TestError: Error, Equatable {
    case unconfigured
    case generic
}
