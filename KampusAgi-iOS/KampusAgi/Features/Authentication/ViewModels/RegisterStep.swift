/// Mirrors the fixed registration order from the brief:
/// Ad Soyad → Email → Şifre → Üniversite → Bölüm → Öğrenci Belgesi.
enum RegisterStep: Int, CaseIterable, Comparable {
    case name = 0
    case email
    case password
    case university
    case department
    case document

    static func < (lhs: RegisterStep, rhs: RegisterStep) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var title: String {
        switch self {
        case .name: return "Ad Soyad"
        case .email: return "E-posta"
        case .password: return "Şifre"
        case .university: return "Üniversite"
        case .department: return "Bölüm"
        case .document: return "Öğrenci Belgesi"
        }
    }
}
