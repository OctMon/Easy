//
//  MarqueeViewController.swift
//  Easy
//
//  Created by OctMon on 2018/11/6.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class MarqueeViewController: easy.ViewController, easy.TableListProtocol, easy.CollectionListProtocol {
    
    typealias EasyTableListViewAssociatedType = easy.TableListView
    typealias EasyCollectionListViewAssociatedType = CollectionListView

    private var marqueeLabel: easy.MarqueeLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        marqueeLabel.numberOfLines = 2
        marqueeLabel.dataSource = ["全新 Liquid 视网膜显示屏，是 iPhone 迄今最先进的 LCD 屏。此外，更有识别速度进一步提升的面容 ID、iPhone 史上最智能最强大的芯片，以及支持景深控制功能的突破性摄像头系统。iPhone XR，怎么看，都满是亮点。", "To run the example project, clone the repo, and run pod install from the Example directory first.", "Easy is available through CocoaPods", "Easy is available under the MIT license. See the LICENSE file for more info."].map { $0.getAttributedString(font: UIFont.size14, foregroundColor: UIColor.random) }
        marqueeLabel.tapClick { (index) in
            log.debug(index)
        }
        
        tableList = marqueeLabel.dataSource
        collectionList = marqueeLabel.dataSource
    }
    
    override func configure() {
        super.configure()
        
        addTableListView(in: view, style: .plain)
        
        tableView.do {
            $0.estimatedRowHeight = 88
            $0.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: .screenWidth, height: 40)).then {
                $0.backgroundColor = UIColor.gray
                marqueeLabel = easy.MarqueeLabel(frame: CGRect(x: 15, y: 0, width: $0.width - 30, height: 40))
                $0.addSubview(marqueeLabel)
            }
            let tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: .screenWidth, height: .screenWidth * 0.25))
            addCollectionView(in: tableFooterView)
            $0.tableFooterView = tableFooterView
        }
        
        tableListView.do {
            $0.register(NSAttributedString.self, cellClass: UITableViewCell.self, configureCell: { (_, cell, _, any) in
                cell.textLabel?.do {
                    $0.numberOfLines = 0
                    $0.attributedText = any
                }
            }, didSelectRow: nil)
        }
    }

}

extension MarqueeViewController {
    
    class CollectionListView: easy.CollectionListView {
        
        override func configure() {
            super.configure()
            
            waterFlowLayout.do {
                $0.minimumInteritemSpacing = 0
                $0.minimumLineSpacing = 0
            }
            collectionView.collectionViewLayout = waterFlowLayout
            
            register(cellClass: UICollectionViewCell.self, configureCell: { (_, cell, _, _) in
                cell.backgroundColor = UIColor.random
            }) { (_, _, any) in
                log.debug(any)
            }
            
            setSizeForItemAt(NSAttributedString.self) { (_, _, _) -> CGSize in
                return CGSize(width: .screenWidth * 0.25, height: .screenWidth * 0.25)
            }
            
        }
        
    }

}
