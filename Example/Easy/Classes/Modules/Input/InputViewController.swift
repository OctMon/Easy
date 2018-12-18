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

    var mobile: String {
        return tableList(easy.InputCell.Model.self)[0].title
    }
    
    var smsCode: String {
        return tableList(easy.InputCell.Model.self)[1].title
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = easy.InputCell.toString
        
        tableList = [
            easy.InputCell.Model(icon: UIColor.random.toImage?.resize(to: CGSize(width: 20, height: 20)), title: "", placeholder: "请输入手机号"),
            easy.InputCell.Model(icon: UIColor.random.toImage?.resize(to: CGSize(width: 20, height: 20)), title: "", placeholder: "请输入密码"),
        ]
    }
    
    override func configure() {
        super.configure()
        
        addTableListView(in: view, style: .grouped)
        
        tableView.do {
            $0.estimatedRowHeight = 88
            $0.allowsSelection = false
            $0.separatorStyle = .none
        }
        
        tableListView.register(easy.InputCell.Model.self, cellClass: easy.InputCell.self, configureCell: { [weak self] (listView, cell, indexPath, any) in
            if let cell = cell as? easy.InputCell {
                var limit = Int.max
                switch indexPath.row {
                case 0:
                    cell.textField.keyboardType = .numberPad
                    limit = 11
                case 1:
                    cell.textField.isSecureTextEntry = true
                    limit = 16
                    cell.smsCodeButton.tap(handler: { [weak self] (_) in
                        self?.view.showText(self?.mobile)
                    })
                default:
                    break
                }
                cell.addSeparatorBottom()
                cell.textField.clearButtonMode = .whileEditing
                cell.setModel(any, imagePadding: 15)
                cell.setTextFieldEditingChangedHandler(textCount: limit, handler: { [weak listView] (input) in
                    any?.do {
                        var model = $0
                        model.title = input
                        listView?.list[indexPath.row] = model
                    }
                })
            }
        }, didSelectRow: nil)
    }
}
