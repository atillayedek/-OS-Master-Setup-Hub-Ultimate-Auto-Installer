import XCTest

/// Smoke test for the unauthenticated entry flow. Needs a running backend +
/// Firebase project reachable from the simulator (or a launch-argument-driven
/// fake backend) to go further than the Welcome screen — not configured in
/// this pass, so this only asserts the app launches and shows the expected
/// entry points (§57 baseline).
final class AuthenticationFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testWelcomeScreenShowsLoginAndRegisterActions() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["KampüsAğı"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Giriş Yap"].exists)
        XCTAssertTrue(app.buttons["Kayıt Ol"].exists)
    }
}
