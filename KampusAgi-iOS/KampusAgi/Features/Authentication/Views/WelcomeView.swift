import SwiftUI

struct WelcomeView: View {
    let container: AppDependencyContainer
    let onAuthenticated: (User) -> Void

    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: Spacing.xl) {
                Spacer()

                VStack(spacing: Spacing.sm) {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Color.brandPrimary)
                    Text("KampüsAğı")
                        .font(.kaLargeTitle)
                    Text("Kampüsündeki öğrencilerle ihtiyaçlarını eşleştir.")
                        .font(.kaSubheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                VStack(spacing: Spacing.sm) {
                    NavigationLink(value: AuthRoute.login) {
                        Text("Giriş Yap")
                    }
                    .buttonStyle(.kaPrimary())

                    NavigationLink(value: AuthRoute.register) {
                        Text("Kayıt Ol")
                    }
                    .buttonStyle(.kaSecondary)
                }
            }
            .padding(Spacing.lg)
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .login:
                    LoginView(container: container, onSignedIn: onAuthenticated) {
                        path.append(AuthRoute.forgotPassword)
                    }
                case .register:
                    RegisterView(container: container, onRegistered: onAuthenticated)
                case .forgotPassword:
                    ForgotPasswordView(container: container)
                }
            }
        }
    }
}

enum AuthRoute: Hashable {
    case login
    case register
    case forgotPassword
}
