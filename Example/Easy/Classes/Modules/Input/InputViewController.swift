//
//  InputViewController.swift
//  Easy
//
//  Created by OctMon on 2018/11/6.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class InputViewController: easy.ViewController, easy.TableListProtocol {
    
    typealias EasyTableListViewAssociatedType = easy.TableListView

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = easy.InputCell.toString
        request()
    }
    
    override func configure() {
        super.configure()
        
        addTableListView(in: view, style: .grouped).do {
            $0.allowsSelection = false
            $0.separatorStyle = .none
        }
        
        tableListView.setTableViewRegister(easy.InputCell.Model.self, cellClass: easy.InputCell.self, configureCell: { [weak self] (cell, indexPath, any) in
            (cell as? easy.InputCell)?.do {
                var limit = Int.max
                switch indexPath.row {
                case 0:
                    $0.textField.keyboardType = .numberPad
                    limit = 11
                case 1:
                    $0.textField.isSecureTextEntry = true
                    limit = 16
//                    $0.smsCodeButton.tap(handler: { [weak self] (_) in
//                        self?.view.showText("sms")
//                    })
                default:
                    break
                }
                $0.addSeparatorBottom()
                $0.textField.clearButtonMode = .always
                $0.setModel(any, imagePadding: 15)
                $0.setTextFieldEditingChangedHandler(textCount: limit, handler: { (input) in
                    any.do {
                        var model = $0
                        model.title = input
                        self?.tableListView.list[indexPath.row] = model
                    }
                })
            }
        }, didSelectRow: nil)
    }
    
    override func request() {
        super.request()
        
        tableListView.list = [
            easy.InputCell.Model(icon: UIColor.random.toImage?.resize(to: CGSize(width: 20, height: 20)), title: "", placeholder: "请输入手机号"),
            easy.InputCell.Model(icon: UIColor.random.toImage?.resize(to: CGSize(width: 20, height: 20)), title: "", placeholder: "请输入密码"),
        ]
    }
}
