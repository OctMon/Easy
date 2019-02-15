//
//  EasyApp.swift
//  Easy
//
//  Created by OctMon on 2018/10/10.
//

import UIKit

public extension Easy {
    typealias App = EasyApp
}

public struct EasyApp {
    private init() {}
}

public extension EasyApp {
    
    #if DEBUG
    static let isDebug = true
    #else
    static let isDebug = false
    #endif
    
    #if BETA
    static let isBeta = true
    #else
    static let isBeta = false
    #endif
    
}

public extension EasyApp {
    
    static let screenBounds = UIScreen.main.bounds
    static let screenSize = UIScreen.main.bounds.size
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
    static let screenScale = UIScreen.main.scale
    
    static let bundleIdentifier = (Bundle.main.infoDictionary!["CFBundleIdentifier"] as? String) ?? ""
    static let bundleVersion = (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String) ?? ""
    static let bundleBuild = (Bundle.main.infoDictionary!["CFBundleVersion"] as? String) ?? ""
    static var bundleName: String {
        if let name = Bundle.main.infoDictionary!["CFBundleDisplayName"] as? String { return name }
        return Bundle.main.infoDictionary!["CFBundleName"] as? String ?? ""
    }
    static let bundleExecutable = Bundle.main.infoDictionary!["CFBundleExecutable"] as? String ?? ""
    
    static let statusBarHeight = UIApplication.shared.statusBarFrame.height
    
    static let userDefaults = UserDefaults.standard
    static let notificationCenter = NotificationCenter.default
    
    static let delegate = UIApplication.shared.delegate
    static var keyWindow: UIWindow? { return UIApplication.shared.keyWindow }
    static var window: UIWindow? { return delegate?.window ?? nil }
    static var rootViewController: UIViewController? { return window?.rootViewController }
    
    static let isCameraAvailableFront = UIImagePickerController.isCameraDeviceAvailable(.front)
    static let isCameraAvailableRear = UIImagePickerController.isCameraDeviceAvailable(.rear)
    
    static var timestamp: Int { return Date().timeIntervalSince1970.toInt }
    static var timestampMillis: Int { return ((Date().timeIntervalSince1970) * 1000).toInt }
    
    static var randomUUID: String { return UUID().uuidString }
    static var randomLowercasedUUID: String { return randomUUID.lowercased() }
    static let getKeychainUUID: String = EasyKeychain.getUUID(service: "EasyKeychain") ?? ""
    
}

public extension EasyApp {
    
    /// 应用第一次启动
    static let isFirstLaunch: Bool = {
        let fistLaunched = EasyApp.bundleIdentifier + "isFistLaunched"
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: fistLaunched)
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: fistLaunched)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }()
    
    /// 当前版本第一次启动
    static let isFirstLaunchOfNewVersion: Bool = {
        let majorVersion = EasyApp.bundleVersion
        let fistLaunchedOfNewVersion = EasyApp.bundleIdentifier + "isFistLaunchedOfNewVersion"
        let lastLaunchVersion = UserDefaults.standard.string(forKey:
            fistLaunchedOfNewVersion)
        let isFirstLaunchOfNewVersion = majorVersion != lastLaunchVersion
        if isFirstLaunchOfNewVersion {
            UserDefaults.standard.set(majorVersion, forKey: fistLaunchedOfNewVersion)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunchOfNewVersion
    }()
    
    /// key第一次标记
    static func isFirstLaunchOfKey(_ key: String) -> Bool {
        let fistLaunched = key
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: fistLaunched)
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: fistLaunched)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }
    
}

public extension EasyApp {
    
    static var currentViewController: UIViewController? {
        var top = UIApplication.shared.keyWindow?.rootViewController
        if top?.presentedViewController != nil {
            top = top?.presentedViewController
        } else if top?.isKind(of: UITabBarController.self) == true {
            top = (top as! UITabBarController).selectedViewController
            if (top?.isKind(of: UINavigationController.self) == true) && (top as! UINavigationController).topViewController != nil {
                top = (top as! UINavigationController).topViewController
            }
        } else if (top?.isKind(of: UINavigationController.self) == true) && (top as! UINavigationController).topViewController != nil {
            top = (top as! UINavigationController).topViewController
        }
        return top
    }
    
    static var currentNavigationController: UINavigationController? {
        if let current = currentViewController {
            return current.navigationController
        }
        return nil
    }
    
    static var currentTabBarController: UITabBarController? {
        if let top = UIApplication.shared.keyWindow?.rootViewController, top.isKind(of: UITabBarController.self) == true {
            return top as? UITabBarController
        }
        return nil
    }
    
}

#if canImport(CoreTelephony)
import CoreTelephony
public extension EasyApp {
    static let telephonyCarrierName = CTTelephonyNetworkInfo().subscriberCellularProvider?.carrierName ?? ""
}
#endif

#if canImport(SystemConfiguration)
import SystemConfiguration
public extension EasyApp {
    static var isConnectedToNetwork: Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if let defaultRouteReachability = defaultRouteReachability, !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
}
#endif

#if canImport(AudioToolbox)
import AudioToolbox
public extension EasyApp {
    static func playVibrate() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}
#endif

public extension EasyApp {
    
    @discardableResult
    static func openSettings() -> Bool {
        return open(UIApplication.openSettingsURLString)
    }
    
    @discardableResult
    static func canOpen(_ urlString: String) -> Bool {
        if let url = URL(string: urlString) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    @discardableResult
    static func open(_ urlString: String) -> Bool {
        if let url = URL(string: urlString) {
            return UIApplication.shared.openURL(url)
        }
        return false
    }
    
    @discardableResult
    static func call(_ telephone: String) -> Bool {
        guard telephone.count > 0 else {
            return false
        }
        return open("telprompt:\(telephone)")
    }
    
    static func getAppStoreDetails(id: Int) -> String {
        return "itms-apps://itunes.apple.com/app/id\(id)"
    }
    
    @discardableResult
    static func openAppStoreDetails(id: Int) -> Bool {
        return open(getAppStoreDetails(id: id))
    }
    
    @discardableResult
    static func openAppStoreWriteReview(id: Int) -> Bool {
        return open(getAppStoreDetails(id: id) + "?action=write-review")
    }
    
    @discardableResult
    static func openAppStoreReviews(id: Int) -> Bool {
        return open("itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=\(id)")
    }
    
}

public extension EasyApp {
    
    static func runInMain(delay: TimeInterval = 0, handler: @escaping () -> Void) {
        if delay <= 0 {
            DispatchQueue.main.async(execute: handler)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: handler)
        }
    }
    
    static func runInGlobal(qos: DispatchQoS.QoSClass = .default, delay: TimeInterval = 0, handler: @escaping () -> Void) {
        if delay <= 0 {
            DispatchQueue.global(qos: qos).async(execute: handler)
        } else {
            DispatchQueue.global(qos: qos).asyncAfter(deadline: .now() + delay, execute: handler)
        }
    }
    
    @discardableResult
    static func runLoop(seconds: TimeInterval, delay: TimeInterval = 0, handler: @escaping (Timer?) -> Void) -> Timer? {
        let fireDate = CFAbsoluteTimeGetCurrent() + delay
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, seconds, 0, 0, handler)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, CFRunLoopMode.defaultMode)
        return timer
    }
    
}

public extension EasyApp {
    
    /**
     ```
     EasyLog.debug(Easy.userDefaultsGetValue(forKey: "user")) // Optional({ a = 1; b = B; })
     ```
     */
    static func userDefaultsGetValue(forKey: String) -> Any? {
        return userDefaults.object(forKey: forKey)
    }
    
    /***
     ```
     EasyLog.debug(Easy.userDefaultsGetString(forKey: "name")) // Optional(octmon)
     ```
     */
    static func userDefaultsGetString(forKey: String) -> String? {
        return userDefaultsGetValue(forKey: forKey) as? String
    }
    
    /**
     ```
     Easy.userDefaultsSet(with: ["name": "octmon", "user": ["a": 1, "b": "B"]])
     ```
     */
    @discardableResult
    static func userDefaultsSet(with keyValues: [String: Any?]) -> Bool {
        keyValues.forEach {
            userDefaults.setValue($0.value, forKey: $0.key)
        }
        return userDefaults.synchronize()
    }
    
}

public extension EasyApp {
    
    static func randomString(length: Int) -> String {
        guard length > 0 else { return "" }
        let base = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789"
        var randomString = ""
        for _ in 1 ... length {
            if let randomCharacter = base.randomElement() {
                randomString.append(randomCharacter)
            }
        }
        return randomString
    }
    
    /// 计算运行所需耗时
    static func performenceRun(loopTimes: Int = 1, testFunc: ()->()) {
        let start = CFAbsoluteTimeGetCurrent()
        for _ in 0...loopTimes {
            testFunc()
        }
        let end = CFAbsoluteTimeGetCurrent()
        EasyLog.debug("运行 \(loopTimes) 次，耗时 \(end - start)s")
    }
    
}

public extension EasyApp {
    
    static func openFullScreenPopGesture() {
        EasyFullScreenPopGesture.open()
    }
    
}

public extension EasyApp {
    
    static func configCheckPgyer(api_key: String , shortcutUrl: String, headerImage: UIImage? = nil, delay: TimeInterval = 3, isWillEnterForegroundCheck: Bool = true) {
        #if BETA
        EasyCheck.configPgyerBeta(api_key: api_key, shortcutUrl: shortcutUrl, headerImage: headerImage, delay: delay, isWillEnterForegroundCheck: isWillEnterForegroundCheck)
        #endif
    }
    
    static func configTestTool() {
        #if BETA
        EasyBeta.configTestTool()
        #endif
    }
    
}

public extension EasyApp {
    
    static func showAlert(image: UIImage? = nil, title: NSAttributedString, message: NSAttributedString?, buttonTitles: [NSAttributedString?], buttonBackgroundImages: [UIImage?], backgroundCornerRadius: CGFloat = 5, tap: @escaping (Int) -> Void) {
        let backgroundView = UIView()
        let popupView = EasyPopupView(backgroundView, transition: .fade).then {
            $0.dismissOnBlackOverlayTap = false
            $0.animationDuration = 0
        }
        backgroundView.do {
            let alertView = UIView().then {
                $0.backgroundColor = .white
                $0.setCornerRadius(backgroundCornerRadius)
            }
            $0.addSubview(alertView)
            alertView.snp.makeConstraints { (make) in
                make.top.equalTo(52)
                make.left.right.equalToSuperview()
                make.bottom.equalTo(-30)
            }
            let iconImageView = UIImageView(image: image)
            $0.addSubview(iconImageView)
            iconImageView.snp.makeConstraints({ (make) in
                make.top.equalToSuperview()
                make.centerX.equalToSuperview()
            })
            alertView.addBottomButton(titles: buttonTitles, height: 52, backgroundImages: buttonBackgroundImages, bottomMargin: 0) { [weak popupView] (offset) in
                tap(offset)
                popupView?.dismiss()
            }
            let titleLabel = UILabel().then {
                $0.attributedText = title
                $0.textAlignment = .center
                $0.adjustsFontSizeToFitWidth = true
            }
            alertView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints({ (make) in
                if image != nil {
                    make.top.equalTo(iconImageView.snp.bottom).offset(15)
                } else {
                    make.top.equalTo(15)
                }
                if message == nil {
                    make.bottom.equalTo(-70)
                }
                make.left.equalTo(15)
                make.right.equalTo(-15)
            })
            if message != nil {
                let messageTextView = UITextView().then {
                    $0.attributedText = message
                    $0.isSelectable = false
                    $0.isEditable = false
                }
                alertView.addSubview(messageTextView)
                messageTextView.snp.makeConstraints({ (make) in
                    make.top.equalTo(titleLabel.snp.bottom).offset(10)
                    make.bottom.equalTo(-60)
                    make.left.equalTo(22)
                    make.right.equalTo(-22)
                    make.height.equalTo((message?.getSize(forConstrainedSize: CGSize(width: .screenWidth - 40 * 2 - 22 * 2, height: .screenHeight / 2)).height ?? 0) + 44)
                })
            }
        }
        backgroundView.snp.makeConstraints { (make) in
            make.left.equalTo(40)
            make.right.equalTo(-40)
            make.center.equalToSuperview()
            make.height.lessThanOrEqualTo(EasyApp.screenHeight - 40)
        }
        popupView.showWithCenter()
    }
    
}
