import SwiftUI

struct RegisterStepIndicator: View {
    let currentStep: RegisterStep

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(spacing: Spacing.xs) {
                ForEach(RegisterStep.allCases, id: \.self) { step in
                    Capsule()
                        .fill(step.rawValue <= currentStep.rawValue ? Color.brandPrimary : Color.surfaceSecondary)
                        .frame(height: 4)
                }
            }
            Text("\(currentStep.rawValue + 1)/\(RegisterStep.allCases.count) — \(currentStep.title)")
                .font(.kaCaption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Adım \(currentStep.rawValue + 1) / \(RegisterStep.allCases.count): \(currentStep.title)")
    }
}
