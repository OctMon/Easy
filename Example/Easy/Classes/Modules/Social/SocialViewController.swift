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

class SocialViewController: easy.ViewController, easy.TableListProtocol {
    
    typealias EasyTableListViewAssociatedType = easy.TableListView

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableList = [[Module.分享], [Module.微信登录, Module.QQ登录, Module.微博登录]]
    }
    
    override func configure() {
        super.configure()
        
        addTableListView(in: view, style: .grouped)
        tableView.estimatedRowHeight = 88
        tableListView.setNumberOfSections({ (listView) -> Int in
            return listView.list.count
        }) { (_, section) -> Int in
            return 1
        }
        tableListView.register([UITableViewCell.self, SocialCell.self], returnCell: { (_, indexPath) -> AnyClass? in
            switch indexPath.section {
            case 0:
                return UITableViewCell.self
            default:
                return SocialCell.self
            }
        }, configureCell: { (listView, cell, indexPath, any) in
            if let cell = cell as? SocialCell {
                cell.modules = listView.list[indexPath.section] as? [Module] ?? []
            } else {
                cell.textLabel?.text = (any as? Module)?.name
            }
        }) { (_, _, any) in
            easy.Social.share(title: "Apple", description: "China", thumbnail: UIImage.setColor(UIColor.red), url: "http://www.apple.com/cn")
        }
    }

}

private func showUserInfo(_ userInfo: easy.Social.UserInfo) {
    alert(message: "nickname:" + userInfo.nickname + "\niconurl:" + userInfo.iconurl + "\nopenid:" + userInfo.openid + "\nsex:" + userInfo.sex).showOk()
}

extension SocialViewController {
    
    private class SocialCell: UITableViewCell, easy.CollectionListProtocol {
        
        typealias EasyCollectionListViewAssociatedType = easy.CollectionListView
        
        var modules: [Module] = [] {
            didSet {
                contentView.snp.makeConstraints { (make) in
                    make.height.equalTo(.screenWidth * 0.5 * (modules.count.toCGFloat * 0.5).ceil).priority(.low)
                }
                collectionList = modules
                collectionView.reloadData()
            }
        }
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            addCollectionView(in: self)
            waterFlowLayout.do {
                $0.minimumInteritemSpacing = 0
                $0.minimumLineSpacing = 0
            }
            collectionView.collectionViewLayout = waterFlowLayout
            
            collectionListView.register(Module.self, cellClass:ImageLabelCollectionViewCell.self, configureCell: { (_, cell, _, any) in
                (cell as? ImageLabelCollectionViewCell)?.do {
                    $0.backgroundColor = UIColor.random
                    $0.label.text = any.name
                }
            }) { (_, indexPath, any) in
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
            
            collectionListView.setSizeForItemAt { (_, _, _) -> CGSize in
                return CGSize(width: .screenWidth * 0.5, height: .screenWidth * 0.5)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }

}
