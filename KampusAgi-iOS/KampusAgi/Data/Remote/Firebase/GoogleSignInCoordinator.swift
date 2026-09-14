import FirebaseAuth
import GoogleSignIn
import UIKit

enum GoogleSignInError: Error {
    case missingPresentingViewController
    case missingIdToken
}

@MainActor
final class GoogleSignInCoordinator {
    func requestSignIn() async throws -> AuthCredential {
        guard let presentingViewController = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?.rootViewController else {
            throw GoogleSignInError.missingPresentingViewController
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)

        guard let idToken = result.user.idToken?.tokenString else {
            throw GoogleSignInError.missingIdToken
        }

        return GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
    }
}
