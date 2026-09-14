import FirebaseAuth
import Foundation

/// Maps thrown errors to user-facing Turkish copy without leaking raw
/// SDK/server error strings (which can contain internal details) to the UI.
enum AuthErrorPresenter {
    static func message(for error: Error) -> String {
        if let apiError = error as? APIError {
            switch apiError {
            case .unauthorized: return "E-posta veya şifre hatalı."
            case .forbidden: return "Bu işlem için yetkiniz yok."
            case .rateLimited: return "Çok fazla deneme yaptınız. Lütfen biraz sonra tekrar deneyin."
            case .transport: return "İnternet bağlantınızı kontrol edin."
            default: return "Bir şeyler ters gitti. Lütfen tekrar deneyin."
            }
        }

        let nsError = error as NSError
        if nsError.domain == AuthErrorDomain, let code = AuthErrorCode(rawValue: nsError.code) {
            switch code {
            case .invalidEmail: return "Geçersiz e-posta adresi."
            case .emailAlreadyInUse: return "Bu e-posta adresi zaten kullanılıyor."
            case .weakPassword: return "Şifre çok zayıf. En az 8 karakter kullanın."
            case .wrongPassword, .userNotFound, .invalidCredential: return "E-posta veya şifre hatalı."
            case .networkError: return "İnternet bağlantınızı kontrol edin."
            case .tooManyRequests: return "Çok fazla deneme yaptınız. Lütfen biraz sonra tekrar deneyin."
            default: return "Bir şeyler ters gitti. Lütfen tekrar deneyin."
            }
        }

        return "Bir şeyler ters gitti. Lütfen tekrar deneyin."
    }
}
