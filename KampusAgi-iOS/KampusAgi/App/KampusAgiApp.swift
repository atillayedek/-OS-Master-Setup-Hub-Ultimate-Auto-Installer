import FirebaseAppCheck
import FirebaseCore
import GoogleSignIn
import SwiftUI

@main
struct KampusAgiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let container = AppDependencyContainer()

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // App Check must be configured before FirebaseApp.configure() so every
        // subsequent Firebase call (Auth included) is attested — §51.
        #if DEBUG
        AppCheck.setAppCheckProviderFactory(DebugAppCheckProviderFactory())
        #else
        AppCheck.setAppCheckProviderFactory(AppAttestProviderFactory())
        #endif

        FirebaseApp.configure()

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: AppEnvironment.current.googleSignInClientID)

        return true
    }
}

private final class DebugAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        AppCheckDebugProvider(app: app)
    }
}

private final class AppAttestProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        AppAttestProvider(app: app)
    }
}
