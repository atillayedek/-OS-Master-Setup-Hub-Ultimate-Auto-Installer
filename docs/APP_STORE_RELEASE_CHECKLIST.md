# App Store Release Checklist — KampüsAğı iOS

Status: **not started** — no App Store Connect, Apple Developer, or Firebase
Console access exists in the session that produced this repository content.
This is an actionable checklist for whoever has that access, not a record of
completed work (see brief §44: never mark a feature done without the real
integration behind it).

## Prerequisites

- [ ] Apple Developer Program membership (org or individual) active
- [ ] App ID `com.kampusagi.app` registered in the Apple Developer portal
      with capabilities: Sign in with Apple, Push Notifications, App Groups
      (if used later for widgets/share extension)
- [ ] Three Firebase projects created (kampusagi-dev / -staging / -prod),
      each with an iOS app registered under the same bundle ID, and their
      real `GoogleService-Info.plist` downloaded (see `KampusAgi-iOS/README.md`)
- [ ] A Google Cloud OAuth client ID configured for Google Sign-In per
      environment, filled into `Configs/*.xcconfig`
- [ ] Backend implementing `docs/BACKEND_API_CONTRACT.md` deployed and
      reachable at the `API_BASE_URL` in each xcconfig

## Build & verify locally (macOS, not done in this sandbox)

- [ ] `xcodegen generate` succeeds
- [ ] Project builds for `KampusAgi-Development` on a simulator
- [ ] `xcodebuild test` passes for `KampusAgiTests` (unit tests in this repo:
      PDF validation, Login/Register/StudentVerification view models)
- [ ] Manual pass on a real device: register → upload a real PDF student
      document → see Pending Review → (backend) approve → relaunch → see
      Home placeholder; and the reject → resubmit path
- [ ] VoiceOver pass on the registration flow and verification screens
- [ ] Dynamic Type at the largest accessibility size doesn't clip any of the
      screens built in this pass
- [ ] Dark Mode pass (brand colors defined for both appearances already, in
      `Assets.xcassets`)

## App Store Connect setup

- [ ] App record created for `com.kampusagi.app`
- [ ] Privacy Policy URL and Terms of Service URL published and linked
- [ ] Privacy "Nutrition Label" (data collection disclosure) filled in
      accurately once Analytics/AdMob/Location features are actually built —
      do not fill this in for features that don't exist yet
- [ ] Sign in with Apple entitlement present in the archived build (already
      configured in `project.yml`'s `entitlements` block)
- [ ] Age rating questionnaire completed
- [ ] Export compliance: `ITSAppUsesNonExemptEncryption = false` is already
      set in `project.yml` (standard HTTPS/Firebase usage only) — revisit if
      custom cryptography is ever added
- [ ] App icon: replace the placeholder `AppIcon.appiconset` (currently has
      no actual image asset) with real 1024×1024 artwork before archiving —
      an archive will fail App Store validation without it
- [ ] Screenshots for required device sizes (this pass has no App Store-ready
      screens beyond auth/verification — revisit once Home/Communities exist)

## TestFlight

- [ ] Internal testing group added, build uploaded via Xcode Organizer or
      `xcodebuild -exportArchive`
- [ ] Build passes automated App Store review checks (no crash on launch,
      no placeholder/Lorem Ipsum content — this pass's copy is real Turkish
      product copy, not lorem ipsum)
- [ ] External testing group only after Communities/Matchmaking/Chat exist —
      the app is not yet a coherent product to test end-to-end beyond
      registration and verification

## Submission blockers specific to what's NOT built yet

Do not submit for review until these are real (per brief §44, no fake
completed features):
- Communities, Matchmaking, Chat — core value proposition, currently absent
- StoreKit 2 subscription flow with backend receipt verification
- AdMob + ATT consent flow for free-tier users
- Account deletion flow (§47) — required by App Store Guideline 5.1.1(v)
  whenever account creation exists in the app, which it now does
- Push notification permission request tied to a meaningful moment (§32),
  not implemented yet

Account deletion in particular is an App Store hard requirement once
in-app account creation exists (which this pass adds) — treat it as the
next must-have, not a nice-to-have, once Home/Settings are built.
