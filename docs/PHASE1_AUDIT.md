# PHASE 1 — Project Audit & Architecture Migration Plan

## 1. Repository audit

The repository attached to this task (`atillayedek/-os-master-setup-hub-ultimate-auto-installer`)
contains, at the start of this work:

- `README.md` — documentation for an unrelated project: a Kali/Ubuntu bash
  install-script generator (a single-page tool that lets a user pick packages
  and generates a `custom_install.sh`).
- `index.html` — the static single-page implementation of that tool.

There is **no existing KampüsAğı code in this repository** — no Swift/SwiftUI
project, no Android/Kotlin project, no backend, no Firebase config. The task
brief references "mevcut Android/Kotlin uygulaması" (an existing Android/Kotlin
app) and asks to analyze and preserve an existing project; no such project
exists here. A private repository, `atillayedek/kampusagi`, appears to be the
actual KampüsAğı project, but per explicit instruction this work proceeds
inside the currently attached repository instead.

**Decision:** treat KampüsAğı iOS as a greenfield SwiftUI build inside this
repository, under a new top-level directory `KampusAgi-iOS/`, so the existing
bash-installer tool (`index.html`, `README.md`) is left untouched and its
functionality is preserved exactly as-is.

## 2. Environment constraint

This sandbox is Linux-only: there is no `swift`, `xcodebuild`, or Xcode
installed, and no way to open or compile an `.xcodeproj`/`.xcworkspace` here.
Consequences for this work:

- The project is generated as source + an **XcodeGen** (`project.yml`) spec
  rather than a hand-authored `.xcodeproj`/`project.pbxproj` (hand-editing a
  pbxproj blind, with no compiler to validate it, is exactly the kind of
  unverifiable change that tends to produce a broken project file).
- All Swift code is written to compile against Swift 6 / iOS 17+ APIs based
  on documented signatures, but it has **not been compiled or run** in this
  session. First step for a developer picking this up on macOS: install
  XcodeGen (`brew install xcodegen`), run `xcodegen generate` inside
  `KampusAgi-iOS/`, open the generated `.xcodeproj`, resolve Swift Package
  dependencies (Firebase iOS SDK, GoogleSignIn-iOS), and build.
- No App Store Connect, Firebase Console, or Google Cloud access exists in
  this session, so account/project provisioning (bundle ID registration,
  Firebase project creation, StoreKit product configuration, TestFlight
  submission) cannot be executed here. Those steps are documented as an
  actionable checklist instead (`docs/APP_STORE_RELEASE_CHECKLIST.md`)
  rather than marked done.

## 3. Chosen architecture

Clean Architecture + MVVM, exactly as specified in the brief:

```
KampusAgi-iOS/KampusAgi/
├── App/            composition root: App entry, Router, Environment, DI container
├── Core/           cross-cutting: Networking, Security, DesignSystem, Utilities, Constants, Extensions
├── Domain/         Entities, Repository protocols, UseCases (no Firebase/UIKit imports)
├── Data/           Models/DTOs, Repository implementations, Remote (Firebase/API/Gemini), Local (SwiftData/Keychain)
└── Features/       one folder per feature: Views, ViewModels, Components (+ Services where needed)
```

Rules enforced while implementing:

- Views never call Firebase or network APIs directly — only through a
  ViewModel, which only knows Domain UseCase protocols.
- Domain layer has zero dependency on Firebase, UIKit, or networking types —
  it only defines protocols and plain entities, so it stays unit-testable
  with mocks and has no compiled dependency on FirebaseAuth etc.
- Authorization is never trusted from the client: `AccountStatus` gating in
  the app is a UX convenience: `RootGateView` steers `pendingReview` /
  `rejected` users away from the main app, but every real access decision
  (community scoping, post authorship, matchmaking, trust score) is
  documented as backend-authoritative in `docs/BACKEND_API_CONTRACT.md`,
  matching sections 10, 11, 20, 27, 49 of the brief.
- No secrets in the client: the Gemini API key never appears in iOS code,
  `Info.plist`, or build settings — AI processing is called through a
  backend endpoint (`docs/BACKEND_API_CONTRACT.md`), consistent with
  section 25.

## 4. Scope of this pass

Given the size of the full 65-section brief, this pass implements the two
modules the task explicitly asks for next — **Authentication** and
**Student Verification** — end-to-end on the client (Views, ViewModels,
UseCases, Repository protocols, one real repository implementation per
protocol, unit tests), plus the composition root and design system needed
to run them. Every other feature area (Matchmaking, Chat, Communities,
Subscriptions, Notifications, etc.) is intentionally **not stubbed with fake
UI** — per section 44's rule against placeholder backend responses and fake
completed features, only the folder structure and repository/use-case
seams for what's built now are included, so future phases have a clean
place to land without any screen claiming to be "done" when it isn't wired
to a real backend.

## 5. Backend dependency

Sections 2, 24–27, 52–53 describe a TypeScript/Firebase Cloud Functions +
PostgreSQL/pgvector backend. That backend is out of scope for an iOS-only
repository and is not implemented here. `docs/BACKEND_API_CONTRACT.md`
specifies the exact endpoints, request/response shapes, and authorization
rules the iOS client in this pass assumes, so backend work can proceed
against a fixed contract.
