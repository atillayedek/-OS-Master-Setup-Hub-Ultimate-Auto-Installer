import Foundation

enum KeychainError: Error {
    case unhandled(OSStatus)
    case notFound
    case encoding
}

/// Secure storage for session/refresh tokens and any other sensitive
/// identifier — per §35, secrets never go into UserDefaults.
protocol KeychainServiceProtocol: Sendable {
    func set(_ value: String, for key: String) throws
    func get(_ key: String) throws -> String?
    func delete(_ key: String) throws
}
