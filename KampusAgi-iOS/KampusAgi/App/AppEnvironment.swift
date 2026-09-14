import Foundation

/// Reads the non-secret, environment-specific values injected via
/// `Configs/*.xcconfig` → Info.plist at build time (§52, §53). The Gemini
/// API key is never one of these — it never reaches the client.
struct AppEnvironment {
    let apiBaseURL: URL
    let firebaseProjectId: String
    let googleSignInClientID: String
    let environmentName: String

    static let current: AppEnvironment = {
        let info = Bundle.main.infoDictionary ?? [:]

        guard let apiBaseURLString = info["API_BASE_URL"] as? String,
              let apiBaseURL = URL(string: apiBaseURLString) else {
            fatalError("API_BASE_URL missing or invalid in Info.plist — check Configs/*.xcconfig")
        }

        let firebaseProjectId = info["FIREBASE_PROJECT_ID"] as? String ?? ""
        let googleSignInClientID = info["GOOGLE_SIGN_IN_CLIENT_ID"] as? String ?? ""
        let environmentName = info["APP_ENVIRONMENT_NAME"] as? String ?? "development"

        return AppEnvironment(
            apiBaseURL: apiBaseURL,
            firebaseProjectId: firebaseProjectId,
            googleSignInClientID: googleSignInClientID,
            environmentName: environmentName
        )
    }()
}
