import XCTest
@testable import Easy_Example

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testEasyLog() {
        log.print("hello print")
        log.debug("hello debug")
    }
    
    func testEasyApp() {
        log.print(app.isDebug)
        log.print(app.isBeta)
    }
    
    func testEasyAppScreen() {
        log.print(app.screenBounds)
        log.print(app.screenSize)
        log.print(app.screenWidth)
        log.print(app.screenHeight)
        log.print(app.screenScale)
    }
    
    func testEasyAppBundle() {
        log.print(app.bundleIdentifier)
        log.print(app.bundleVersion)
        log.print(app.bundleBuild)
        log.print(app.bundleName)
        log.print(app.bundleExecutable)
    }
    
    func testEasyApplication() {
        log.print(app.statusBarHeight)
        log.print(app.userDefaults)
        log.print(app.notificationCenter)
        log.print(app.delegate)
        log.print(app.keyWindow)
        log.print(app.window)
        log.print(app.rootViewController)
    }
    
    func testEasyCamera() {
        log.print(app.isCameraAvailableFront)
        log.print(app.isCameraAvailableRear)
    }
    
    func testEasyTime() {
        log.print(app.timestamp)
        log.print(app.timestampMillis)
    }
    
    func testEasyUUID() {
        log.print(app.randomUUID)
        log.print(app.randomLowercasedUUID)
        log.print(app.getKeychainUUID)
    }
    
}
