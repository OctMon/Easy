//
//  EasyResult.swift
//  Easy
//
//  Created by OctMon on 2018/10/9.
//

import Foundation
import Alamofire

public enum EasyResult {
    case success(EasyDataResult)
    case failure(Error)
    
    /// Returns `true` if the result is a success, `false` otherwise.
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    /// Returns `true` if the result is a failure, `false` otherwise.
    public var isFailure: Bool {
        return !isSuccess
    }
    
    /// Returns the EasyDataResult if the result is a success, `nil` otherwise.
    public var value: EasyDataResult? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }

    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    public var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}

public struct EasyDataResponse {
    /// The URL request sent to the server.
    public let request: URLRequest?
    
    /// The server's response to the URL request.
    public let response: HTTPURLResponse?
    
    /// The data returned by the server.
    public let data: Data?
    
    /// The result of response serialization.
    public let result: EasyResult
    
    /// The timeline of the complete lifecycle of the request.
    public let timeline: Timeline
    
    /// Returns the associated error value if the result if it is a failure, `nil` otherwise.
    public var error: Error? { return result.error }

    var list: [Any] = []
    
    var _config: EasyConfig
}

extension DataResponse {
    
    func toEasyDataResponse(config: EasyConfig) -> EasyDataResponse {
        var dataResult: EasyDataResult
        switch result {
        case .success(let dataResponse):
            if let jsonData = try? JSONSerialization.data(withJSONObject: dataResponse), let jsonobject = try? JSONSerialization.jsonObject(with: jsonData), let json = jsonobject as? Parameters, JSONSerialization.isValidJSONObject(dataResponse) {
                dataResult = EasyDataResult(config: config, json: json, error: nil)
            } else {
                dataResult = EasyDataResult(config: config, json: [:], error: EasyError.empty(EasyErrorReason.serverError))
            }
            return EasyDataResponse(request: request, response: response, data: data, result: .success(dataResult), timeline: timeline, list: [], _config: config)
        case .failure(let error):
            dataResult = EasyDataResult(config: config, json: [:], error: error)
            return EasyDataResponse(request: request, response: response, data: data, result: .failure(error), timeline: timeline, list: [], _config: config)
        }
    }

}

public struct EasyDataResult {
    
    private let config: EasyConfig
    private let easyError: EasyError?
    let json: EasyParameters
    
    init(config: EasyConfig, json: EasyParameters, error: Error?) {
        self.config = config
        self.json = json
        if let error = error {
            switch URLError.Code(rawValue: (error as NSError).code) {
            case URLError.Code.notConnectedToInternet, URLError.Code.timedOut:
                self.easyError = EasyError.networkFailed
            default:
                self.easyError = EasyError.serviceError(error.localizedDescription)
            }
        } else {
            easyError = nil
        }
    }
    
}

public extension EasyDataResult {
    
    var code: Int { return json[config.key.code].toInt ?? config.code.unknown }
    var msg: String { return json[config.key.msg].toString ?? EasyErrorReason.serverError }
    var data: EasyParameters { return (json[config.key.data] as? EasyParameters) ?? [:] }

    var total: Int { return json[config.key.total].toIntValue }
    var list: [EasyParameters] { return (json[config.key.list] as? [EasyParameters]) ?? [] }
    
    var valid: Bool {
        guard easyError == nil else { return false}
        return code == config.code.success
    }
    
    var error: EasyError? {
        if let error = easyError {
            return error
        } else {
            switch code {
            case config.code.empty:
                return EasyError.empty(msg.isEmpty ? EasyErrorReason.empty : msg)
            case config.code.tokenExpired:
                return EasyError.tokenExpired(msg.isEmpty ? EasyErrorReason.token : msg)
            case config.code.forceUpdate:
                return EasyError.forceUpdate(msg.isEmpty ? EasyErrorReason.force : msg)
            default:
                if valid { return nil }
                return EasyError.serviceError(msg.isEmpty ? EasyErrorReason.serverError : msg)
            }
        }
    }

}

public extension EasyDataResponse {
    
    func fill<T: Any>(list: [T]) -> EasyDataResponse {
        var dataResponse = self
        dataResponse.list = list
        return dataResponse
    }
    
    public func list<T>(_ class: T.Type) -> [T] {
        return list as? [T] ?? []
    }
    
}

public extension JSONDecoder {
    
    func decode<T>(_ type: T.Type, from json: EasyParameters?) -> T? where T : Decodable {
        if let data = json?.toData {
            return try? decode(type, from: data)
        }
        return nil
    }
    
}

#if canImport(MJRefresh)
import MJRefresh
public extension EasyListView {
    
    fileprivate func addRefresh(_ scrollView: UIScrollView, isAddHeader: Bool, isAddFooter: Bool, requestHandler: @escaping (() -> Void)) {
        self.requestHandler = requestHandler
        if isAddHeader {
            scrollView.mj_header = EasyRefresh.headerWithHandler { [weak self] in
                self?.currentPage = self?.firstPage ?? 0
                self?.requestHandler?()
            }
        }
        if isAddFooter {
            scrollView.mj_footer = EasyRefresh.footerWithHandler { [weak self] in
                self?.requestHandler?()
            }
        }
    }
    
    fileprivate func setRefresh(_ scrollView: UIScrollView, dataResponse: EasyDataResponse, errorHandler: ((Error?) -> Void)? = nil) {
        let isTableView = scrollView is UITableView
        let isCollectionView = scrollView is UICollectionView
        hideLoading()
        if self.currentPage == self.firstPage {
            if scrollView.mj_header != nil {
                scrollView.mj_header.endRefreshing()
            }
        } else {
            if scrollView.mj_footer != nil {
                scrollView.mj_footer.endRefreshing()
            }
        }
        switch dataResponse.result {
        case .success(let result):
            guard result.valid else {
                if let handler = errorHandler {
                    handler(dataResponse.error)
                } else {
                    if list.count > 0 {
                        showText(dataResponse.error?.localizedDescription)
                    } else {
                        showPlaceholder(error: dataResponse.error, image: nil, tap: { [weak self] in
                            self?.showLoading()
                            self?.requestHandler?()
                        })
                    }
                    
                }
                return
            }
            hidePlaceholder()
            if self.currentPage == self.firstPage {
                if isTableView {
                    self.list = dataResponse.list
                } else if isCollectionView {
                    self.list = dataResponse.list
                }
            } else {
                if isTableView {
                    self.list.append(contentsOf: dataResponse.list)
                } else if isCollectionView {
                    self.list.append(contentsOf: dataResponse.list)
                }
            }
            if let tableView = scrollView as? UITableView {
                tableView.reloadData()
            } else if let collectionView = scrollView as? UICollectionView {
                UIView.performWithoutAnimation {
                    collectionView.reloadData()
                }
            }
            if ignoreTotalPage || (autoTotalPage ? dataResponse.list.count >= self.pageSize : result.total > self.currentPage) {
                self.currentPage += incrementPage
                if scrollView.mj_footer != nil {
                    scrollView.mj_footer.isHidden = false
                    scrollView.mj_footer.resetNoMoreData()
                }
            } else {
                if scrollView.mj_footer != nil {
                    scrollView.mj_footer.isHidden = false
                    scrollView.mj_footer.endRefreshingWithNoMoreData()
                }
            }
        case .failure(let error):
            showPlaceholder(error: error, image: nil, tap: { [weak self] in
                self?.showLoading()
                self?.requestHandler?()
            })
        }
    }
    
}

public extension EasyTableListView {
    
    func addRefresh(isAddHeader: Bool, isAddFooter: Bool, requestHandler: @escaping (() -> Void)) {
        addRefresh(tableView, isAddHeader: isAddFooter, isAddFooter: isAddFooter, requestHandler: requestHandler)
    }
    
    func setRefresh(dataResponse: EasyDataResponse, errorHandler: ((Error?) -> Void)? = nil) {
        setRefresh(tableView, dataResponse: dataResponse, errorHandler: errorHandler)
    }
    
}

public extension EasyCollectionListView {
    
    func addRefresh(isAddHeader: Bool, isAddFooter: Bool, requestHandler: @escaping (() -> Void)) {
        addRefresh(collectionView, isAddHeader: isAddFooter, isAddFooter: isAddFooter, requestHandler: requestHandler)
    }
    
    func setRefresh(dataResponse: EasyDataResponse, errorHandler: ((Error?) -> Void)? = nil) {
        setRefresh(collectionView, dataResponse: dataResponse, errorHandler: errorHandler)
    }

}
#endif
