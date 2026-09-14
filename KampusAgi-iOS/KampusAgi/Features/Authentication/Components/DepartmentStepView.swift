import SwiftUI

struct DepartmentStepView: View {
    @Bindable var viewModel: RegisterViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Bölümünüz nedir?")
                .font(.kaTitle)
            AuthTextField(title: "Örn. Bilgisayar Mühendisliği", text: $viewModel.department)
            Text("\(viewModel.department.trimmed.count)/\(AppConstants.Validation.departmentMaxLength)")
                .font(.kaCaption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}
