//
//  EasyResult.swift
//  Easy
//
//  Created by OctMon on 2018/10/9.
//

import Foundation
import Alamofire

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
    public var error: EasyError? { return result.error }
    
    var list: [Any] = []
}

public extension EasyDataResponse {
    
    /// Returns the config
    var config: EasyConfig {
        return result.config
    }
    
    /// The response’s HTTP status code
    var statusCode: Int {
        return result.statusCode
    }
    
    /// Returns `true` if the result.validStatusCode is a success, `false` otherwise.
    var validStatusCode: Bool {
        return result.validStatusCode
    }
    
    /// Returns `true` if the result.valid is a success, `false` otherwise.
    var valid: Bool {
        return result.valid
    }
    
    /// Returns `true` if the result.validList is a success, `false` otherwise.
    var validList: Bool {
        return result.validList
    }
    
    /// Returns the totalPgee
    var total: Int {
        return result.total
    }
    
    /// Returns the code
    var code: Int {
        return result.code
    }
    
    /// Returns the message
    var msg: String {
        return result.msg
    }
    
    /// Returns the data -> [String: Any]
    var dataParameters: EasyParameters {
        return result.data
    }

    /// Returns the list -> [[String: Any]]
    var listParameters: [EasyParameters] {
        return result.list
    }
    
    /// Returns the Outermost json -> [String: Any]
    var jsonParameters: EasyParameters {
        return result.json
    }
    
}

public struct EasyResult {
    
    private let easyError: EasyError?
    private let dataResponse: DataResponse<Any>?
    public let config: EasyConfig
    public let json: EasyParameters
    
    init(config: EasyConfig, dataResponse: DataResponse<Any>) {
        self.config = config
        self.dataResponse = dataResponse
        switch dataResponse.result {
        case .success(let dataResponse):
            if config.code.onlyValidWithHTTPstatusCode {
                self.json = [:]
                self.easyError = nil
            } else {
                if let jsonData = try? JSONSerialization.data(withJSONObject: dataResponse), let jsonobject = try? JSONSerialization.jsonObject(with: jsonData), let json = jsonobject as? Parameters, JSONSerialization.isValidJSONObject(dataResponse) {
                    self.json = json
                    self.easyError = nil
                } else {
                    self.json = [:]
                    self.easyError = EasyError.serviceError(EasyErrorReason.serverError)
                }
            }
        case .failure(let error):
            self.json = [:]
            switch URLError.Code(rawValue: (error as NSError).code) {
            case URLError.Code.notConnectedToInternet, URLError.Code.timedOut:
                self.easyError = EasyError.networkFailed
            default:
                self.easyError = EasyError.serviceError(error.localizedDescription)
            }
        }
    }
    
    init(config: EasyConfig, error: Error) {
        self.config = config
        self.easyError = EasyError.unknown(error.localizedDescription)
        self.json = [:]
        self.dataResponse = nil
    }
    
}

public extension EasyResult {
    
    var code: Int { return json[config.key.code].toInt ?? config.code.unknown }
    var statusCode: Int { return dataResponse?.response?.statusCode ?? config.code.unknown }
    var msg: String { return json[config.key.msg].toString ?? easyError?.localizedDescription ?? EasyErrorReason.serverError }
    var data: EasyParameters { return (json[config.key.data] as? EasyParameters) ?? [:] }

    var total: Int { return json[config.key.total].toIntValue }
    var list: [EasyParameters] { return (json[config.key.list] as? [EasyParameters]) ?? [] }
    
    var valid: Bool { return code == config.code.success && easyError == nil }
    var validList: Bool { return valid && list.count > 0 }
    var validStatusCode: Bool { return statusCode == config.code.successStatusCode && easyError == nil }
    
    var error: EasyError? {
        if let error = easyError {
            return error
        } else {
            if config.code.onlyValidWithHTTPstatusCode {
                return EasyError.serviceError(msg.isEmpty ? EasyErrorReason.serverError : msg)
            }
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
    
    fileprivate func setRefresh(_ scrollView: UIScrollView, dataResponse: EasyDataResponse, isValidList: Bool, errorHandler: ((Error?) -> Void)? = nil) {
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
        var valid = true
        if isValidList {
            valid = dataResponse.validList
        } else if dataResponse.config.code.onlyValidWithHTTPstatusCode {
            valid = dataResponse.validStatusCode
        } else {
            valid = dataResponse.valid
        }
        if valid {
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
            if ignoreTotalPage || (autoTotalPage ? dataResponse.list.count >= self.pageSize : dataResponse.total
                > self.currentPage) {
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
        } else {
            if let handler = errorHandler {
                handler(dataResponse.error)
            } else {
                if currentPage != firstPage && list.count > 0 {
                    showText(dataResponse.error?.localizedDescription)
                } else {
                    list.removeAll()
                    if let tableView = scrollView as? UITableView {
                        tableView.reloadData()
                    } else if let collectionView = scrollView as? UICollectionView {
                        UIView.performWithoutAnimation {
                            collectionView.reloadData()
                        }
                    }
                    showPlaceholder(error: dataResponse.error, image: nil, tap: { [weak self] in
                        self?.showLoading()
                        self?.requestHandler?()
                    })
                }
                
            }
        }
    }
    
}

public extension EasyTableListView {
    
    func addRefresh(isAddHeader: Bool, isAddFooter: Bool, requestHandler: @escaping (() -> Void)) {
        addRefresh(tableView, isAddHeader: isAddFooter, isAddFooter: isAddFooter, requestHandler: requestHandler)
    }
    
    func setRefresh(dataResponse: EasyDataResponse, isValidList: Bool, errorHandler: ((Error?) -> Void)? = nil) {
        setRefresh(tableView, dataResponse: dataResponse, isValidList: isValidList, errorHandler: errorHandler)
    }
    
}

public extension EasyCollectionListView {
    
    func addRefresh(isAddHeader: Bool, isAddFooter: Bool, requestHandler: @escaping (() -> Void)) {
        addRefresh(collectionView, isAddHeader: isAddFooter, isAddFooter: isAddFooter, requestHandler: requestHandler)
    }
    
    func setRefresh(dataResponse: EasyDataResponse, isValidList: Bool, errorHandler: ((Error?) -> Void)? = nil) {
        setRefresh(collectionView, dataResponse: dataResponse, isValidList: isValidList, errorHandler: errorHandler)
    }

}
#endif
