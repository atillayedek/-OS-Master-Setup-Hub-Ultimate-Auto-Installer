import Foundation

enum AppConstants {
    enum Validation {
        static let departmentMinLength = 2
        static let departmentMaxLength = 150
        static let maxDocumentSizeBytes = 10 * 1024 * 1024 // 10 MB
        static let minPasswordLength = 8
    }

    enum Network {
        static let requestTimeout: TimeInterval = 30
        static let uploadTimeout: TimeInterval = 120
    }

    enum PDF {
        /// First bytes of any valid PDF file ("%PDF").
        static let magicBytes: [UInt8] = [0x25, 0x50, 0x44, 0x46]
    }
}
