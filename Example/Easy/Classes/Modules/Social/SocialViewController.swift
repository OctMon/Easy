//
//  SocialViewController.swift
//  Easy
//
//  Created by OctMon on 2018/10/17.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class SocialViewController: easy.ViewController {

    enum Module: String {
        case 分享, 微信登录, QQ登录, 微博登录
        case `default`
        var name: String { return "\(self)" }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lazyListView.collectionViewDataSource = [Module.分享, Module.微信登录, Module.QQ登录, Module.微博登录]
        lazyListView.collectionView.reloadData()
    }
    
    override func configure() {
        super.configure()
        
        lazyListView.addCollectionView(layout: lazyListView.collectionViewWaterFlowLayout)
        
        lazyListView.collectionViewWaterFlowLayout.do {
            $0.minimumInteritemSpacing = 0
            $0.minimumLineSpacing = 0
        }
        
        lazyListView.setCollectionViewRegister(Module.self, cellClass:TuchongCollectionViewCell.self, configureCell: { (cell, _, any) in
            (cell as? TuchongCollectionViewCell)?.do {
                $0.backgroundColor = UIColor.random
                $0.label.text = any.name
            }
        }) { [weak self] (indexPath, any) in
            switch any {
            case .分享:
                easy.Social.share(title: "Apple", description: "China", thumbnail: UIImage.setColor(UIColor.red), url: "http://www.apple.com/cn")
            case .微信登录:
                easy.Social.oauth(platformType: .wechat) { [weak self] (userInfo, _, error) in
                    if let userInfo = userInfo {
                        self?.showUserInfo(userInfo)
                    } else if let error = error {
                        log.debug(error)
                    }
                }
            case .QQ登录:
                easy.Social.oauth(platformType: .qq) { [weak self] (userInfo, _, error) in
                    if let userInfo = userInfo {
                        self?.showUserInfo(userInfo)
                    } else if let error = error {
                        log.debug(error)
                    }
                }
            case .微博登录:
                easy.Social.oauth(platformType: .weibo) { [weak self] (userInfo, _, error) in
                    if let userInfo = userInfo {
                        self?.showUserInfo(userInfo)
                    } else if let error = error {
                        log.debug(error)
                    }
                }
            default:
                break
            }
        }
        
        lazyListView.setCollectionViewSizeForItemAt { (_, _) -> CGSize in
            return CGSize(width: .screenWidth * 0.5, height: .screenWidth * 0.5)
        }
    }
    
    private func showUserInfo(_ userInfo: easy.Social.UserInfo) {
        alert(message: "nickname:" + userInfo.nickname + "\niconurl:" + userInfo.iconurl + "\nopenid:" + userInfo.openid + "\nsex:" + userInfo.sex).showOk()
    }

}
