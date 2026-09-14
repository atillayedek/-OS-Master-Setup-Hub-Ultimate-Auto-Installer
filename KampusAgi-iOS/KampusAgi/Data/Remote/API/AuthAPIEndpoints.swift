import Foundation

enum AuthAPIEndpoints {
    static func sync(fullName: String?) throws -> APIEndpoint {
        let body = try JSONEncoder.kampusAgiDefault.encode(AuthSyncRequestDTO(fullName: fullName))
        return APIEndpoint(path: "/v1/auth/sync", method: .post, body: body)
    }
}
