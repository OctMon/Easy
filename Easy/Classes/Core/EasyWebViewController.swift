//
//  EasyWebViewController.swift
//  Easy
//
//  Created by OctMon on 2018/10/14.
//

import UIKit
import WebKit

public extension Easy {
    typealias WebViewController = EasyWebViewController
}

open class EasyWebViewController: EasyViewController {

    public let progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 2))
    
    public let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration()).then {
        $0.allowsBackForwardNavigationGestures = true
        $0.scrollView.bounces = false
    }
    
    public var urlString = ""
    public var timeoutInterval: TimeInterval = 60
    public var scriptCallNativeHandler = "callNativeHandler"
    
    public var navigationBarHidden = false
    
    deinit {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: scriptCallNativeHandler)
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        progressView.reloadInputViews()
    }
    
    open override func navigationShouldPopOnBackButton() -> Bool {
        if webView.canGoBack {
            webView.goBack()
            return false
        }
        return true
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(navigationBarHidden, animated: false)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.do {
            view.addSubview($0)
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: navigationBarHidden ? EasyApp.statusBarHeight : ((self.navigationBar?.isTranslucent ?? false) ? navigationBottom : 0), left: 0, bottom: 0, right: 0))
                if #available(iOS 11, *) {
                } else {
                    automaticallyAdjustsScrollViewInsets = false
                }
            })
            $0.navigationDelegate = self
            $0.uiDelegate = self
            $0.configuration.userContentController.add(EasyWebScriptMessageDelegate(delegate: self), name: scriptCallNativeHandler)
            $0.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        }
        
        progressView.do {
            $0.frame.origin.y = 0
            $0.trackTintColor = .white
            $0.progressTintColor = EasyGlobal.tint
            webView.addSubview(progressView)
        }
        
        request()
    }
    
    open override func request() {
        super.request()
        
        guard let url = URL(string: urlString) else {
            return
        }
        webView.load(URLRequest(url: url, timeoutInterval: timeoutInterval))
    }
    
    public func messageFromNative(_ messageFromNative: String = "JSBridge.handleMessageFromNative", parameters: EasyParameters) {
        guard let parameters = parameters.toPrettyPrintedString else { return }
        let evaluateJavaScript = messageFromNative + "(" + parameters + ")"
        EasyLog.debug("调用了evaluateJavaScript方法，传出参数" + evaluateJavaScript)
        
        EasyApp.runInMain {
            self.webView.evaluateJavaScript(evaluateJavaScript, completionHandler: { (object, error) in
                if let error = error {
                    EasyLog.debug("evaluateJavaScript error:" + error.localizedDescription)
                } else {
                    EasyLog.debug("evaluateJavaScript success")
                }
            })
        }
    }

}

extension EasyWebViewController: WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "estimatedProgress") {
            EasyLog.debug(webView.estimatedProgress)
            progressView.isHidden = false
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            if webView.estimatedProgress >= 1 {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                    self.progressView.setProgress(1, animated: true)
                }) { (_) in
                    self.progressView.isHidden = true
                }
            }
        }
    }
    
    open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.setProgress(0.0, animated: false)
        navigationItem.title = webView.title
    }
    
    open func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        EasyLog.debug(navigationAction.request.url?.absoluteString ?? "")
        decisionHandler(.allow)
    }
    
    open func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        EasyLog.debug("JS 调用了message.name:" + message.name)
        EasyLog.debug("JS 调用了message.body:")
        EasyLog.debug(message.body)
    }
    
}

private class EasyWebScriptMessageDelegate: NSObject {
    
    private weak var scriptDelegate: WKScriptMessageHandler?
    
    deinit {
        EasyLog.debug(toDeinit)
    }
    
    convenience init(delegate: WKScriptMessageHandler?) {
        self.init()
        self.scriptDelegate = delegate
    }
}

extension EasyWebScriptMessageDelegate: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        scriptDelegate?.userContentController(userContentController, didReceive: message)
    }
    
}
