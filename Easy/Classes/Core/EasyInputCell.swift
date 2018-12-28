//
//  EasyInputCell.swift
//  Pods
//
//  Created by OctMon on 2018/11/6.
//

import UIKit

public extension Easy {
    typealias InputCell = EasyInputCell
}

public class EasyInputCell: UITableViewCell {
    
    deinit {
        EasyLog.debug(toDeinit)
    }

    public struct Model: EasyThen {
        public var icon: UIImage?
        public var title: String = ""
        public var placeholder: String?
        
        public init(icon: UIImage?, title: String, placeholder: String?) {
            self.icon = icon
            self.title = title
            self.placeholder = placeholder
        }
    }
    
    public lazy var textField: UITextField = {
        let textField = UITextField()
        contentView.addSubview(textField)
        
        textField.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
            make.height.equalTo(60)
        })
        
        textField.font = .size14
        textField.textColor = .hex333333
        textField.addTarget(self, action: #selector(textFieldEditingChanged(textField:)), for: .editingChanged)
        textField.setDoneButton()
        
        return textField
    }()
    
    public lazy var smsCodeButton: UIButton = {
        let button = UIButton()
        contentView.addSubview(button)
        
        button.snp.makeConstraints({ (make) in
            make.top.bottom.equalToSuperview()
            make.right.equalTo(textField.snp.right).offset(-15)
        })
        
        button.setTitleColor(.hex(0xFF4040), for: .normal)
        button.titleLabel?.font = .size14
        button.setTitle("获取验证码", for: .normal)
        
        return button
    }()
    
    private var textCount = Int.max
    private var lastText = ""
    private var textFieldEditingChangedHandler: ((String) -> Void)?
    
    private var model: Model? {
        didSet {
            model?.do {
                textField.text = $0.title
                textField.placeholder = $0.placeholder
            }
        }
    }
    
    @objc private func textFieldEditingChanged(textField: UITextField) {
        guard let text = textField.text, text.count <= textCount else {
            textField.text = lastText
            textFieldEditingChangedHandler?(lastText)
            return
        }
        textFieldEditingChangedHandler?(text)
        lastText = text
    }
    
    public func setModel(_ model: Model?, imagePadding: CGFloat) {
        self.model = model
        textField.setLeftIcon(image: model?.icon, padding: imagePadding)
    }
    
    public func setTextFieldEditingChangedHandler(textCount: Int = Int.max, handler: @escaping (String) -> Void) {
        textField.setLimit(textCount)
        self.textCount = textCount
        textFieldEditingChangedHandler = handler
    }

}
