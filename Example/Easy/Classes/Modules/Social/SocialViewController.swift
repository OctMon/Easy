//
//  SocialViewController.swift
//  Easy
//
//  Created by OctMon on 2018/10/17.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

private enum Module: String {
    case 分享, 微信登录, QQ登录, 微博登录
    case `default`
    var name: String { return "\(self)" }
}

class SocialViewController: easy.ViewController, easy.ListProtocol {
    
    typealias EasyListViewAssociatedType = easy.ListView

    override func viewDidLoad() {
        super.viewDidLoad()
        
        listView.tableViewDataSource = [[Module.分享], [Module.微信登录, Module.QQ登录, Module.微博登录]]
    }
    
    override func configure() {
        super.configure()
        
        addListView(in: view).addTableView(style: .grouped)
        
        listView.setTableView(numberOfSections: { (listView) -> Int in
            return listView.tableViewDataSource.count
        }) { (_, section) -> Int in
            return 1
        }
        listView.setTableViewRegister([UITableViewCell.self, SocialCell.self], returnCell: { (indexPath) -> AnyClass? in
            switch indexPath.section {
            case 0:
                return UITableViewCell.self
            default:
                return SocialCell.self
            }
        }, configureCell: { [weak self] (cell, indexPath, any) in
            if let cell = cell as? SocialCell {
                cell.modules = self?.listView.tableViewDataSource[indexPath.section] as? [Module] ?? []
            } else {
                cell.textLabel?.text = (any as? Module)?.name
            }
        }) { (_, any) in
            easy.Social.share(title: "Apple", description: "China", thumbnail: UIImage.setColor(UIColor.red), url: "http://www.apple.com/cn")
        }
    }

}

private func showUserInfo(_ userInfo: easy.Social.UserInfo) {
    alert(message: "nickname:" + userInfo.nickname + "\niconurl:" + userInfo.iconurl + "\nopenid:" + userInfo.openid + "\nsex:" + userInfo.sex).showOk()
}

private class SocialCell: UITableViewCell, easy.ListProtocol {
    
    typealias EasyListViewAssociatedType = easy.ListView
    
    var modules: [Module] = [] {
        didSet {
            listView.snp.remakeConstraints { (make) in
                make.edges.equalToSuperview()
                make.height.equalTo(.screenWidth * 0.5 * (modules.count.toCGFloat * 0.5).ceil)
            }
            listView.collectionViewDataSource = modules
            listView.collectionView.reloadData()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addListView(in: self).do {
            $0.addCollectionView(layout: $0.collectionViewWaterFlowLayout)
            $0.collectionViewWaterFlowLayout.do {
                $0.minimumInteritemSpacing = 0
                $0.minimumLineSpacing = 0
            }
        }
        
        listView.setCollectionViewRegister(Module.self, cellClass:TuchongCollectionViewCell.self, configureCell: { (cell, _, any) in
            (cell as? TuchongCollectionViewCell)?.do {
                $0.backgroundColor = UIColor.random
                $0.label.text = any.name
            }
        }) { (indexPath, any) in
            switch any {
            case .微信登录:
                easy.Social.oauth(platformType: .wechat) { (userInfo, _, error) in
                    if let userInfo = userInfo {
                        showUserInfo(userInfo)
                    } else if let error = error {
                        log.debug(error)
                    }
                }
            case .QQ登录:
                easy.Social.oauth(platformType: .qq) { (userInfo, _, error) in
                    if let userInfo = userInfo {
                        showUserInfo(userInfo)
                    } else if let error = error {
                        log.debug(error)
                    }
                }
            case .微博登录:
                easy.Social.oauth(platformType: .weibo) { (userInfo, _, error) in
                    if let userInfo = userInfo {
                        showUserInfo(userInfo)
                    } else if let error = error {
                        log.debug(error)
                    }
                }
            default:
                break
            }
        }
        
        listView.setCollectionViewSizeForItemAt { (_, _) -> CGSize in
            return CGSize(width: .screenWidth * 0.5, height: .screenWidth * 0.5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
