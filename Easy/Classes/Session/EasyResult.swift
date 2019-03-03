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
    var model: Any? = nil
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
    
    /// Returns the Outermost array -> [[String: Any]]
    var arrayParameters: [EasyParameters] {
        return result.array
    }
    
}

public struct EasyResult {
    
    private let easyError: EasyError?
    private let dataResponse: DataResponse<Any>?
    public let config: EasyConfig
    public let json: EasyParameters
    public let array: [EasyParameters]
    
    init(config: EasyConfig, dataResponse: DataResponse<Any>) {
        self.config = config
        self.dataResponse = dataResponse
        switch dataResponse.result {
        case .success(let value):
            if let jsonData = try? JSONSerialization.data(withJSONObject: value), let jsonobject = try? JSONSerialization.jsonObject(with: jsonData), JSONSerialization.isValidJSONObject(value) || config.code.onlyValidWithHTTPstatusCode {
                self.json = (jsonobject as? EasyParameters) ?? [:]
                self.array = (jsonobject as? [EasyParameters]) ?? []
                if config.code.onlyValidWithHTTPstatusCode && (dataResponse.response?.statusCode != config.code.successStatusCode) {
                    let server = json[config.key.msg].toString ?? EasyGlobal.errorServer
                    self.easyError = EasyError.server(server ?? EasyGlobal.errorUnknown)
                } else {
                    self.easyError = nil
                }
            } else {
                self.json = [:]
                self.array = []
                self.easyError = EasyError.server(EasyGlobal.errorServer ?? EasyGlobal.errorUnknown)
            }
        case .failure(let error):
            self.json = [:]
            self.array = []
            switch URLError.Code(rawValue: (error as NSError).code) {
            case URLError.Code.notConnectedToInternet, URLError.Code.timedOut, URLError.Code.networkConnectionLost:
                if let reason = EasyGlobal.errorNetwork {
                    self.easyError = EasyError.network(reason)
                } else {
                    self.easyError = EasyError.network(error.localizedDescription)
                }
            default:
                if config.code.onlyValidWithHTTPstatusCode {
                    self.easyError = (dataResponse.response?.statusCode == config.code.successStatusCode) ? nil : EasyError.server(EasyGlobal.errorServer ?? error.localizedDescription)
                } else {
                    self.easyError = EasyError.server(EasyGlobal.errorServer ?? error.localizedDescription)
                }
            }
        }
    }
    
    init(config: EasyConfig, error: Error) {
        self.config = config
        self.easyError = EasyError.unknown(error.localizedDescription)
        self.json = [:]
        self.array = []
        self.dataResponse = nil
    }
    
}

public extension EasyResult {
    
    var code: Int { return json[config.key.code].toInt ?? config.code.unknown }
    var statusCode: Int { return dataResponse?.response?.statusCode ?? config.code.unknown }
    var msg: String { return json[config.key.msg].toString ?? easyError?.localizedDescription ?? (EasyGlobal.errorServer ?? EasyGlobal.errorUnknown) }
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
                return validStatusCode ? nil : EasyError.server(msg.isEmpty ? EasyGlobal.errorServer ?? EasyGlobal.errorUnknown : msg)
            }
            switch code {
            case config.code.empty:
                return EasyError.empty(msg.isEmpty ? EasyGlobal.errorEmpty : msg)
            case config.code.tokenExpired:
                return EasyError.token(msg.isEmpty ? EasyGlobal.errorToken : msg)
            case config.code.forceUpdate:
                return EasyError.version(msg.isEmpty ? EasyGlobal.errorVersion : msg)
            default:
                if valid { return nil }
                return EasyError.server(msg.isEmpty ? EasyGlobal.errorServer ?? EasyGlobal.errorUnknown : msg)
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
    
    func fill<T: Any>(model: T?) -> EasyDataResponse {
        var dataResponse = self
        if let model = model {
            dataResponse.model = model
        }
        return dataResponse
    }
    
    public func list<T>(_ class: T.Type) -> [T] {
        return list as? [T] ?? []
    }
    
}

public extension JSONDecoder {
    
    func decode<T>(_ type: T.Type, from json: EasyParameters?) -> T? where T : Decodable {
        if let json = json, let data = json.toData, !json.isEmpty {
            return try? decode(type, from: data)
        }
        return nil
    }
    
}

#if canImport(MJRefresh)
import MJRefresh
public extension EasyListView {
    
    enum Valid {
        case list, model, `default`, none
    }
    
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
    
    fileprivate func setRefresh(_ scrollView: UIScrollView, dataResponse: EasyDataResponse, valid: Valid, errorHandler: ((Error?) -> Void)? = nil) {
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
        var isValid = true
        if valid == .list {
            isValid = dataResponse.validList || dataResponse.list.count > 0
        } else if valid == .model {
            isValid = dataResponse.model != nil
        } else if dataResponse.config.code.onlyValidWithHTTPstatusCode {
            isValid = dataResponse.validStatusCode
        } else {
            isValid = dataResponse.valid
        }
        if isValid || valid == .none {
            recoverBackgroundColor(scrollView)
            hidePlaceholder()
            if let model = dataResponse.model {
                self.model = model
            } else {
                if self.currentPage == self.firstPage {
                    self.list = dataResponse.list
                } else {
                    self.list.append(contentsOf: dataResponse.list)
                }
                if ignoreTotalPage || (autoTotalPage ? (dataResponse.list.count >= self.pageSize ?? noMoreDataSize) : dataResponse.total
                    > self.currentPage) {
                    self.currentPage += incrementPage
                    if scrollView.mj_footer != nil {
                        scrollView.mj_footer.isHidden = false
                        scrollView.mj_footer.resetNoMoreData()
                    }
                } else {
                    if scrollView.mj_footer != nil {
                        if self.list.count >= noMoreDataSize {
                            scrollView.mj_footer.isHidden = false
                            scrollView.mj_footer.endRefreshingWithNoMoreData()
                        } else {
                            scrollView.mj_footer.isHidden = true
                        }
                    }
                }
            }
            if let tableView = scrollView as? UITableView {
                tableView.reloadData()
            } else if let collectionView = scrollView as? UICollectionView {
                UIView.performWithoutAnimation {
                    collectionView.reloadData()
                }
            }
        } else {
            if let handler = errorHandler {
                handler(dataResponse.error)
            } else {
                if currentPage != firstPage && list.count > 0 {
                    if dataResponse.list.count == 0 && dataResponse.error == nil {
                        if scrollView.mj_footer != nil {
                            if self.list.count >= noMoreDataSize {
                                scrollView.mj_footer.isHidden = false
                                scrollView.mj_footer.endRefreshingWithNoMoreData()
                            } else {
                                scrollView.mj_footer.isHidden = true
                            }
                        }
                    } else {
                        showText(dataResponse.error?.localizedDescription)
                    }
                } else {
                    if scrollView.mj_footer != nil {
                        scrollView.mj_footer.isHidden = true
                    }
                    list.removeAll()
                    if let tableView = scrollView as? UITableView {
                        tableView.reloadData()
                    } else if let collectionView = scrollView as? UICollectionView {
                        UIView.performWithoutAnimation {
                            collectionView.reloadData()
                        }
                    }
                    let error = dataResponse.error
                    var image: UIImage?
                    var attributedString: NSAttributedString? = error?.localizedDescription.getAttributedString
                    if ((valid == .list) && !dataResponse.validList && (error == nil)) || (dataResponse.code == dataResponse.config.code.empty) || ((valid == .model) && (model == nil) && (error == nil)) {
                        image = EasyGlobal.placeholderEmptyImage
                        attributedString = (dataResponse.msg.isEmpty ? EasyGlobal.errorEmpty : dataResponse.msg).getAttributedString
                        if let placeholders = placeholders {
                            for placeholder in placeholders {
                                if placeholder.style == .empty {
                                    image = placeholder.image
                                    if let title = placeholder.title {
                                        attributedString = title
                                    }
                                }
                            }
                        }
                    } else {
                        if let error = error {
                            switch error {
                            case .server(_):
                                if let placeholderImage = EasyGlobal.placeholderServerImage {
                                    image = placeholderImage
                                }
                            case .network(_):
                                if let placeholderImage = EasyGlobal.placeholderNetworkImage {
                                    image = placeholderImage
                                }
                            default:
                                break
                            }
                        }
                        if let placeholders = placeholders, let error = error {
                            for placeholder in placeholders {
                                switch error {
                                case .server(_):
                                    if placeholder.style == .server {
                                        image = placeholder.image
                                        if let title = placeholder.title {
                                            let att = (EasyGlobal.errorServer ?? error.localizedDescription).getAttributedString
                                            att.append(title)
                                            attributedString = att
                                        }
                                    }
                                case .network(_):
                                    if placeholder.style == .network {
                                        image = placeholder.image
                                        if let title = placeholder.title {
                                            attributedString = title
                                        }
                                    }
                                default:
                                    break
                                }
                            }
                        }
                    }
                    scrollView.backgroundColor = EasyGlobal.placeholderBackgroundColor
                    showPlaceholder(attributedString: attributedString, image: image, backgroundColor: .clear, offset: placeholderOffset, isUserInteractionEnabled: placeholderIsUserInteractionEnabled, bringSubviews: placeholderBringSubviews, tap: { [weak self] in
                        self?.showLoading()
                        self?.requestHandler?()
                    })
                }
                
            }
        }
    }
    
    func recoverBackgroundColor(_ scrollView: UIScrollView?) {
        if let tableView = scrollView as? UITableView {
            tableView.backgroundColor = tableViewBackgroundColor
        } else if let collectionView = scrollView as? UICollectionView {
            collectionView.backgroundColor = collectionViewBackgroundColor
        }
    }
    
    func checkEmptyPlaceholder(scrollView: UIScrollView?) {
        guard list.count == 0 else {
            return
        }
        if scrollView?.mj_footer != nil {
            scrollView?.mj_footer.isHidden = true
        }
        var image: UIImage? = EasyGlobal.placeholderEmptyImage
        var attributedString: NSAttributedString? = EasyGlobal.errorEmpty.getAttributedString
        if let placeholders = placeholders {
            for placeholder in placeholders {
                if placeholder.style == .empty {
                    image = placeholder.image
                    if let title = placeholder.title {
                        attributedString = title
                    }
                }
            }
        }
        scrollView?.backgroundColor = EasyGlobal.placeholderBackgroundColor
        showPlaceholder(attributedString: attributedString, image: image, backgroundColor: .clear, offset: placeholderOffset, isUserInteractionEnabled: placeholderIsUserInteractionEnabled, bringSubviews: placeholderBringSubviews, tap: { [weak self] in
            self?.showLoading()
            self?.requestHandler?()
        })
    }
    
}

public extension EasyTableListView {
    
    var headerRefresh: MJRefreshGifHeader? {
        return tableView.mj_header as? MJRefreshGifHeader
    }
    
    var footerRefresh: MJRefreshAutoNormalFooter? {
        return tableView.mj_footer as? MJRefreshAutoNormalFooter
    }
    
    func addRefresh(isAddHeader: Bool, isAddFooter: Bool, requestHandler: @escaping (() -> Void)) {
        addRefresh(tableView, isAddHeader: isAddHeader, isAddFooter: isAddFooter, requestHandler: requestHandler)
    }
    
    func setRefresh(dataResponse: EasyDataResponse, valid: Valid, errorHandler: ((Error?) -> Void)? = nil) {
        setRefresh(tableView, dataResponse: dataResponse, valid: valid, errorHandler: errorHandler)
    }
    
}

public extension EasyCollectionListView {
    
    var headerRefresh: MJRefreshGifHeader? {
        return collectionView.mj_header as? MJRefreshGifHeader
    }
    
    var footerRefresh: MJRefreshAutoNormalFooter? {
        return collectionView.mj_footer as? MJRefreshAutoNormalFooter
    }
    
    func addRefresh(isAddHeader: Bool, isAddFooter: Bool, requestHandler: @escaping (() -> Void)) {
        addRefresh(collectionView, isAddHeader: isAddHeader, isAddFooter: isAddFooter, requestHandler: requestHandler)
    }
    
    func setRefresh(dataResponse: EasyDataResponse, valid: Valid, errorHandler: ((Error?) -> Void)? = nil) {
        setRefresh(collectionView, dataResponse: dataResponse, valid: valid, errorHandler: errorHandler)
    }
    
}
#endif
