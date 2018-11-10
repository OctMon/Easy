//
//  MarqueeViewController.swift
//  Easy
//
//  Created by OctMon on 2018/11/6.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class MarqueeViewController: easy.ViewController, easy.ListProtocol {
    
    typealias EasyListViewAssociatedType = easy.ListView

    private var marqueeLabel: easy.MarqueeLabel!
    
    private let marqueeListView = MarqueeListView(frame: CGRect(x: 0, y: 0, width: .screenWidth, height: .screenWidth * 0.25))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        marqueeLabel.numberOfLines = 2
        marqueeLabel.dataSource = ["全新 Liquid 视网膜显示屏，是 iPhone 迄今最先进的 LCD 屏。此外，更有识别速度进一步提升的面容 ID、iPhone 史上最智能最强大的芯片，以及支持景深控制功能的突破性摄像头系统。iPhone XR，怎么看，都满是亮点。", "To run the example project, clone the repo, and run pod install from the Example directory first.", "Easy is available through CocoaPods", "Easy is available under the MIT license. See the LICENSE file for more info."].map { $0.getAttributedString(font: UIFont.size14, foregroundColor: UIColor.random) }
        marqueeLabel.tapClick { (index) in
            log.debug(index)
        }
        
        listView.tableViewDataSource = marqueeLabel.dataSource
        marqueeListView.collectionViewDataSource = marqueeLabel.dataSource
    }
    
    override func configure() {
        super.configure()
        
        addListView(in: view).addTableView(style: .plain).do {
            $0.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: .screenWidth, height: 40)).then {
                $0.backgroundColor = UIColor.gray
                marqueeLabel = easy.MarqueeLabel(frame: CGRect(x: 15, y: 0, width: $0.width - 30, height: 40))
                $0.addSubview(marqueeLabel)
            }
            
            $0.tableFooterView = marqueeListView
        }
        
        listView.do {
            $0.setTableViewRegister(NSAttributedString.self, cellClass: UITableViewCell.self, configureCell: { (cell, _, any) in
                cell.textLabel?.do {
                    $0.numberOfLines = 0
                    $0.attributedText = any
                }
            }, didSelectRow: nil)
        }
    }

}

class MarqueeListView: easy.ListView {
    
    override func configure() {
        super.configure()
        
        addCollectionView(layout: collectionViewWaterFlowLayout)
        
        collectionViewWaterFlowLayout.do {
            $0.minimumInteritemSpacing = 0
            $0.minimumLineSpacing = 0
        }
        
//        collectionView.registerReusableCell(UICollectionViewCell.self)

        setCollectionViewRegister(UICollectionViewCell.self, configureCell: { (cell, _, _) in
            cell.backgroundColor = UIColor.random
        }) { (_, any) in
            log.debug(any)
        }
        
        setCollectionViewSizeForItemAt(NSAttributedString.self) { (_, _) -> CGSize in
            return CGSize(width: .screenWidth * 0.25, height: .screenWidth * 0.25)
        }
        
    }
    
//    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: .screenWidth * 0.25, height: .screenWidth * 0.25)
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(for: indexPath).then {
//            $0.backgroundColor = UIColor.red
//        }
//        return cell
//    }

}
