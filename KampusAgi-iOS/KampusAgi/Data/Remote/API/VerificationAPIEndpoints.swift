import Foundation

enum VerificationAPIEndpoints {
    static func searchUniversities(query: String) -> APIEndpoint {
        let items = query.trimmed.isEmpty ? [] : [URLQueryItem(name: "query", value: query.trimmed)]
        return APIEndpoint(path: "/v1/universities", method: .get, queryItems: items)
    }

    static let apply = APIEndpoint(path: "/v1/verification/apply", method: .post)
    static let resubmit = APIEndpoint(path: "/v1/verification/resubmit", method: .post)
    static let status = APIEndpoint(path: "/v1/verification/status", method: .get)
}
