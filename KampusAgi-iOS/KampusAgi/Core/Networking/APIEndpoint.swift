import Foundation

/// Describes a single backend request. The Gemini API key, and any other
/// backend secret, never appears here or anywhere on the client — the app
/// only ever talks to `AppEnvironment.apiBaseURL`, which fronts the
/// authenticated backend described in docs/BACKEND_API_CONTRACT.md.
struct APIEndpoint {
    let path: String
    let method: HTTPMethod
    var queryItems: [URLQueryItem] = []
    var body: Data? = nil
    var headers: [String: String] = [:]
    var requiresAuth: Bool = true

    func url(baseURL: URL) throws -> URL {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        return url
    }
}
