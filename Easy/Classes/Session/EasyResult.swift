//
//  EasyResult.swift
//  Easy
//
//  Created by OctMon on 2018/10/9.
//

import Foundation

public struct EasyResult {
    
    static var logEnabel = false
    
    private let config: EasyConfig
    private let easyError: EasyError?
    let json: EasyParameters
    
    public var models = [Any]()
    public var model: Any?
    
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

public extension EasyResult {
    
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

public extension EasyResult {
    
    func fill<T: Any>(models: [T]) -> EasyResult {
        var response = self
        response.models = models
        return response
    }
    
    func fill<T: Any>(model: T?) -> EasyResult {
        var response = self
        response.model = model
        return response
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
public extension EasyBaseViewController {
    
    func appendRefresh(_ scrollView: UIScrollView, isApeendHeader: Bool, isApeendFooter: Bool) {
        if isApeendHeader {
            scrollView.mj_header = EasyRefresh.headerWithHandler { [weak self] in
                self?.currentPage = self?.firstPage ?? 0
                self?.request()
            }
        }
        if isApeendFooter {
            scrollView.mj_footer = EasyRefresh.footerWithHandler { [weak self] in
                self?.request()
            }
        }
    }
    
    func setRefresh(_ scrollView: UIScrollView, response: EasyResult, errorHandler: ((Error?) -> Void)? = nil) {
        self.view.hideLoading()
        if self.currentPage == self.firstPage {
            if scrollView.mj_header != nil {
                scrollView.mj_header.endRefreshing()
            }
        } else {
            if scrollView.mj_footer != nil {
                scrollView.mj_footer.endRefreshing()
            }
        }
        guard response.valid else {
            if let handler = errorHandler {
                handler(response.error)
            } else {
                if dataSource.count > 0 {
                    self.view.showText(response.error?.localizedDescription)
                } else {
                    self.view.showPlaceholder(error: response.error, image: nil, tap: { [weak self] in
                        self?.view.showLoading()
                        self?.request()
                    })
                }
                
            }
            return
        }
        self.view.hidePlaceholder()
        if self.currentPage == self.firstPage {
            self.dataSource = response.models
        } else {
            self.dataSource.append(contentsOf: response.models)
        }
        if let tableView = scrollView as? UITableView {
            tableView.reloadData()
        } else if let collectionView = scrollView as? UICollectionView {
            UIView.performWithoutAnimation {
                collectionView.reloadData()
            }
        }
        if ignoreTotalPage || response.total > self.currentPage {
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
    }
    
}
#endif
