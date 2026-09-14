import AuthenticationServices
import CryptoKit
import FirebaseAuth
import UIKit

enum AppleSignInError: Error {
    case missingIdentityToken
    case invalidCredential
}

/// Runs the native "Sign in with Apple" sheet and produces a Firebase
/// `AuthCredential`. Apple Sign-In is mandatory for App Store review whenever
/// other third-party logins are offered (§3).
@MainActor
final class AppleSignInCoordinator: NSObject {
    private var continuation: CheckedContinuation<AuthCredential, Error>?
    private var currentNonce: String?

    func requestSignIn() async throws -> AuthCredential {
        let nonce = Self.randomNonceString()
        currentNonce = nonce

        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = Self.sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            controller.performRequests()
        }
    }

    private static func randomNonceString(length: Int = 32) -> String {
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        while remainingLength > 0 {
            var randomByte: UInt8 = 0
            _ = SecRandomCopyBytes(kSecRandomDefault, 1, &randomByte)
            if randomByte < charset.count {
                result.append(charset[Int(randomByte)])
                remainingLength -= 1
            }
        }
        return result
    }

    private static func sha256(_ input: String) -> String {
        let hashed = SHA256.hash(data: Data(input.utf8))
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}

extension AppleSignInCoordinator: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        defer { continuation = nil }

        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = appleIDCredential.identityToken,
              let idTokenString = String(data: identityToken, encoding: .utf8),
              let nonce = currentNonce else {
            continuation?.resume(throwing: AppleSignInError.missingIdentityToken)
            return
        }

        let credential = OAuthProvider.credential(
            providerID: .apple,
            idToken: idTokenString,
            rawNonce: nonce
        )
        continuation?.resume(returning: credential)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        defer { continuation = nil }
        continuation?.resume(throwing: error)
    }
}

extension AppleSignInCoordinator: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow) ?? ASPresentationAnchor()
    }
}
