# Easy

[![CI Status](https://img.shields.io/travis/OctMon/Easy.svg?style=flat)](https://travis-ci.org/OctMon/Easy)
[![Version](https://img.shields.io/cocoapods/v/Easy.svg?style=flat)](https://cocoapods.org/pods/Easy)
[![License](https://img.shields.io/cocoapods/l/Easy.svg?style=flat)](https://cocoapods.org/pods/Easy)
[![Platform](https://img.shields.io/cocoapods/p/Easy.svg?style=flat)](https://cocoapods.org/pods/Easy)

## Requirements
+ iOS 9.0+
+ Xcode 10.0+
+ Swift 4.2

## Installation

Easy is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Easy'
```

## Example

### To run the example project, clone the repo.

#### import Easy
#### typealias easy = Easy

```swift
import Easy

typealias easy = Easy
typealias app = easy.App
typealias log = easy.Log
typealias alert = easy.Alert
typealias actionSheet = easy.ActionSheet
typealias global = easy.Global
typealias router = easy.Router

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configGlobal()
        window = easy.NavigationController(rootViewController: Main()).makeRootViewController()
        config(application, launchOptions: launchOptions)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return easy.Social.handleOpenURLSocial(open: url)
    }


}
```

### EasyLog

#### typealias log = easy.Log
```swift
log.print("hello print") // hello print

log.debug("hello debug") // 2018-12-06 11:09:25.373 [debug] [Tests.swift:38] testEasyLog() > hello debug
```

### EasyApp

#### typealias app = easy.App
```swift
log.print(app.isDebug) // true
log.print(app.isBeta) // false

log.print(app.screenBounds) // (0.0, 0.0, 414.0, 736.0)
log.print(app.screenSize) // (414.0, 736.0)
log.print(app.screenWidth) // 414.0
log.print(app.screenHeight) // 736.0
log.print(app.screenScale) // 3.0

log.print(app.statusBarHeight) // 20.0
log.print(app.userDefaults) // <NSUserDefaults: 0x6000029c1380>
log.print(app.notificationCenter) // <CFNotificationCenter 0x6000003c4720 [0x10f4a5b68]
log.print(app.delegate) // Optional(<Easy_Example.AppDelegate: 0x600000f9ca00>)
log.print(app.keyWindow) // Optional(<UIWindow: 0x7fd487701540; frame = (0 0; 414 736); gestureRecognizers = <NSArray: 0x6000001c5b30>; layer = <UIWindowLayer: 0x600000fd8300>>)
log.print(app.window) // Optional(<UIWindow: 0x7fd487701540; frame = (0 0; 414 736); gestureRecognizers = <NSArray: 0x6000001c5b30>; layer = <UIWindowLayer: 0x600000fd8300>>)
log.print(app.rootViewController // Optional(<Easy.EasyNavigationController: 0x7fd48886f000>)

log.print(app.isCameraAvailableFront) // true
log.print(app.isCameraAvailableRear) // true

log.print(app.timestamp) // 1544232815
log.print(app.timestampMillis) // 1544232815518

log.print(app.randomUUID) // 90F67FF1-58B0-492E-9A98-9DC019BCB43C
log.print(app.randomLowercasedUUID) // 65a1273a-7889-4854-bddb-939f0089e88e
log.print(app.getKeychainUUID) // D262661F-06C8-4B45-B3FC-1878DCB65456

log.print(app.isFirstLaunch) // true
log.print(app.isFirstLaunchOfNewVersion) // true
log.print(app.isFirstLaunchOfKey("test")) // true

log.print(app.currentViewController) // Optional(<RTContainerController: 0x7fded3d0d770 contentViewController: <Easy_Example.Main: 0x7fded3d03e90>>)
log.print(app.currentNavigationController) // Optional(<Easy.EasyNavigationController: 0x7fded4832e00>)
log.print(app.currentTabBarController) // nil
log.print(app.telephonyCarrierName) //  中国联通
log.print(app.isConnectedToNetwork) // true

app.playVibrate()

app.openSettings()
app.canOpen("https://github.com/octmon/easy")
app.open("https://github.com/octmon/easy")
app.call("12345")

log.print(app.getAppStoreDetails(id: 414478124)) // itms-apps://itunes.apple.com/app/id414478124
app.openAppStoreDetails(id: 414478124)
app.openAppStoreReviews(id: 414478124)
app.openAppStoreWriteReview(id: 414478124)

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

app.userDefaultsSet(with: ["app": "test"])
log.print(app.userDefaultsGetValue(forKey: "app")) // Optional(test)
log.print(app.userDefaultsGetString(forKey: "app")) // Optional("test")

app.performenceRun(loopTimes: 999) {
    autoreleasepool(invoking: {
        var str = "Oct"
        str = str.lowercased()
        str += "Mon"
        log.debug(str)
    })
} // 运行 999 次，耗时 5.197448015213013s

log.debug(app.isPhone) // false
log.debug(app.isPad) // false
log.debug(app.isPod) // false
log.debug(app.isSimulator) // true
log.debug(app.isFaceIDCapableDevices) // false
log.debug(app.safeBottomEdge) // false

log.debug(app.aboutName) // iPhone 8 Plus
log.debug(app.systemName) // iOS
log.debug(app.systemVersion) // 12.1
log.debug(app.batteryLevel) // -1.0
log.debug(app.deviceMachine) // x86_64
log.debug(app.deviceModel) // simulator
log.debug(app.deviceType) // simulator
log.debug(app.deviceSize) // screen5_5Inch

app.openFullScreenPopGesture() // 打开全屏返回手势

app.configTestTool() // 配置调试工具
app.configCheckPgyer(api_key: "#replace your api_key", shortcutUrl: "", headerImage: nil, delay: 3, isWillEnterForegroundCheck: true) // 配置Pgyer检测更新
```

##### app.showUpdateAlert

<img src="https://github.com/OctMon/Easy/blob/assets/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202018-12-28%20at%2010.22.79.png?raw=true" width="200" align=left />
<img src="https://github.com/OctMon/Easy/blob/assets/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202018-12-28%20at%2010.23.04.png?raw=true" width="200" align=center />

```swift
let isForceUpdate = Int.random(in: 0...1) == 0

var buttonTitles = ["立即升级".getAttributedString(font: .size15, foregroundColor: UIColor.white)]
var buttonBackgroundImages = [UIColor.red.toImage]
if !isForceUpdate {
    buttonTitles.insert("稍后再说".getAttributedString(font: .size15, foregroundColor: .hex666666), at: 0)
    buttonBackgroundImages.insert(UIColor.white.toImage, at: 0)
}
app.showUpdateAlert(image: nil, title: "发现新版本".getAttributedString(font: .size21, foregroundColor: .hex333333).append(title: "  v6.7.3", font: .size12, foregroundColor: .hex999999), message: """
    本次更新：
    - 可以拍一个自己的表情
    - 聊天输入文字时可以长按换行
    
    最近更新：
    - 可以使用英语和粤语进行语音输入了
    - 可以直接浏览订阅号的消息
    - 可以把浏览的文章缩小为浮窗
    """.getAttributedString(font: .size14, foregroundColor: .hex999999, lineSpacing: 8), buttonTitles: buttonTitles, buttonBackgroundImages: buttonBackgroundImages, tap: { offset in
        if isForceUpdate || offset == 1 {
            app.openAppStoreDetails(id: 414478124)
            log.debug("Force update")
        } else {
            log.debug("Say later")
        }
})
```

### EasyAlert

#### typealias alert = easy.Alert
#### typealias actionSheet = easy.ActionSheet

```swift
alert(title: "title", message: "message").addAction(title: "ok", style: .default, handler: { (_) in
    log.debug("ok")
}).show()

actionSheet(title: "title", message: "message").addAction(title: "ok", style: .default, handler: { (_) in
    log.debug("ok")
}).addAction(title: "cancel").show()
```

## Author

octmon, octmon@qq.com

## License

Easy is available under the MIT license. See the LICENSE file for more info.
