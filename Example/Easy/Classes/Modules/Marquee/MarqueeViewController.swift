//
//  MarqueeViewController.swift
//  Easy
//
//  Created by OctMon on 2018/11/6.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class MarqueeViewController: easy.ViewController {

    private var marqueeLabel: easy.MarqueeLabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        marqueeLabel.numberOfLines = 2
        marqueeLabel.dataSource = ["全新 Liquid 视网膜显示屏，是 iPhone 迄今最先进的 LCD 屏。此外，更有识别速度进一步提升的面容 ID、iPhone 史上最智能最强大的芯片，以及支持景深控制功能的突破性摄像头系统。iPhone XR，怎么看，都满是亮点。", "To run the example project, clone the repo, and run pod install from the Example directory first.", "Easy is available through CocoaPods", "Easy is available under the MIT license. See the LICENSE file for more info."].map { $0.getAttributedString(font: UIFont.size14, foregroundColor: UIColor.random) }
        marqueeLabel.tapClick { (index) in
            log.debug(index)
        }
        
        collectionViewDataSource = marqueeLabel.dataSource
    }
    
    override func configure() {
        super.configure()
        
        addTableView(style: .grouped, inView: view)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: .screenWidth, height: 200)).then {
            $0.backgroundColor = UIColor.gray
            marqueeLabel = easy.MarqueeLabel(frame: CGRect(x: 15, y: 0, width: $0.width - 30, height: 40))
            $0.addSubview(marqueeLabel)
            
            addCollectionView(layout: collectionViewWaterFlowLayout, inView: $0)
            collectionView.snp.remakeConstraints({ (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0))
            })
        }
        
        collectionViewWaterFlowLayout.minimumInteritemSpacing = 0
        collectionViewWaterFlowLayout.minimumLineSpacing = 0
        
        setCollectionViewRegister(UICollectionViewCell.self, configureCell: { (cell, _, _) in
            cell.backgroundColor = UIColor.random
        }) { (_, any) in
            log.debug(any)
        }
    }

}
