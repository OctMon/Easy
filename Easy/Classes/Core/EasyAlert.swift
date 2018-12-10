//
//  EasyAlert.swift
//  Easy
//
//  Created by OctMon on 2018/9/29.
//

import UIKit

public extension Easy {
    typealias Alert = EasyAlert
    typealias ActionSheet = EasyActionSheet
}

public class EasyAlertController {
    
    var alertController: UIAlertController
    var presentationSource: UIViewController?
    var delayTime: TimeInterval?
    
    var title: String? {
        get {
            return alertController.title
        }
        set {
            alertController.title = newValue
        }
    }
    
    var message: String? {
        get {
            return alertController.message
        }
        set {
            alertController.message = newValue
        }
    }
    
    var configuredPopoverController = false
    
    var tintColor: UIColor? {
        didSet {
            if let tint = tintColor {
                alertController.view.tintColor = tint
            }
        }
    }
    
    var hasRequiredTextfield = false
    var alertPrimaryAction: UIAlertAction?
    
    public init(style: UIAlertController.Style) {
        alertController = UIAlertController(title: nil, message: nil, preferredStyle: style)
    }
    
    @discardableResult
    public func addAction(title: String, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)? = nil) -> EasyAlertController {
        addAction(title: title, style: style, preferredAction: false, handler: handler)
        return self
    }
    
    @discardableResult
    public func addAction(title: String, style: UIAlertAction.Style, preferredAction: Bool = false, handler: ((UIAlertAction) -> Void)? = nil) -> EasyAlertController {
        var action: UIAlertAction
        if let handler = handler {
            action = UIAlertAction(title: title, style: style, handler: handler)
        } else {
            action = UIAlertAction(title: title, style: style, handler: { _ in })
        }
        alertController.addAction(action)
        if #available(iOS 9.0, *) {
            if preferredAction {
                alertController.preferredAction = action
                if(hasRequiredTextfield){
                    action.isEnabled = false
                    alertPrimaryAction = action
                }
            }
        }
        return self
    }
    
    @discardableResult
    public func presentIn(_ source: UIViewController) -> EasyAlertController {
        presentationSource = source
        return self
    }
    
    @discardableResult
    public func delay(_ time: TimeInterval) -> EasyAlertController {
        delayTime = time
        return self
    }
    
    public func show() {
        if let time = delayTime {
            let dispatchTime = DispatchTime.now() + time
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                self.show()
            }
            delayTime = nil
            return
        } else if let viewController = UIApplication.shared.keyWindow?.rootViewController {
            var presentedController = viewController
            while presentedController.presentedViewController != nil && presentedController.presentedViewController?.isBeingDismissed == false {
                presentedController = presentedController.presentedViewController!
            }
            if self is EasyActionSheet && !configuredPopoverController,
                let popoverController = alertController.popoverPresentationController {
                
                var topController = presentedController
                while (topController.children.last != nil) {
                    topController = topController.children.last!
                }
                
                popoverController.sourceView = topController.view
                popoverController.sourceRect = topController.view.bounds
            }
            if let source = presentationSource {
                presentedController = source
            }
            DispatchQueue.main.async {
                presentedController.present(self.alertController, animated: true, completion: nil)
            }
        }
    }
    
}

public class EasyAlert: EasyAlertController {
    
    public init() {
        super.init(style: .alert)
    }
    
    public init(title: String?) {
        super.init(style: .alert)
        self.title = title
    }
    
    public init(message: String?) {
        super.init(style: .alert)
        self.message = message
    }
    
    public init(title: String?, message: String?) {
        super.init(style: .alert)
        self.title = title
        self.message = message
    }
    
    public func addAction(title: String) -> EasyAlert {
        return addAction(title: title, style: .default, preferredAction: false, handler: nil)
    }
    
    @discardableResult
    public override func addAction(title: String, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)? = nil) -> EasyAlert {
        return addAction(title: title, style: style, preferredAction: false, handler: handler)
    }
    
    @discardableResult
    public override func addAction(title: String, style: UIAlertAction.Style, preferredAction: Bool, handler: ((UIAlertAction) -> Void)? = nil) -> EasyAlert {
        return super.addAction(title: title, style: style, preferredAction: preferredAction, handler: handler) as? EasyAlert ?? self
    }
    
    @discardableResult
    public func addTextField(_ textField: inout UITextField, required: Bool = false) -> EasyAlert {
        var tmp: UITextField?
        alertController.addTextField { [unowned textField] (_textField) -> Void in
            _textField.text = textField.text
            _textField.placeholder = textField.placeholder
            _textField.font = textField.font
            _textField.textColor = textField.textColor
            _textField.isSecureTextEntry = textField.isSecureTextEntry
            _textField.keyboardType = textField.keyboardType
            _textField.autocapitalizationType = textField.autocapitalizationType
            _textField.autocorrectionType = textField.autocorrectionType
            tmp = _textField
        }
        if required {
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: tmp, queue: OperationQueue.main) { (notification) in
                if let actionButton = self.alertPrimaryAction {
                    actionButton.isEnabled = tmp?.text?.isEmpty == false
                }
            }
            self.hasRequiredTextfield = true
        }
        if let tmp = tmp {
            textField = tmp
        }
        return self
    }
    
    @discardableResult
    public override func presentIn(_ source: UIViewController) -> EasyAlert {
        return super.presentIn(source) as? EasyAlert ?? self
    }
    
    @discardableResult
    public override func delay(_ time: TimeInterval) -> EasyAlert {
        return super.delay(time) as? EasyAlert ?? self
    }
    
    @discardableResult
    public func tint(_ color: UIColor) -> EasyAlert {
        tintColor = color
        return self
    }
    
    public func showOk(_ handler: ((UIAlertAction) -> Void)? = nil) {
        super.addAction(title:"确定", style: .cancel, preferredAction: false, handler: handler)
        show()
    }
}

public class EasyActionSheet: EasyAlertController {
    
    public init() {
        super.init(style: .actionSheet)
    }
    
    public init(title: String?) {
        super.init(style: .actionSheet)
        self.title = title
    }
    
    public init(message: String?) {
        super.init(style: .actionSheet)
        self.message = message
    }
    
    public init(title: String?, message: String?) {
        super.init(style: .actionSheet)
        self.title = title
        self.message = message
    }
    
    @discardableResult
    public func addAction(title: String) -> EasyActionSheet {
        return addAction(title: title, style: .cancel, handler: nil)
    }
    
    @discardableResult
    public override func addAction(title: String, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)? = nil) -> EasyActionSheet {
        return super.addAction(title: title, style: style, preferredAction: false, handler: handler) as? EasyActionSheet ?? self
    }
    
    @discardableResult
    public override func presentIn(_ source: UIViewController) -> EasyActionSheet {
        return super.presentIn(source) as? EasyActionSheet ?? self
    }
    
    @discardableResult
    public override func delay(_ time: TimeInterval) -> EasyActionSheet {
        return super.delay(time) as? EasyActionSheet ?? self
    }
    
    public func tint(_ color: UIColor) -> EasyActionSheet {
        tintColor = color
        return self
    }
    
    @discardableResult
    public func setBarButtonItem(_ item: UIBarButtonItem) -> EasyActionSheet {
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = item
        }
        super.configuredPopoverController = true
        
        return self
    }
    
    @discardableResult
    public func setPresentingSource(_ source: UIView) -> EasyActionSheet {
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = source
            popoverController.sourceRect = source.bounds
        }
        super.configuredPopoverController = true
        
        return self
    }
}

