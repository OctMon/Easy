//
//  Main.swift
//  Easy_Example
//
//  Created by OctMon on 2018/10/7.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class Main: easy.ViewController {
    
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
        
        lazyListView.addTableView(style: .grouped)
        
        let tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: .screenWidth, height: 22 + 45)).then {
            let button = UIButton().then {
                $0.setTitleColor(easy.Global.tint, for: .normal)
                $0.setBackgroundBorder()
                $0.titleLabel?.font = UIFont.size16
                $0.setTitle("Easy", for: .normal)
            }
            $0.addSubview(button)
            button.snp.makeConstraints({ (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview()
                make.height.equalTo(45)
                make.width.equalTo(.screenWidth - 30)
            })
            button.addTarget(self, action: #selector(showCheckAlert), for: .touchUpInside)
        }
        
        lazyListView.tableView.tableHeaderView = textView
        lazyListView.tableView.tableFooterView = tableFooterView
        lazyListView.setTableViewRegister(String.self, cellClass: UITableViewCell.self, configureCell: { (cell, _, any) in
            cell.textLabel?.text = any
        }) { (_, any) in
            easy.Router.openURL("easy://", routerParameters: [.className: any])
        }
    }
    
    override func request() {
        super.request()
        
        lazyListView.tableViewDataSource = [ScanViewController.toString, TuchongViewController.toString, SocialViewController.toString, PageViewController.toString, InputViewController.toString, MarqueeViewController.toString, FontViewController.toString]
        lazyListView.tableView.reloadData()
    }
    
    @objc private func showCheckAlert() {
        let isForceUpdate = Int.random(in: 0...1) == 0
        
        var buttonTitles = ["立即升级".getAttributedString(font: UIFont.size15, foregroundColor: UIColor.white)]
        var buttonBackgroundImages = [UIColor.red.toImage]
        if !isForceUpdate {
            buttonTitles.insert("稍后再说".getAttributedString(font: UIFont.size15, foregroundColor: UIColor.hex666666), at: 0)
            buttonBackgroundImages.insert(UIColor.white.toImage, at: 0)
        }
        app.showUpdateAlert(image: nil, title: "发现新版本".getAttributedString(font: UIFont.size21, foregroundColor: UIColor.hex333333).getAttributedString(title: "  v6.7.3", font: UIFont.size12, foregroundColor: UIColor.hex999999), message: """
            本次更新：
            - 可以拍一个自己的表情
            - 聊天输入文字时可以长按换行
            
            最近更新：
            - 可以使用英语和粤语进行语音输入了
            - 可以直接浏览订阅号的消息
            - 可以把浏览的文章缩小为浮窗
            """.getAttributedString(font: UIFont.size14, foregroundColor: UIColor.hex999999, lineSpacing: 8), buttonTitles: buttonTitles, buttonBackgroundImages: buttonBackgroundImages, tap: { offset in
                if isForceUpdate || offset == 1 {
                    app.openAppStoreDetails(id: 414478124)
                    log.debug("Force update")
                } else {
                    log.debug("Say later")
                }
        })
    }
    
}
