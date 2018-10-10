//
//  EasySession.swift
//  Easy
//
//  Created by OctMon on 2018/10/9.
//

import Foundation
import Alamofire

#if canImport(SwiftyJSON)
import SwiftyJSON
public typealias EasyJSON = JSON
public extension Easy {
    typealias JSON = EasyJSON
}
#endif

public extension Easy {
    typealias session = EasySession
}

public typealias EasyHttpMethod = HTTPMethod
public extension Easy {
    typealias httpMethod = EasyHttpMethod
}

public struct EasySession {
    
    public let config: EasySessionConfig
    
    private let manager = SessionManager.default
    
    public init(_ config: EasySessionConfig) {
        self.config = config
    }
    
    private enum Router: URLRequestConvertible {
        case requestURLEncoding(String, String?, EasyHttpMethod, EasyParameters?, TimeInterval, requestHandler: ((URLRequest) -> URLRequest)?)
        case requestJSONEncoding(String, String?, EasyHttpMethod, EasyParameters?, TimeInterval, requestHandler: ((URLRequest) -> URLRequest)?)
        
        func asURLRequest() throws -> URLRequest {
            switch self {
            case .requestURLEncoding(let baseURL, let path, let method, let parameters, let timeoutInterval, let requestHandler):
                var request = try easyRequestURLEncoding(baseURL: baseURL, path: path, httpMethod: method, parameters: parameters, timeoutInterval: timeoutInterval)
                if let handler = requestHandler?(request) {
                    request = handler
                }
                return request
            case .requestJSONEncoding(let baseURL, let path, let method, let parameters, let timeoutInterval, let requestHandler):
                var request = try easyRequestJSONEncoding(baseURL: baseURL, path: path, httpMethod: method, parameters: parameters, timeoutInterval: timeoutInterval)
                if let handler = requestHandler?(request) {
                    request = handler
                }
                return request
            }
        }
    }
    
}

public extension EasySession {
    
    func get(path: String?, parameters: EasyParameters?, timeoutInterval: TimeInterval? = nil, requestHandler: ((URLRequest) -> URLRequest)? = nil, handler: @escaping (EasyResult) -> Void) {
        manager.easyRequest(Router.requestURLEncoding(config.baseURL.currentBaseURL, path, .get, parameters, timeoutInterval ?? config.other.timeout, requestHandler: requestHandler)).easyResponse { (json, error) in
            handler(EasyResult(config: self.config, json: json, error: error))
        }
    }
    
    func post(path: String?, isURLEncoding: Bool = false, parameters: EasyParameters? = nil, timeoutInterval: TimeInterval? = nil, requestHandler: ((URLRequest) -> URLRequest)? = nil, handler: @escaping (EasyResult) -> Void) {
        if isURLEncoding {
            manager.easyRequest(Router.requestURLEncoding(config.baseURL.currentBaseURL, path, .post, parameters, timeoutInterval ?? config.other.timeout, requestHandler: requestHandler)).easyResponse { (json, error) in
                handler(EasyResult(config: self.config, json: json, error: error))
            }
        } else {
            manager.easyRequest(Router.requestJSONEncoding(config.baseURL.currentBaseURL, path, .post, parameters, timeoutInterval ?? config.other.timeout, requestHandler: requestHandler)).easyResponse { (json, error) in
                handler(EasyResult(config: self.config, json: json, error: error))
            }
        }
    }
    
}

public struct EasySessionConfig {
    
    public init() {
        
    }
    
    public struct BaseURL {
        public var global: String?
        public var release = ""
        public var test = ""
        public var list = [String]()
        public var addition: [String: [String: String]]?
        public var alias: String = ""
        
        public var currentBaseURL: String {
            if let global = global {
                return global
            }
            if EasyApp.isBeta {
                if let url = UserDefaults.standard.string(forKey: defaultCustomBaseURLKey), !url.isEmpty {
                    return url
                }
                return test
            }
            return release
        }
        
        public func currentAddition(key: String) -> String? {
            if let global = global {
                return addition?[global]?[key]
            }
            if EasyApp.isBeta {
                if let url = UserDefaults.standard.string(forKey: defaultCustomBaseURLKey), !url.isEmpty {
                    return addition?[url]?[key] ?? addition?[test]?[key]
                }
                return addition?[test]?[key]
            }
            return addition?[release]?[key]
        }
    }
    
    public struct Key {
        public var code = ["code"]
        public var data = ["data"]
        public var msg = ["message"]
        public var total = ["total"]
        public var list = ["data", "list"]
        public var page = "page"
        public var size = "size"
    }
    
    public struct Code {
        public var success = 0
        public var empty = 1
        public var tokenExpired = -1
        public var forceUpdate = -2
        public var unknown = -990909
    }
    
    public struct Other {
        public var timeout: TimeInterval = 10
        public var pagesize = 10 // 分页数量
    }
    
    public var baseURL = BaseURL()
    public var key = Key()
    public var code = Code()
    public var other = Other()
}

extension EasySessionConfig.BaseURL {
    
    var defaultCustomBaseURLKey: String {
        return "EasyDefaultCustomBaseURL_\(alias.md5)".md5
    }
    
}

extension SessionManager {
    
    func easyRequest(_ urlRequest: URLRequestConvertible) -> DataRequest {
        #if DEBUG || BETA
            urlRequest.urlRequest?.printRequestLog()
        #endif
        return request(urlRequest).validate()
    }
    
}

extension DataRequest {
    
    func easyResponse(handler: @escaping (EasyParameters, Error?) -> Void) {
        responseJSON { (response) in
            self.logResponseJSON(response)
            switch response.result {
            case .success(let data):
                if let jsonData = try? JSONSerialization.data(withJSONObject: data), let jsonobject = try? JSONSerialization.jsonObject(with: jsonData), let json = jsonobject as? Parameters, JSONSerialization.isValidJSONObject(data) {
                    handler(json, nil)
                } else {
                    handler([:], EasyError.empty(EasyErrorReason.empty))
                }
            case .failure(let error):
                handler([:], error)
            }
        }
    }
    
}

#if canImport(NotificationBannerSwift)
import NotificationBannerSwift
#endif

private extension DataRequest {
    
    func logResponseJSON(_ response: DataResponse<Any>) {
        #if DEBUG || BETA
        let title = self.request?.printResponseLog(isPrintBase64DecodeBody: true, response: response.response, data: response.data, error: response.result.error, requestDuration: response.timeline.requestDuration)
        if EasyResult.logEnabel {
            #if canImport(NotificationBannerSwift)
            let banner = StatusBarNotificationBanner(title: "查看日志 📋 [接口响应时间] 🔌 " + String(format: "%.3f秒", response.timeline.requestDuration))
            banner.duration = 1
            banner.show(queuePosition: .front, bannerPosition: .top)
            banner.onTap = {
                let alert = EasyAlert(title: (title?.requestLog ?? "").replacingOccurrences(of: ">", with: "").replacingOccurrences(of: "----", with: "--"), message: (title?.responseLog
                    ?? "").replacingOccurrences(of: ">", with: ""))
                alert.addAction(title: "复制", style: .default, handler: { (_) in
                    ((title?.requestLog ?? "") + (title?.responseLog ?? "")).copyToPasteboard()
                })
                alert.showOk()
            }
            #endif
        }
        #endif
    }
    
}

extension URLRequestConvertible {
    
    func easyRequestURLEncoding(baseURL: String, path: String? = nil, httpMethod: EasyHttpMethod = .get, parameters: EasyParameters? = nil, timeoutInterval: TimeInterval) throws -> URLRequest {
        return try URLEncoding.default.encode(easyRequest(baseURL: baseURL, path: path, httpMethod: httpMethod, timeoutInterval: timeoutInterval), with: parameters)
    }
    
    func easyRequestJSONEncoding(baseURL: String, path: String? = nil, httpMethod: EasyHttpMethod = .post, parameters: EasyParameters? = nil, timeoutInterval: TimeInterval) throws -> URLRequest {
        return try JSONEncoding.default.encode(easyRequest(baseURL: baseURL, path: path, httpMethod: httpMethod, timeoutInterval: timeoutInterval), with: parameters)
    }
    
    private func easyRequest(baseURL: String, path: String?, httpMethod: EasyHttpMethod, timeoutInterval: TimeInterval) throws -> URLRequest {
        let url = URL(string: baseURL)!
        var urlRequest: URLRequest
        if let path = path {
            urlRequest = URLRequest(url: url.appendingPathComponent(path))
        } else {
            urlRequest = URLRequest(url: url)
        }
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.timeoutInterval = timeoutInterval
        return urlRequest
    }
    
}
