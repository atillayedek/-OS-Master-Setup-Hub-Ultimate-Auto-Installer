import SwiftUI

/// §10, §11 — the client-side gate: a pending/rejected/suspended user only
/// ever sees a verification-status screen, never the main app surface. This
/// is a UX convenience only — the backend independently refuses any
/// community/matchmaking/chat request from a non-approved account (see
/// docs/BACKEND_API_CONTRACT.md), so this view is not the security boundary.
struct RootGateView: View {
    let user: User
    let onSignedOut: () -> Void

    /// Built once via `@State` (not inline in `body`) so it survives
    /// `RootGateView` being reconstructed by its parent on every unrelated
    /// re-render — recreating it on each `body` evaluation would silently
    /// drop in-flight `isLoading`/`errorMessage` state.
    @State private var verificationViewModel: StudentVerificationViewModel

    init(container: AppDependencyContainer, user: User, onSignedOut: @escaping () -> Void, onStatusChanged: @escaping (User) -> Void) {
        self.user = user
        self.onSignedOut = onSignedOut
        _verificationViewModel = State(initialValue: container.makeStudentVerificationViewModel(
            user: user,
            onStatusChanged: { status in
                onStatusChanged(Self.applying(status, to: user))
            }
        ))
    }

    var body: some View {
        NavigationStack {
            Group {
                switch user.accountStatus {
                case .pendingDocument, .pendingReview:
                    PendingReviewView(viewModel: verificationViewModel)
                case .rejected:
                    RejectedView(viewModel: verificationViewModel)
                case .approved:
                    HomePlaceholderView(user: user, onSignOut: onSignedOut)
                case .suspended:
                    AccountBlockedView(
                        title: "Hesabınız Askıya Alındı",
                        message: "Hesabınız topluluk kurallarını ihlal nedeniyle askıya alınmıştır.",
                        onSignOut: onSignedOut
                    )
                case .deleted:
                    AccountBlockedView(
                        title: "Hesap Bulunamadı",
                        message: "Bu hesap silinmiş görünüyor.",
                        onSignOut: onSignedOut
                    )
                }
            }
        }
    }

    private static func applying(_ status: VerificationStatus, to user: User) -> User {
        User(
            id: user.id,
            email: user.email,
            fullName: user.fullName,
            accountStatus: status.accountStatus,
            universityId: user.universityId,
            department: user.department,
            rejectionReason: status.rejectionReason
        )
    }
}
