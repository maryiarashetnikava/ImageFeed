import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false

        app.launch()
    }

    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText(" ")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        app.typeText(" ")
        sleep(1)
        webView.swipeUp()

        
        webView.tap()

        sleep(2)
        
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))

        loginButton.tap()
        sleep(5)
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 30))
        }
        
    func testFeed() throws {
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(3)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        sleep(2)
                
        cellToLike.buttons["like button off"].tap()
        sleep(2)
        
        cellToLike.buttons["like button on"].tap()
        sleep(2)
            
        cellToLike.tap()
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)

        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let backButton = app.buttons["back button"]
        backButton.tap()
        }
        
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
           
        XCTAssertTrue(app.staticTexts["Maria Reshetnikova"].exists)
        XCTAssertTrue(app.staticTexts["@maryreshetnikova"].exists)
            
        app.buttons["logout button"].tap()
            
        app.alerts["Goodbye!"].scrollViews.otherElements.buttons["Log Out"].tap()
        }

}
