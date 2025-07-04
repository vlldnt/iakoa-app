import XCTest

final class IAKOAUITests: XCTestCase {

    func testSplashScreenAppearsAndDisappears() {
        let app = XCUIApplication()
        app.launch()
        
        let splashLogo = app.images["SplashLogo"]
        
        // ✅ Le logo doit apparaître pendant 1 seconde
        XCTAssertTrue(splashLogo.waitForExistence(timeout: 1.5), "Le logo du splash screen doit apparaître.")
        
        // ✅ Ensuite, il doit disparaître au bout de 2 secondes
        sleep(3) // Attendre que SplashView disparaisse
        XCTAssertFalse(splashLogo.exists, "Le splash screen doit disparaître après quelques secondes.")
    }
}
