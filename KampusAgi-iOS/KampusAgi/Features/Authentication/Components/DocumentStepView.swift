import SwiftUI

struct DocumentStepView: View {
    @Bindable var viewModel: RegisterViewModel
    @State private var showHelpSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Öğrenci belgenizi yükleyin")
                    .font(.kaTitle)
                Spacer()
                Button {
                    showHelpSheet = true
                } label: {
                    Image(systemName: "questionmark.circle")
                }
                .frame(width: Spacing.minTapTarget, height: Spacing.minTapTarget)
                .accessibilityLabel("Öğrenci belgesi nasıl alınır?")
            }

            PDFDocumentPickerButton(
                selectedFileName: viewModel.documentFileName,
                onPicked: { data, fileName in viewModel.setDocument(data: data, fileName: fileName) },
                onValidationError: { viewModel.errorMessage = $0 }
            )

            Text("Yalnızca resmi PDF öğrenci belgesi kabul edilir. Ekran görüntüsü veya fotoğraf yüklemeyin.")
                .font(.kaCaption)
                .foregroundStyle(.secondary)
        }
        .sheet(isPresented: $showHelpSheet) {
            StudentDocumentHelpSheet()
                .presentationDetents([.medium, .large])
        }
    }
}
