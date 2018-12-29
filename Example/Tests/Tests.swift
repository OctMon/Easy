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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testAppLog() {
        log.print("hello print")
        log.debug("hello debug")
    }
    
    func testApp() {
        log.print(app.isDebug)
        log.print(app.isBeta)
    }
    
    func testAppScreen() {
        log.print(app.screenBounds)
        log.print(app.screenSize)
        log.print(app.screenWidth)
        log.print(app.screenHeight)
        log.print(app.screenScale)
    }
    
    func testAppBundle() {
        log.print(app.bundleIdentifier)
        log.print(app.bundleVersion)
        log.print(app.bundleBuild)
        log.print(app.bundleName)
        log.print(app.bundleExecutable)
    }
    
    func testApplication() {
        log.print(app.statusBarHeight)
        log.print(app.userDefaults)
        log.print(app.notificationCenter)
        log.print(app.delegate)
        log.print(app.keyWindow)
        log.print(app.window)
        log.print(app.rootViewController)
    }
    
    func testAppCamera() {
        log.print(app.isCameraAvailableFront)
        log.print(app.isCameraAvailableRear)
    }
    
    func testAppTime() {
        log.print(app.timestamp)
        log.print(app.timestampMillis)
    }
    
    func testAppUUID() {
        log.print(app.randomUUID)
        log.print(app.randomLowercasedUUID)
        log.print(app.getKeychainUUID)
    }
    
    func testAppFirstLaunch() {
        log.print(app.isFirstLaunch)
        log.print(app.isFirstLaunchOfNewVersion)
        log.print(app.isFirstLaunchOfKey("test"))
    }
    
    func testAppCurrent() {
        log.print(app.currentViewController)
        log.print(app.currentNavigationController)
        log.print(app.currentTabBarController)
        log.print(app.telephonyCarrierName)
        log.print(app.isConnectedToNetwork)
    }
    
    func testAppPlayVibrate() {
        app.playVibrate()
    }
    
    func testAppOpen() {
        app.openSettings()
        app.canOpen("https://github.com/octmon/easy")
        app.open("https://github.com/octmon/easy")
        app.call("12345")
    }
    
    func testAppStore() {
        log.print(app.getAppStoreDetails(id: 414478124))
        app.openAppStoreDetails(id: 414478124)
        app.openAppStoreReviews(id: 414478124)
        app.openAppStoreWriteReview(id: 414478124)
    }
    
    func testAppRun() {
        app.runInMain(delay: 3) {
            
        }
        app.runInMain(handler: {
            
        })
        app.runInGlobal(qos: .background, delay: 2, handler: {
            
        })
        app.runInGlobal(handler: {
            
        })
        app.runLoop(seconds: 1, delay: 3, handler: { (time) in
            
        })
    }
    
    func testAppDefaults() {
        app.userDefaultsSet(with: ["app": "test"])
        log.print(app.userDefaultsGetValue(forKey: "app"))
        log.print(app.userDefaultsGetString(forKey: "app"))
    }
    
    func testAppPerformenceRun() {
        app.performenceRun(loopTimes: 999) {
            autoreleasepool(invoking: {
                var str = "Oct"
                str = str.lowercased()
                str += "Mon"
                log.debug(str)
            })
        }
    }
    
    func testAppOpenFullScreenPopGesture() {
        app.openFullScreenPopGesture()
    }
    
    func testTestTool() {
        app.configTestTool() // 配置调试工具
        app.configCheckPgyer(api_key: "#replace your api_key", shortcutUrl: "", headerImage: nil, delay: 3, isWillEnterForegroundCheck: true) // 配置Pgyer检测更新
    }
    
    func testAlert() {
        alert(title: "title", message: "message").addAction(title: "ok", style: .default, handler: { (_) in
            log.debug("ok")
        }).show()
        actionSheet(title: "title", message: "message").addAction(title: "ok", style: .default, handler: { (_) in
            log.debug("ok")
        }).addAction(title: "cancel").show()
    }
    
}
