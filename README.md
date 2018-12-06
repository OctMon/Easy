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

```

## Author

octmon, octmon@qq.com

## License

Easy is available under the MIT license. See the LICENSE file for more info.
