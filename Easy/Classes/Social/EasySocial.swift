//
//  EasySocial.swift
//  Easy
//
//  Created by OctMon on 2018/10/10.
//

import UIKit
import MonkeyKing

public extension Easy {
    typealias Social = EasySocial
}

public class EasySocial: NSObject {
    
    public struct SharePlatform {
        
        var type: SharePlatformType
        var name: String
        var image: UIImage?
        
        public init(type: SharePlatformType) {
            self.type = type
            self.name = type.name
            self.image = type.image
        }
        
        public init(type: SharePlatformType, image: UIImage) {
            self.type = type
            self.name = type.name
            self.image = image
        }
        
        public init(type: SharePlatformType, name: String, image: UIImage) {
            self.type = type
            self.name = name
            self.image = image
        }
        
    }
    
    public enum OauthPlatformType: Int {
        case wechat, qq, weibo
    }
    
    public enum SharePlatformType: Int {
        case wechat
        case wechatTimeline
        case wechatFavorite
        case qq
        case qqZone
        case weibo
        
        var name: String {
            switch self {
            case .wechat:
                return "微信"
            case .wechatTimeline:
                return "微信朋友圈"
            case .wechatFavorite:
                return "微信收藏"
            case .qq:
                return "QQ"
            case .qqZone:
                return "QQ空间"
            case .weibo:
                return "新浪微博"
            }
        }
        
        var image: UIImage? {
            switch self {
            case .wechat:
                return EasySocial.imageName("wechat")
            case .wechatTimeline:
                return EasySocial.imageName("wechat_timeline")
            case .wechatFavorite:
                return EasySocial.imageName("wechat_favorite")
            case .qq:
                return EasySocial.imageName("qq")
            case .qqZone:
                return EasySocial.imageName("qzone")
            case .weibo:
                return EasySocial.imageName("sina")
            }
        }
    }
    
    private var sharePlatforms = [SharePlatform]()
    
    private static var shared = EasySocial()
    
    private var qqAppId = ""
    
    private override init() {
        sharePlatforms = [SharePlatform(type: .wechat), SharePlatform(type: .wechatTimeline), SharePlatform(type: .qq), SharePlatform(type: .qqZone)]
    }
    
    private static func imageName(_ name: String) -> UIImage? {
        return UIImage(for: EasySocial.self, forResource: EasySocial.toString, forImage: "easy_" + name)
    }
    
    private static func filterPlatformsItems() {
        shared.sharePlatforms.enumerated().forEach { (offset, platform) in
            if !EasySocial.isAppInstalledWeChat {
                if platform.type == .wechat || platform.type == .wechatTimeline || platform.type == .wechatFavorite {
                    shared.sharePlatforms.removeFirst()
                }
            }
            if !EasySocial.isAppInstalledQQ {
                if platform.type == .qq || platform.type == .qqZone {
                    shared.sharePlatforms.removeFirst()
                }
            }
            if !EasySocial.isAppInstalledWeibo{
                if platform.type == .weibo {
                    shared.sharePlatforms.removeFirst()
                }
            }
        }
    }
    
}

extension EasySocial {
    
    public struct UserInfo {
        public let openid: String
        public let nickname: String
        public let iconurl: String
        public let sex: String
    }
    
}

private class EasyVerticalButton: UIButton {
    
    var imageSize = CGSize(width: 60, height: 60)
    private var space: CGFloat = 5
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        
        imageView?.contentMode = .scaleAspectFit
        titleLabel?.font = UIFont.systemFont(ofSize: 12)
        titleLabel?.textAlignment = .center
        setTitleColor(UIColor.black, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        return CGRect(x: 0, y: self.frame.size.height - imageSize.height * 0.5 + space, width: contentRect.size.width, height: imageSize.height * 0.5 - space)
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        return CGRect(x: self.frame.size.width / 2 - imageSize.height * 0.5, y: space, width: imageSize.width, height: imageSize.height)
    }
    
}

public extension EasySocial {
    
    static var isAppInstalledWeChat: Bool {
        return MonkeyKing.SupportedPlatform.weChat.isAppInstalled
    }
    
    static var isAppInstalledQQ: Bool {
        return MonkeyKing.SupportedPlatform.qq.isAppInstalled
    }
    
    static var isAppInstalledWeibo: Bool {
        return MonkeyKing.SupportedPlatform.weibo.isAppInstalled
    }
    
    static func register(weChatAppId: String, weChatAppKey: String) {
        MonkeyKing.registerAccount(MonkeyKing.Account.weChat(appID: weChatAppId, appKey: weChatAppKey, miniAppID: ""))
    }
    
    static func register(qqAppId: String) {
        shared.qqAppId = qqAppId
        MonkeyKing.registerAccount(MonkeyKing.Account.qq(appID: qqAppId))
    }
    
    static func register(weiboAppId: String, appKey: String, redirectURL: String) {
        MonkeyKing.registerAccount(MonkeyKing.Account.weibo(appID: weiboAppId, appKey: appKey, redirectURL: redirectURL))
    }
    
    static func setSharePlatforms(_ sharePlatforms: [SharePlatform]) {
        shared.sharePlatforms = sharePlatforms
    }
    
    static func handleOpenURLSocial(open url: URL) -> Bool {
        return MonkeyKing.handleOpenURL(url)
    }
    
    static func share(title: String, description: String, thumbnail: UIImage?, url: String) {
        filterPlatformsItems()
        EasySocialShareView().show(platforms: shared.sharePlatforms) { (platform) in
            EasyLog.debug(platform)
            guard let url = URL(string: url) else { return }
            var message: MonkeyKing.Message?
            switch platform {
            case .wechat:
                message = MonkeyKing.Message.weChat(.session(info: (title: title, description: description, thumbnail: thumbnail, media: .url(url))))
            case .wechatFavorite:
                message = MonkeyKing.Message.weChat(.favorite(info: (title: title, description: description, thumbnail: thumbnail, media: .url(url))))
            case .wechatTimeline:
                message = MonkeyKing.Message.weChat(.timeline(info: (title: title, description: description, thumbnail: thumbnail, media: .url(url))))
            case .qq:
                message = MonkeyKing.Message.qq(.friends(info: (title: title, description: description, thumbnail: thumbnail, media: .url(url))))
            case .qqZone:
                message = MonkeyKing.Message.qq(.zone(info: (title: title, description: description, thumbnail: thumbnail, media: .url(url))))
            case .weibo:
                message = MonkeyKing.Message.weibo(.default(info: (title: title, description: description, thumbnail: thumbnail, media: .url(url)), accessToken: ""))
            }
            guard let m = message else { return }
            MonkeyKing.deliver(m, completionHandler: { (result) in
                EasyLog.debug("result: \(result)")
            })
        }
    }
    
    static func oauth(platformType: OauthPlatformType, responseHandler: @escaping (UserInfo?, Error?) -> Void) {
        switch platformType {
        case .wechat:
            MonkeyKing.oauth(for: .weChat) { (dictionary, response, error) in
                if let error = error {
                    EasyLog.debug("error \(String(describing: error))")
                    responseHandler(nil, error)
                } else {
                    guard let token = dictionary?["access_token"] as? String, let openid = dictionary?["openid"] as? String, let refreshToken = dictionary?["refresh_token"] as? String, let expiresIn = dictionary?["expires_in"] as? Int else { return }
                    let userInfoAPI = "https://api.weixin.qq.com/sns/userinfo"
                    let parameters = ["openid": openid, "access_token": token]
                    // https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1421140839
                    EasyNetworking.sharedInstance.request(userInfoAPI, method: .get, parameters: parameters, completionHandler: { (userInfo, _, error) in
                        if let error = error {
                            EasyLog.debug(error)
                            responseHandler(nil, error)
                        } else {
                            if var userInfo = userInfo {
                                userInfo["access_token"] = token
                                userInfo["openid"] = openid
                                userInfo["refresh_token"] = refreshToken
                                userInfo["expires_in"] = expiresIn
                                EasyLog.debug("userInfo \(userInfo)")
                                // 用户的性别，值为1时是男性，值为2时是女性，值为0时是未知
                                var sex = ""
                                if let gender = userInfo["sex"] as? Int {
                                    switch gender {
                                    case 1:
                                        sex = "男"
                                    case 2:
                                        sex = "女"
                                    default:
                                        break
                                    }
                                }
                                responseHandler(UserInfo(openid: openid, nickname: userInfo["nickname"] as? String ?? "", iconurl: userInfo["headimgurl"] as? String ?? "", sex: sex), error)
                            }
                        }
                    })
                }
            }
        case .qq:
            MonkeyKing.oauth(for: .qq, scope: "get_user_info") { (info, response, error) in
                if let error = error {
                    EasyLog.debug("error \(String(describing: error))")
                    responseHandler(nil, error)
                } else {
                    guard let unwrappedInfo = info, let token = unwrappedInfo["access_token"] as? String, let openid = unwrappedInfo["openid"] as? String else { return }
                    let query = "get_user_info"
                    let userInfoAPI = "https://graph.qq.com/user/\(query)"
                    let parameters = ["openid": openid, "access_token": token, "oauth_consumer_key": shared.qqAppId]
                    // http://wiki.open.qq.com/wiki/website/get_user_info
                    EasyNetworking.sharedInstance.request(userInfoAPI, method: .get, parameters: parameters) { (userInfo, _, _) in
                        if let error = error {
                            EasyLog.debug(error)
                            responseHandler(nil, error)
                        } else {
                            if var userInfo = userInfo {
                                userInfo["access_token"] = token
                                userInfo["openid"] = openid
                                EasyLog.debug("userInfo \(userInfo)")
                                responseHandler(UserInfo(openid: openid, nickname: userInfo["nickname"] as? String ?? "", iconurl: userInfo["figureurl_qq_1"] as? String ?? "", sex: userInfo["gender"] as? String ?? ""), error)
                            }
                        }
                    }
                }
            }
        case .weibo:
            MonkeyKing.oauth(for: .weibo) { (info, response, error) in
                if let error = error {
                    EasyLog.debug("error \(String(describing: error))")
                    responseHandler(nil, error)
                } else {
                    guard let unwrappedInfo = info, let token = (unwrappedInfo["access_token"] as? String) ?? (unwrappedInfo["accessToken"] as? String), let userID = (unwrappedInfo["uid"] as? String) ?? (unwrappedInfo["userID"] as? String) else { return }
                    let userInfoAPI = "https://api.weibo.com/2/users/show.json"
                    let parameters = ["uid": userID, "access_token": token]
                    // http://open.weibo.com/wiki/2/users/domain_show
                    EasyNetworking.sharedInstance.request(userInfoAPI, method: .get, parameters: parameters) { (userInfo, _, _) in
                        if let error = error {
                            EasyLog.debug(error)
                            responseHandler(nil, error)
                        } else {
                            if var userInfo = userInfo {
                                userInfo["access_token"] = token
                                userInfo["uid"] = userID
                                EasyLog.debug("userInfo \(userInfo)")
                                // m：男、f：女、n：未知
                                var sex = ""
                                if let gender = userInfo["gender"] as? String {
                                    switch gender {
                                    case "m":
                                        sex = "男"
                                    case "f":
                                        sex = "女"
                                    default:
                                        break
                                    }
                                }
                                responseHandler(UserInfo(openid: userID, nickname: userInfo["screen_name"] as? String ?? "", iconurl: userInfo["profile_image_url"] as? String ?? "", sex: sex), error)
                            }
                        }
                    }
                }
            }
        }
    }
    
}

private class EasySocialShareView: UIView {
    
    private let kSocialShreButtonHeight: CGFloat = 90
    private let kSocialShreButtonWidth: CGFloat = 76
    private let kSocialShreHeightSpace: CGFloat = 15
    private let kSocialShreCancelHeight: CGFloat = (EasyApp.isAllFaceIDCapableDevices ? 80 : 46)
    
    private var bottomViewHeight: CGFloat = 0
    private var platforms = [EasySocial.SharePlatform]()
    private var completion: ((EasySocial.SharePlatformType) -> Void)?
    
    private lazy var bottomView: UIView = {
        let bottomView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: bottomViewHeight))
        bottomView.backgroundColor = UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 1)
        return bottomView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.addTarget(self, action: #selector(close))
        self.addGestureRecognizer(tapGestureRecognizer)
        
        addSubview(bottomView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addPlatformsItems() {
        let column: Int = 4
        let ceil = CGFloat(Double(platforms.count) / Double(column)).ceil
        bottomViewHeight = kSocialShreHeightSpace * (CGFloat(platforms.count / column + 2)) + kSocialShreButtonHeight * ceil + kSocialShreCancelHeight
        
        let margin = (UIScreen.main.bounds.width - CGFloat(column) * kSocialShreButtonWidth) / (CGFloat(column) + 1)
        
        for index in 0 ..< platforms.count {
            let platform = platforms[index]
            
            let colX: Int = index % column
            let rowY: Int = Int(index / column)
            
            let buttonX: CGFloat = margin + CGFloat(colX) * (kSocialShreButtonWidth + margin)
            let buttonY: CGFloat = kSocialShreHeightSpace + CGFloat(rowY) * (kSocialShreButtonHeight + kSocialShreHeightSpace)
            let button = EasyVerticalButton()
            button.frame = CGRect(x: buttonX, y: buttonY, width: kSocialShreButtonWidth, height: kSocialShreButtonHeight)
            button.setTitle(platform.name, for: .normal)
            button.setImage(platforms[index].image, for: .normal)
            button.addTarget(self, action: #selector(show(_:)), for: .touchUpInside)
            button.tag = platform.type.rawValue
            self.bottomView.addSubview(button)
        }
        
        for (index, button) in bottomView.subviews.enumerated() {
            guard let button = button as? UIButton else { return }
            
            let fromTransform = CGAffineTransform(translationX: 0, y: 50)
            button.transform = fromTransform
            button.alpha = 0.3
            
            UIView.animate(withDuration: TimeInterval(0.9 + Float(index) * 0.1), delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
                button.transform = CGAffineTransform.identity
                button.alpha = 1
            }, completion: nil)
        }
        
        let cancel = UIButton(type: .custom)
        cancel.frame = CGRect(x: 0, y: bottomViewHeight - kSocialShreCancelHeight, width: UIScreen.main.bounds.width, height: kSocialShreCancelHeight)
        cancel.setTitle("取消", for: .normal)
        cancel.setTitleColor(UIColor.black, for: .normal)
        cancel.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancel.backgroundColor = UIColor.white
        cancel.addTarget(self, action: #selector(close), for: .touchUpInside)
        self.bottomView.addSubview(cancel)
    }
    
    func show(platforms: [EasySocial.SharePlatform], completion: @escaping (EasySocial.SharePlatformType) -> Void) {
        self.platforms = platforms
        self.completion = completion
        self.addPlatformsItems()
        self.frame = UIScreen.main.bounds
        self.backgroundColor = UIColor.clear
        UIApplication.shared.keyWindow?.addSubview(self)
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let `self` = self else { return }
            self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            self.bottomView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - self.bottomViewHeight, width: UIScreen.main.bounds.width, height: self.bottomViewHeight)
        }
    }
    
    @objc private func show(_ sender: UIButton) {
        guard let platform = EasySocial.SharePlatformType(rawValue: sender.tag) else { return }
        completion?(platform)
        close()
    }
    
    @objc private func close() {
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            guard let `self` = self else { return }
            self.backgroundColor = UIColor.clear
            self.bottomView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: self.bottomViewHeight)
        }) { (finish) in
            self.subviews.forEach({ $0.removeFromSuperview() })
            self.removeFromSuperview()
        }
    }
    
}

extension EasySocialShareView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: self.bottomView))! {
            return false
        }
        return true
    }
    
}

private class EasyNetworking {
    
    static let sharedInstance = EasyNetworking()
    private let session = URLSession.shared
    
    typealias NetworkingResponseHandler = ([String: Any]?, URLResponse?, Error?) -> Void
    
    enum Method: String {
        case get = "GET"
        case post = "POST"
    }
    
    enum ParameterEncoding {
        case url
        case urlEncodedInURL
        case json
        
        func encode(_ urlRequest: URLRequest, parameters: [String: Any]?) -> URLRequest {
            guard let parameters = parameters else {
                return urlRequest
            }
            var mutableURLRequest = urlRequest
            switch self {
            case .url, .urlEncodedInURL:
                func query(_ parameters: [String: Any]) -> String {
                    var components: [(String, String)] = []
                    for key in parameters.keys.sorted(by: <) {
                        let value = parameters[key]!
                        components += queryComponents(key, value)
                    }
                    return (components.map { "\($0)=\($1)" } as [String]).joined(separator: "&")
                }
                func encodesParametersInURL(_ method: Method) -> Bool {
                    switch self {
                    case .urlEncodedInURL:
                        return true
                    default:
                        break
                    }
                    switch method {
                    case .get:
                        return true
                    default:
                        return false
                    }
                }
                if let method = Method(rawValue: mutableURLRequest.httpMethod!) , encodesParametersInURL(method) {
                    if var urlComponents = URLComponents(url: mutableURLRequest.url!, resolvingAgainstBaseURL: false) {
                        let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
                        urlComponents.percentEncodedQuery = percentEncodedQuery
                        mutableURLRequest.url = urlComponents.url
                    }
                } else {
                    if mutableURLRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                        mutableURLRequest.setValue(
                            "application/x-www-form-urlencoded; charset=utf-8",
                            forHTTPHeaderField: "Content-Type"
                        )
                    }
                    mutableURLRequest.httpBody = query(parameters).data(using: .utf8, allowLossyConversion: false)
                }
            case .json:
                do {
                    let options = JSONSerialization.WritingOptions()
                    let data = try JSONSerialization.data(withJSONObject: parameters, options: options)
                    
                    mutableURLRequest.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
                    mutableURLRequest.setValue("application/json", forHTTPHeaderField: "X-Accept")
                    mutableURLRequest.httpBody = data
                } catch {
                    EasyLog.debug(error)
                }
            }
            return mutableURLRequest
        }
        
        func queryComponents(_ key: String, _ value: Any) -> [(String, String)] {
            var components: [(String, String)] = []
            if let dictionary = value as? [String: Any] {
                for (nestedKey, value) in dictionary {
                    components += queryComponents("\(key)[\(nestedKey)]", value)
                }
            } else if let array = value as? [Any] {
                for value in array {
                    components += queryComponents("\(key)[]", value)
                }
            } else {
                components.append((escape(key), escape("\(value)")))
            }
            return components
        }
        
        func escape(_ string: String) -> String {
            let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
            let subDelimitersToEncode = "!$&'()*+,;="
            let allowedCharacterSet = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
            allowedCharacterSet.removeCharacters(in: generalDelimitersToEncode + subDelimitersToEncode)
            var escaped = ""
            if #available(iOS 8.3, *) {
                escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet) ?? string
            } else {
                let batchSize = 50
                var index = string.startIndex
                while index != string.endIndex {
                    let startIndex = index
                    let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) ?? startIndex
                    let substring = string[startIndex..<endIndex]
                    escaped += (substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet) ?? String(substring))
                    index = endIndex
                }
            }
            return escaped
        }
    }
    
    func request(_ urlString: String, method: Method, parameters: [String: Any]? = nil, encoding: ParameterEncoding = .url, headers: [String: String]? = nil, completionHandler: @escaping NetworkingResponseHandler) {
        guard let url = URL(string: urlString) else {
            return
        }
        var mutableURLRequest = URLRequest(url: url)
        mutableURLRequest.httpMethod = method.rawValue
        if let headers = headers {
            for (headerField, headerValue) in headers {
                mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }
        let request = encoding.encode(mutableURLRequest, parameters: parameters)
        let task = session.dataTask(with: request) { data, response, error in
            var json: [String: Any]?
            defer {
                completionHandler(json, response, error)
            }
            guard
                let validData = data,
                let jsonData = try? JSONSerialization.jsonObject(with: validData, options: .allowFragments) as? [String: Any] else {
                    EasyLog.debug("sample networking requet failt: JSON could not be serialized because input data was nil.")
                    return
            }
            json = jsonData
        }
        task.resume()
    }
    
    func upload(_ urlString: String, parameters: [String: Any], completionHandler: @escaping NetworkingResponseHandler) {
        let tuple = urlRequestWithComponents(urlString, parameters: parameters)
        guard let request = tuple.request, let data = tuple.data else {
            return
        }
        let uploadTask = session.uploadTask(with: request, from: data) { data, response, error in
            var json: [String: Any]?
            defer {
                completionHandler(json, response, error)
            }
            guard
                let validData = data,
                let jsonData = try? JSONSerialization.jsonObject(with: validData, options: .allowFragments) as? [String: Any] else {
                    EasyLog.debug("sample networking upload failt: JSON could not be serialized because input data was nil.")
                    return
            }
            json = jsonData
        }
        uploadTask.resume()
    }
    
    private func urlRequestWithComponents(_ urlString: String, parameters: [String: Any], encoding: ParameterEncoding = .url) -> (request: URLRequest?, data: Data?) {
        guard let url = URL(string: urlString) else {
            return (nil, nil)
        }
        // create url request to send
        var mutableURLRequest = URLRequest(url: url)
        mutableURLRequest.httpMethod = Method.post.rawValue
        let boundaryConstant = "NET-POST-boundary-\(arc4random())-\(arc4random())"
        let contentType = "multipart/form-data;boundary=" + boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        var uploadData = Data()
        // add parameters
        for (key, value) in parameters {
            guard let encodeBoundaryData = "\r\n--\(boundaryConstant)\r\n".data(using: .utf8) else {
                return (nil, nil)
            }
            uploadData.append(encodeBoundaryData)
            if let imageData = value as? Data {
                let filename = arc4random()
                let filenameClause = "filename=\"\(filename)\""
                let contentDispositionString = "Content-Disposition: form-data; name=\"\(key)\";\(filenameClause)\r\n"
                let contentDispositionData = contentDispositionString.data(using: .utf8)
                uploadData.append(contentDispositionData!)
                // append content type
                let contentTypeString = "Content-Type: image/JPEG\r\n\r\n"
                guard let contentTypeData = contentTypeString.data(using: .utf8) else {
                    return (nil, nil)
                }
                uploadData.append(contentTypeData)
                uploadData.append(imageData)
            } else {
                guard let encodeDispositionData = "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".data(using: .utf8) else {
                    return (nil, nil)
                }
                uploadData.append(encodeDispositionData)
            }
        }
        uploadData.append("\r\n--\(boundaryConstant)--\r\n".data(using: .utf8)!)
        return (encoding.encode(mutableURLRequest, parameters: nil), uploadData)
    }
}
