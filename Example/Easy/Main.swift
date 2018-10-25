//
//  Main.swift
//  Easy_Example
//
//  Created by OctMon on 2018/10/7.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class Main: easy.BaseViewController {
    
    private let textView: UITextView = UITextView(frame: CGRect(x: 0, y: 0, width: app.screenWidth, height: 100))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.appendLeftBarButtonItem(title: "baidu") { [weak self] in
            let webVC = easy.WebViewController().then {
                $0.urlString = "https://www.baidu.com"
            }
            self?.pushWithHidesBottomBar(to: webVC)
        }
        
        navigationItem.appendRightBarButtonItem(title: "+") { [weak self] in
            guard let `self` = self else { return }
            easy.PopMenu().show(point: CGPoint(x: app.screenWidth - 120, y: self.navigationBottom), items: ["QRcode", "Barcode"], completion: { [weak self] index in
                guard let `self` = self else {
                    return
                }
                let text = self.textView.text.isEmpty ? self.textView.placeholder : self.textView.text
                var image: UIImage?
                switch index {
                case 0:
                    image = text?.toQRcode
                case 1:
                    image = text?.toBarcode
                default:
                    break
                }
                guard image != nil else {
                    return
                }
                
                let imageView = UIImageView(image: image?.resize(to: CGSize(width: .screenWidth * 2, height: index == 0 ? .screenWidth * 2 : .screenWidth))).then {
                    $0.contentMode = .scaleAspectFit
                    $0.size = CGSize(width: .screenWidth, height: .screenWidth)
                }
                let popupView = easy.PopupView(imageView)
                popupView.animationDuration = 0
                popupView.showWithCenter(showHandler: {
                    switch Int.random(in: 1...3) {
                    case 1:
                        imageView.animationShake()
                    case 2:
                        imageView.animationPulse(1)
                    case 3:
                        imageView.animationHeartbeat(1)
                    default:
                        break
                    }
                }, dismissHandler: {
                    log.debug("dismissHandler")
                })
            })
        }
        
        request()
    }
    
    override func configure() {
        super.configure()
        
        textView.placeholder = app.bundleName
        textView.placeholderColor = UIColor.random
        
        let tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: .screenWidth, height: 22 + 45)).then {
            let button = UIButton().then {
                $0.setTitleColor(easy.Global.tint, for: .normal)
                $0.setBacdkgroundBorder()
                $0.titleLabel?.font = UIFont.size16
                $0.setTitle("Easy", for: .normal)
            }
            $0.addSubview(button)
            button.snp.makeConstraints({ (make) in
                make.left.equalTo(15)
                make.right.equalTo(-15)
                make.bottom.equalToSuperview()
                make.height.equalTo(45)
            })
        }
        
        tableView.tableHeaderView = textView
        tableView.tableFooterView = tableFooterView
        setTableViewRegister(UITableViewCell.self, configureCell: { (cell, _, any) in
            cell.textLabel?.text = any as? String
        }) { (_, any) in
            guard let aClassName = any as? String else { return }
            easy.Router.openURL("easy://", routerParameters: [.className: aClassName])
        }
    }
    
    override func request() {
        super.request()
        
        dataSource = [ScanViewController.toString, TuchongViewController.toString, SocialViewController.toString]
        tableView.reloadData()
    }
    
}
