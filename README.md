# Easy

[![CI Status](https://img.shields.io/travis/octmon/Easy.svg?style=flat)](https://travis-ci.org/octmon/Easy)
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

### To run the example project, clone the repo, and run `pod install` from the Example directory first.

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

## Author

octmon, octmon@qq.com

## License

Easy is available under the MIT license. See the LICENSE file for more info.
