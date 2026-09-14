import Foundation

enum APIError: Error, Equatable {
    case invalidURL
    case unauthorized
    case forbidden
    case notFound
    case rateLimited(retryAfter: TimeInterval?)
    case server(statusCode: Int, message: String?)
    case decoding
    case transport(String)
    case cancelled

    var isRecoverableByRetry: Bool {
        switch self {
        case .transport, .rateLimited: return true
        default: return false
        }
    }
}
