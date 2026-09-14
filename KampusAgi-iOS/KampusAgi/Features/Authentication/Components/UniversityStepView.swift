import SwiftUI

struct UniversityStepView: View {
    @Bindable var viewModel: RegisterViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Üniversitenizi seçin")
                .font(.kaTitle)

            UniversitySearchPicker(
                query: $viewModel.universityQuery,
                results: viewModel.universityResults,
                selected: viewModel.selectedUniversity,
                isSearching: viewModel.isSearchingUniversities,
                onSelect: { viewModel.selectUniversity($0) },
                onQueryChanged: { Task { await viewModel.searchUniversities() } }
            )
        }
        .task {
            if viewModel.universityResults.isEmpty {
                await viewModel.searchUniversities()
            }
        }
    }
}
