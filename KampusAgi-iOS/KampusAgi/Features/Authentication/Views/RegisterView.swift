import SwiftUI

struct RegisterView: View {
    @State private var viewModel: RegisterViewModel

    init(container: AppDependencyContainer, onRegistered: @escaping (User) -> Void) {
        _viewModel = State(initialValue: container.makeRegisterViewModel(onRegistered: onRegistered))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                RegisterStepIndicator(currentStep: viewModel.step)

                stepContent

                if let errorMessage = viewModel.errorMessage {
                    ErrorBanner(message: errorMessage)
                }

                HStack(spacing: Spacing.sm) {
                    if viewModel.step > .name {
                        Button("Geri", action: viewModel.goBack)
                            .buttonStyle(.kaSecondary)
                    }

                    if viewModel.step == .document {
                        Button {
                            Task { await viewModel.submit() }
                        } label: {
                            Text("Başvuruyu Gönder")
                        }
                        .buttonStyle(.kaPrimary(isLoading: viewModel.isLoading, isDisabled: !viewModel.isCurrentStepValid))
                        .disabled(!viewModel.isCurrentStepValid || viewModel.isLoading)
                    } else {
                        Button("İleri", action: viewModel.goNext)
                            .buttonStyle(.kaPrimary(isDisabled: !viewModel.isCurrentStepValid))
                            .disabled(!viewModel.isCurrentStepValid)
                    }
                }
            }
            .padding(Spacing.lg)
        }
        .navigationTitle("Kayıt Ol")
        .navigationBarTitleDisplayMode(.inline)
        .loadingOverlay(viewModel.isLoading, message: "Başvurunuz gönderiliyor…")
    }

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.step {
        case .name: NameStepView(viewModel: viewModel)
        case .email: EmailStepView(viewModel: viewModel)
        case .password: PasswordStepView(viewModel: viewModel)
        case .university: UniversityStepView(viewModel: viewModel)
        case .department: DepartmentStepView(viewModel: viewModel)
        case .document: DocumentStepView(viewModel: viewModel)
        }
    }
}
