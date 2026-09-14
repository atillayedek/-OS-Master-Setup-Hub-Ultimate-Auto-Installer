import SwiftUI

/// Brand palette. Uses named Asset Catalog colors so every value has a
/// light/dark variant configured in Xcode (Assets.xcassets/Colors) — Dark
/// Mode is mandatory per §36, not an afterthought bolted on with `.dark`
/// overrides here.
extension Color {
    static let brandPrimary = Color("BrandPrimary", bundle: .main)
    static let brandSecondary = Color("BrandSecondary", bundle: .main)
    static let brandAccent = Color("BrandAccent", bundle: .main)

    static let surfacePrimary = Color(.systemBackground)
    static let surfaceSecondary = Color(.secondarySystemBackground)
    static let surfaceCard = Color(.tertiarySystemBackground)

    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)

    static let statusPending = Color("StatusPending", bundle: .main)
    static let statusApproved = Color("StatusApproved", bundle: .main)
    static let statusRejected = Color("StatusRejected", bundle: .main)
}
