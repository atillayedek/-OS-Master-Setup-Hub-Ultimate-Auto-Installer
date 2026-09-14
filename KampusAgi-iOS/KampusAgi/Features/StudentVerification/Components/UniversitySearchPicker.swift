import SwiftUI

/// Searchable picker only — the university list always comes from the
/// backend (§17); there is no hardcoded array of Turkish university names
/// anywhere in the UI layer.
struct UniversitySearchPicker: View {
    @Binding var query: String
    let results: [University]
    let selected: University?
    let isSearching: Bool
    let onSelect: (University) -> Void
    let onQueryChanged: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            AuthTextField(title: "Üniversite Ara", text: $query, autocapitalization: .words)
                .onChange(of: query) { onQueryChanged() }

            if let selected {
                HStack {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                    Text(selected.name)
                        .font(.kaSubheadline.weight(.semibold))
                }
                .kaCardStyle()
            }

            if isSearching {
                ProgressView().frame(maxWidth: .infinity, alignment: .center)
            } else if !results.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(results) { university in
                            Button {
                                onSelect(university)
                            } label: {
                                VStack(alignment: .leading, spacing: Spacing.xs) {
                                    Text(university.name)
                                        .font(.kaBody)
                                        .foregroundStyle(Color.textPrimary)
                                    Text(university.city)
                                        .font(.kaCaption)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, Spacing.sm)
                            }
                            Divider()
                        }
                    }
                }
                .frame(maxHeight: 260)
            }
        }
    }
}
