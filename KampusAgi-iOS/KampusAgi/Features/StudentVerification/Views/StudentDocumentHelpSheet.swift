import SwiftUI

/// §8 — explains how to obtain the official student-document PDF, presented
/// as a `.sheet` with medium/large detents from the document step.
struct StudentDocumentHelpSheet: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                Text("Öğrenci belgenizi nasıl alırım?")
                    .font(.kaTitle)

                VStack(alignment: .leading, spacing: Spacing.md) {
                    helpStep(number: 1, text: "Üniversitenizin Öğrenci Bilgi Sistemi'ne giriş yapın.")
                    helpStep(number: 2, text: "Öğrenci Belgesi veya Belge Talepleri bölümünü açın.")
                    helpStep(number: 3, text: "Güncel tarihli öğrenci belgesini oluşturun.")
                    helpStep(number: 4, text: "Belgeyi PDF olarak indirin.")
                    helpStep(number: 5, text: "İndirdiğiniz PDF dosyasını buraya yükleyin.")
                }

                ErrorBanner(message: "Önemli: Ekran görüntüsü veya fotoğraf yüklemeyin. Yalnızca resmi PDF öğrenci belgesi kabul edilir.")
            }
            .padding(Spacing.lg)
        }
    }

    private func helpStep(number: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Text("\(number)")
                .font(.kaHeadline)
                .frame(width: 28, height: 28)
                .background(Color.brandPrimary.opacity(0.15), in: Circle())
            Text(text)
                .font(.kaBody)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
