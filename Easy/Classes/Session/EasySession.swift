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
    typealias DataResponse = EasyDataResponse
    typealias Error = EasyError
}

public typealias EasyHttpMethod = HTTPMethod
public typealias EasyMultipartFormData = MultipartFormData
public extension Easy {
    typealias HttpMethod = EasyHttpMethod
    typealias MultipartFormData = EasyMultipartFormData
}

public struct EasySession {
    
    public let config: EasyConfig
    
    private let manager = SessionManager.default
    
    static var logEnabel = false
    
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
    
    func pageSize(_ page: Int, _ size: Int?) -> EasyParameters {
        return pageSize(page, size, parameters: nil)
    }
    
    func pageSize(_ page: Int, _ size: Int?, parameters: EasyParameters?) -> EasyParameters {
        var pageSizeParameters = EasyParameters()
        if let parameters = parameters {
            pageSizeParameters = parameters
        }
        pageSizeParameters[config.key.page] = page
        if let size = size {
            pageSizeParameters[config.key.size] = size
        }
        return pageSizeParameters
    }
    
    func get(parameters: EasyParameters?, timeoutInterval: TimeInterval? = nil, inView view: UIView? = nil, requestHandler: ((URLRequest) -> URLRequest)? = nil, completionHandler: @escaping (EasyDataResponse) -> Void) {
        get(path: nil, parameters: parameters, timeoutInterval: timeoutInterval, inView: view, requestHandler: requestHandler, completionHandler: completionHandler)
    }
    
    func get(path: String?, parameters: EasyParameters?, timeoutInterval: TimeInterval? = nil, inView view: UIView? = nil, requestHandler: ((URLRequest) -> URLRequest)? = nil, completionHandler: @escaping (EasyDataResponse) -> Void) {
        request(path: path, method: .get, isURLEncoding: true, parameters: parameters, timeoutInterval: timeoutInterval, inView: view, requestHandler: requestHandler, completionHandler: completionHandler)
    }
    
    func post(isURLEncoding: Bool = false, parameters: EasyParameters? = nil, timeoutInterval: TimeInterval? = nil, inView view: UIView? = nil, requestHandler: ((URLRequest) -> URLRequest)? = nil, completionHandler: @escaping (EasyDataResponse) -> Void) {
        post(path: nil, isURLEncoding: isURLEncoding, parameters: parameters, timeoutInterval: timeoutInterval, requestHandler: requestHandler, completionHandler: completionHandler)
    }
    
    func post(path: String?, isURLEncoding: Bool = false, parameters: EasyParameters? = nil, timeoutInterval: TimeInterval? = nil, inView view: UIView? = nil, requestHandler: ((URLRequest) -> URLRequest)? = nil, completionHandler: @escaping (EasyDataResponse) -> Void) {
        request(path: path, method: .post, isURLEncoding: isURLEncoding, parameters: parameters, timeoutInterval: timeoutInterval, inView: view, requestHandler: requestHandler, completionHandler: completionHandler)
    }
    
    func request(path: String?, method: EasyHttpMethod, isURLEncoding: Bool, parameters: EasyParameters? = nil, timeoutInterval: TimeInterval? = nil, inView view: UIView? = nil, requestHandler: ((URLRequest) -> URLRequest)? = nil, completionHandler: @escaping (EasyDataResponse) -> Void) {
        request(host: config.url.currentBaseURL, path: path, method: method, isURLEncoding: isURLEncoding, parameters: parameters, timeoutInterval: timeoutInterval, inView: view, requestHandler: requestHandler, completionHandler: completionHandler)
    }
    
    func request(host: String, path: String?, method: EasyHttpMethod, isURLEncoding: Bool, parameters: EasyParameters? = nil, timeoutInterval: TimeInterval? = nil, inView view: UIView? = nil, requestHandler: ((URLRequest) -> URLRequest)? = nil, completionHandler: @escaping (EasyDataResponse) -> Void) {
        view?.showLoading()
        if isURLEncoding {
            manager.easyRequest(Router.requestURLEncoding(host, path, method, parameters, timeoutInterval ?? config.other.timeout, requestHandler: requestHandler), config: config).easyResponse { (dataResponse) in
                view?.hideLoading()
                completionHandler(self.getEasyDataResponse(dataResponse: dataResponse))
            }
        } else {
            manager.easyRequest(Router.requestJSONEncoding(host, path, method, parameters, timeoutInterval ?? config.other.timeout, requestHandler: requestHandler), config: config).easyResponse { (dataResponse) in
                view?.hideLoading()
                completionHandler(self.getEasyDataResponse(dataResponse: dataResponse))
            }
        }
    }
    
    func upload(multipartFormData: @escaping (MultipartFormData) -> Void, host: String? = nil, path: String?, method: EasyHttpMethod = .post, timeoutInterval: TimeInterval? = nil, inView view: UIView? = nil, requestHandler: ((URLRequest) -> URLRequest)? = nil, completionHandler: @escaping (EasyDataResponse) -> Void) {
        let urlRequest = Router.requestJSONEncoding(host ?? config.url.currentBaseURL, path, method, nil, timeoutInterval ?? config.other.timeout, requestHandler: requestHandler)
        logRequest(urlRequest)
        Alamofire.upload(multipartFormData: multipartFormData, with: urlRequest) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                view?.showLoading()
                upload.responseJSON { dataResponse in
                    view?.hideLoading()
                    logResponseJSON(dataResponse)
                    completionHandler(self.getEasyDataResponse(dataResponse: dataResponse))
                }
            case .failure(let encodingError):
                completionHandler(EasyDataResponse(request: nil, response: nil, data: nil, result: EasyResult(config: self.config, error: encodingError), timeline: Timeline(), list: [], model: nil))
            }
        }
    }
    
    private func getEasyDataResponse(dataResponse: DataResponse<Any>) -> EasyDataResponse {
        return EasyDataResponse(request: dataResponse.request, response: dataResponse.response, data: dataResponse.data, result: EasyResult(config: config, dataResponse: dataResponse), timeline: dataResponse.timeline, list: [], model: nil)
    }
    
}

public extension EasySession {
    
    func showChangeBaseURL(_ handler: @escaping (String) -> Void) {
        #if BETA
        let vc = EasySessionViewController()
        vc.config = config
        let popupView = EasyPopupView(vc, height: .screenHeight * 0.38, transition: .bottom)
        vc.popupView = popupView
        vc.successHandler = handler
        popupView.showWithBottom(showHandler: nil) {
            vc.popupView = nil
        }
        #endif
    }
    
}

extension SessionManager {
    
    func easyRequest(_ urlRequest: URLRequestConvertible, config: EasyConfig) -> DataRequest {
        logRequest(urlRequest)
        if let acceptableStatusCodes = config.code.acceptableStatusCodes {
            return request(urlRequest).validate(statusCode: acceptableStatusCodes)
        }
        return request(urlRequest)
    }
    
}

extension DataRequest {
    
    func easyResponse(_ handler: @escaping (DataResponse<Any>) -> Void) {
        responseJSON { (dataResponse) in
            logResponseJSON(dataResponse)
            handler(dataResponse)
        }
    }
    
}

private func logRequest(_ urlRequest: URLRequestConvertible) {
    #if DEBUG || BETA
    urlRequest.urlRequest?.printRequestLog()
    #endif
}

private func logResponseJSON(_ dataResponse: DataResponse<Any>) {
    #if DEBUG || BETA
    let title = dataResponse.request?.printResponseLog(isPrintBase64DecodeBody: true, response: dataResponse.response, data: dataResponse.data, error: dataResponse.result.error, requestDuration: dataResponse.timeline.requestDuration)
    if EasySession.logEnabel {
        EasyNotificationBanner().show(text: "查看日志 📋 [接口响应时间] 🔌 " + String(format: "%.3f秒", dataResponse.timeline.requestDuration) + "\n" + (dataResponse.request?.url?.absoluteString ?? ""), tap: {
            let alert = EasyAlert(title: (title?.requestLog ?? "").replacingOccurrences(of: ">", with: "").replacingOccurrences(of: "----", with: "--"), message: (title?.responseLog
                ?? "").replacingOccurrences(of: ">", with: ""))
            alert.addAction(title: "复制", style: .default, handler: { (_) in
                ((title?.requestLog ?? "") + (title?.responseLog ?? "")).copyToPasteboard()
            })
            alert.showOk()
        })
    }
    #endif
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
