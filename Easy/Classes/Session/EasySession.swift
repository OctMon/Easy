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
    typealias Session = EasySession
    typealias Config = EasyConfig
    typealias Result = EasyResult
    typealias Error = EasyError
}

public typealias EasyHttpMethod = HTTPMethod
public extension Easy {
    typealias HttpMethod = EasyHttpMethod
}

public struct EasySession {
    
    public let config: EasyConfig
    
    private let manager = SessionManager.default
    
    public init(_ config: EasyConfig) {
        self.config = config
        #if BETA
        addToShowBaseURL()
        #endif
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
    
    func pageSize(_ page: Int, _ size: Int? = nil) -> EasyParameters {
        var parameters = [config.key.page: page]
        if let size = size {
            parameters[config.key.size] = size
        }
        return parameters
    }
    
    func get(parameters: EasyParameters?, timeoutInterval: TimeInterval? = nil, requestHandler: ((URLRequest) -> URLRequest)? = nil, completionHandler: @escaping (EasyResult) -> Void) {
        get(path: nil, parameters: parameters, timeoutInterval: timeoutInterval, requestHandler: requestHandler, completionHandler: completionHandler)
    }
    
    func get(path: String?, parameters: EasyParameters?, timeoutInterval: TimeInterval? = nil, requestHandler: ((URLRequest) -> URLRequest)? = nil, completionHandler: @escaping (EasyResult) -> Void) {
        manager.easyRequest(Router.requestURLEncoding(config.url.currentBaseURL, path, .get, parameters, timeoutInterval ?? config.other.timeout, requestHandler: requestHandler)).easyResponse { (json, error) in
            completionHandler(EasyResult(config: self.config, json: json, error: error))
        }
    }
    
    func post(isURLEncoding: Bool = false, parameters: EasyParameters? = nil, timeoutInterval: TimeInterval? = nil, requestHandler: ((URLRequest) -> URLRequest)? = nil, completionHandler: @escaping (EasyResult) -> Void) {
        post(path: nil, isURLEncoding: isURLEncoding, parameters: parameters, timeoutInterval: timeoutInterval, requestHandler: requestHandler, completionHandler: completionHandler)
    }
    
    func post(path: String?, isURLEncoding: Bool = false, parameters: EasyParameters? = nil, timeoutInterval: TimeInterval? = nil, requestHandler: ((URLRequest) -> URLRequest)? = nil, completionHandler: @escaping (EasyResult) -> Void) {
        if isURLEncoding {
            manager.easyRequest(Router.requestURLEncoding(config.url.currentBaseURL, path, .post, parameters, timeoutInterval ?? config.other.timeout, requestHandler: requestHandler)).easyResponse { (json, error) in
                completionHandler(EasyResult(config: self.config, json: json, error: error))
            }
        } else {
            manager.easyRequest(Router.requestJSONEncoding(config.url.currentBaseURL, path, .post, parameters, timeoutInterval ?? config.other.timeout, requestHandler: requestHandler)).easyResponse { (json, error) in
                completionHandler(EasyResult(config: self.config, json: json, error: error))
            }
        }
    }
    
}

public extension EasySession {
    
    func showChangeBaseURL(_ handler: @escaping (String) -> Void) {
        #if BETA
        let vc = EasySessionViewController()
        vc.config = config
        let popupView = EasyPopupView(vc, height: 300)
        vc.popupView = popupView
        vc.successHandler = handler
        popupView.showWithBottom()
        #endif
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
                    handler([:], EasyError.empty(EasyErrorReason.serverError))
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
