# KampüsAğı — iOS

Native SwiftUI client for KampüsAğı (CampusNetwork), a student social-need
matching platform. Swift 6, SwiftUI, iOS 17+, MVVM + Clean Architecture.

See `../docs/PHASE1_AUDIT.md` for the audit that led to this structure and
`../docs/BACKEND_API_CONTRACT.md` for the backend contract this client
assumes. This directory was generated and edited in a Linux sandbox with no
Xcode/Swift toolchain — **it has not been compiled**. Follow the steps below
on macOS to generate, build, and run it.

## Prerequisites

- macOS with Xcode 16+ (Swift 6 toolchain, iOS 17 SDK)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`
- A Firebase project per environment (dev/staging/prod) with iOS apps
  registered under bundle ID `com.kampusagi.app`
- A backend implementing `../docs/BACKEND_API_CONTRACT.md`

## First-time setup

```bash
cd KampusAgi-iOS
xcodegen generate                 # creates KampusAgi.xcodeproj — never commit it, it's git-ignored
open KampusAgi.xcodeproj
```

In Xcode, resolve Swift Package dependencies (Firebase iOS SDK, GoogleSignIn-iOS)
when prompted.

Then, per environment you intend to build:

1. Download the real `GoogleService-Info.plist` from that Firebase project's
   console and place it at `KampusAgi/Resources/GoogleService-Info.plist`
   (see `GoogleService-Info.plist.template` for the expected shape — the
   real file is git-ignored and must never be committed).
2. Fill in `Configs/<Environment>.xcconfig` with the real
   `GOOGLE_SIGN_IN_CLIENT_ID` / `GOOGLE_SIGN_IN_URL_SCHEME` (the *reversed*
   client ID) from that Firebase/Google Cloud project.
3. Select the matching scheme — `KampusAgi-Development`,
   `KampusAgi-Staging`, or `KampusAgi-Production` — and run.

The Gemini API key is **never** placed in any of these files: it lives only
on the backend, which the app calls through `API_BASE_URL`.

## Project layout

```
KampusAgi/
├── App/          composition root (entry point, router, environment, DI container)
├── Core/         networking, security (Keychain), design system, utilities, constants
├── Domain/       entities + repository protocols + use cases (no Firebase/UIKit imports)
├── Data/         DTOs + repository implementations (Firebase, REST API), SwiftData, Keychain
├── Features/     one folder per feature (Authentication, StudentVerification, Home, ...)
└── Resources/    Info.plist, entitlements, asset catalog, localization
```

## What's implemented in this pass

- **Authentication**: email/password, Sign in with Apple, Google Sign-In,
  password reset, session restore, sign out — behind an
  `AuthenticationRepository` protocol with a Firebase-backed implementation.
- **Student Verification**: university picker (backend-sourced, not a
  hardcoded UI list per section 17), free-text department field, PDF-only
  document picker with magic-byte + size validation, help sheet explaining
  how to obtain the document, pending-review / rejected screens driven by
  `AccountStatus`.
- Composition root wiring all of the above with protocol-based dependency
  injection (no singletons reached into from Views).
- Unit tests for the ViewModels and the PDF validation service using mock
  repositories (no live Firebase/network dependency in `KampusAgiTests`).

Everything else in the full product brief (Communities, Matchmaking, Chat,
Notifications, Subscriptions/StoreKit, AdMob, etc.) is deliberately left out
of this pass rather than stubbed with placeholder UI — see
`../docs/PHASE1_AUDIT.md` §4 for why.

## Running tests

```bash
xcodegen generate
xcodebuild test -project KampusAgi.xcodeproj -scheme KampusAgi-Development \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

(Not run in this session — no macOS/Xcode available here. Run this on
macOS before merging.)
