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

```swift
import Easy

typealias easy = Easy
typealias app = EasyApp
typealias log = EasyLog
typealias alert = EasyAlert
typealias actionSheet = EasyActionSheet
typealias global = EasyGlobal
typealias router = EasyRouter

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

```swift
log.print("hello print") // hello print

log.debug("hello debug")
// 2018-12-06 11:09:25.373 [debug] [Tests.swift:38] testEasyLog() > hello debug
```

### EasyApp

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
```

## Author

octmon, octmon@qq.com

## License

Easy is available under the MIT license. See the LICENSE file for more info.
