import os

/// Thin wrapper over os.Logger so call sites don't hardcode subsystem/category
/// strings, and so we have one place to make sure sensitive data (tokens,
/// passwords, document contents, emails) never gets logged — see brief §54.
enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.kampusagi.app"

    static let auth = Logger(subsystem: subsystem, category: "authentication")
    static let verification = Logger(subsystem: subsystem, category: "verification")
    static let network = Logger(subsystem: subsystem, category: "network")
}
