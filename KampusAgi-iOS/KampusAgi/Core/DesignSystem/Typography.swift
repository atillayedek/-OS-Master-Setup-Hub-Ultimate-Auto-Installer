import SwiftUI

/// Wraps Dynamic Type text styles rather than fixed point sizes, so every
/// screen respects the user's chosen text size (§38, accessibility is
/// mandatory).
extension Font {
    static let kaLargeTitle = Font.largeTitle.weight(.bold)
    static let kaTitle = Font.title2.weight(.semibold)
    static let kaHeadline = Font.headline
    static let kaBody = Font.body
    static let kaSubheadline = Font.subheadline
    static let kaCaption = Font.caption
}
