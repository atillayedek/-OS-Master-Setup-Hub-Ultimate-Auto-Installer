import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    var isLoading: Bool = false
    var isDisabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: Spacing.sm) {
            if isLoading {
                ProgressView()
                    .tint(.white)
            }
            configuration.label
                .font(.kaHeadline)
        }
        .frame(maxWidth: .infinity, minHeight: Spacing.minTapTarget)
        .foregroundStyle(.white)
        .background((isDisabled ? Color.gray : Color.brandPrimary).opacity(configuration.isPressed ? 0.85 : 1))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .opacity(isDisabled ? 0.6 : 1)
        .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.kaHeadline)
            .frame(maxWidth: .infinity, minHeight: Spacing.minTapTarget)
            .foregroundStyle(Color.brandPrimary)
            .background(Color.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.brandPrimary.opacity(0.4), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static func kaPrimary(isLoading: Bool = false, isDisabled: Bool = false) -> PrimaryButtonStyle {
        PrimaryButtonStyle(isLoading: isLoading, isDisabled: isDisabled)
    }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var kaSecondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}
