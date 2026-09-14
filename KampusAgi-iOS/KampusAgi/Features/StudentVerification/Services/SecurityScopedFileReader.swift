import Foundation

enum FileReadError: Error {
    case accessDenied
    case readFailed
}

/// Reads a `.fileImporter` result URL under a security-scoped resource
/// access token, per §9. The temporary local copy is never retained after
/// the byte contents are read into memory — nothing is cached to disk
/// beyond what iOS itself already staged.
enum SecurityScopedFileReader {
    static func readData(from url: URL) throws -> Data {
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            return try Data(contentsOf: url)
        } catch {
            throw FileReadError.readFailed
        }
    }
}
