//
//  CycleViewController.swift
//  Easy
//
//  Created by OctMon on 2018/11/24.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class CycleViewController: easy.ViewController, easy.TableListProtocol {
    
    typealias EasyTableListViewAssociatedType = easy.TableListView

    override func viewDidLoad() {
        super.viewDidLoad()

        tableList = [
            ["https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1543167192007&di=37d2a71912847671ca8694f79935ba6f&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01e25259a8c8f7a8012028a99fb154.jpg%402o.jpg"
            ],
            ["https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1543167192007&di=37d2a71912847671ca8694f79935ba6f&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01e25259a8c8f7a8012028a99fb154.jpg%402o.jpg",
             "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1543167192006&di=cc6371e4176f7206607ca83e4a176ea5&imgtype=0&src=http%3A%2F%2Fpic.90sjimg.com%2Fback_pic%2Fqk%2Fback_origin_pic%2F00%2F03%2F10%2F865d85ba89d775cf8579fff62ef8ae26.jpg"
             ],
            ["https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1543167192007&di=37d2a71912847671ca8694f79935ba6f&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01e25259a8c8f7a8012028a99fb154.jpg%402o.jpg",
             "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1543167192006&di=cc6371e4176f7206607ca83e4a176ea5&imgtype=0&src=http%3A%2F%2Fpic.90sjimg.com%2Fback_pic%2Fqk%2Fback_origin_pic%2F00%2F03%2F10%2F865d85ba89d775cf8579fff62ef8ae26.jpg",
             "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1543167192007&di=78bbcd549eb0ea599eecbb2c5510c339&imgtype=0&src=http%3A%2F%2Fpic.qiantucdn.com%2F58pic%2F20%2F03%2F83%2F81k58PICefJ_1024.jpg"
             ],
            ["https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1543167192007&di=37d2a71912847671ca8694f79935ba6f&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01e25259a8c8f7a8012028a99fb154.jpg%402o.jpg",
             "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1543167192006&di=cc6371e4176f7206607ca83e4a176ea5&imgtype=0&src=http%3A%2F%2Fpic.90sjimg.com%2Fback_pic%2Fqk%2Fback_origin_pic%2F00%2F03%2F10%2F865d85ba89d775cf8579fff62ef8ae26.jpg",
             "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1543167192007&di=78bbcd549eb0ea599eecbb2c5510c339&imgtype=0&src=http%3A%2F%2Fpic.qiantucdn.com%2F58pic%2F20%2F03%2F83%2F81k58PICefJ_1024.jpg",
             "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1543167192007&di=eb8a9c957038e6c8b0b5a2a2c941a052&imgtype=0&src=http%3A%2F%2Fpic107.nipic.com%2Ffile%2F20160818%2F19565400_090859183314_2.jpg"],
            ["https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1543167192007&di=37d2a71912847671ca8694f79935ba6f&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01e25259a8c8f7a8012028a99fb154.jpg%402o.jpg",
             "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1543167192006&di=cc6371e4176f7206607ca83e4a176ea5&imgtype=0&src=http%3A%2F%2Fpic.90sjimg.com%2Fback_pic%2Fqk%2Fback_origin_pic%2F00%2F03%2F10%2F865d85ba89d775cf8579fff62ef8ae26.jpg",
             "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1543167192007&di=78bbcd549eb0ea599eecbb2c5510c339&imgtype=0&src=http%3A%2F%2Fpic.qiantucdn.com%2F58pic%2F20%2F03%2F83%2F81k58PICefJ_1024.jpg",
             "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1543167192007&di=eb8a9c957038e6c8b0b5a2a2c941a052&imgtype=0&src=http%3A%2F%2Fpic107.nipic.com%2Ffile%2F20160818%2F19565400_090859183314_2.jpg",
             "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1543231995493&di=4eae68828d839f04a812599a42ae9e94&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01946559c5b66ba801218e187b33a3.jpg%402o.jpg"
            ]
        ]
    }
    
    override func configure() {
        super.configure()
        
        addTableListView(in: view, style: .grouped)
        tableView.estimatedRowHeight = 44
        
        tableListView.setNumberOfSections({ (listView) -> Int in
            return listView.list.count
        }) { (listView, section) -> Int in
            return 1
        }
        
        tableListView.register(cellsClass: [CycleCell.self, CycleCell2.self, CycleCell3.self, CycleCell4.self], returnCell: { (_, indexPath) -> AnyClass in
            switch indexPath.section {
            case 2:
                return CycleCell2.self
            case 3:
                return CycleCell3.self
            case 4:
                return CycleCell4.self
            default:
                return CycleCell.self
            }
        }, configureCell: { (listView, cell, indexPath) in
            if let cell = cell as? CycleCell {
                let urls = listView.listTo([String].self)[indexPath.section]
                cell.cycleView.setImageURLs(urls, placeholderImage: global.tint.toImage, tap: { current in
                    log.debug(current)
                })
                cell.cycleView.timeInterval = TimeInterval(indexPath.section)
            }
            if let cell = cell as? CycleCell2 {
                cell.cycleView.pageControl.pageIndicatorTintColor = .green
                cell.cycleView.pageControl.currentPageIndicatorTintColor = .red
                cell.cycleView.pageControl.alignment = .left
                cell.cycleView.pageControl.cornerRadius = 2
            } else if let cell = cell as? CycleCell3 {
                cell.cycleView.pageControl.alignment = .right
                cell.cycleView.pageControl.pageIndicatorSize = CGSize(width: 16, height: 4)
                cell.cycleView.pageControl.currentPageIndicatorSize = CGSize(width: 32, height: 4)
            } else if let cell = cell as? CycleCell4 {
                cell.cycleView.pageControl.spacing = 15
                cell.cycleView.pageControl.pageIndicatorSize = CGSize(width: 16, height: 16)
                cell.cycleView.pageControl.pageIndicatorImage = #imageLiteral(resourceName: "icon_pageIndicatorImage")
                cell.cycleView.pageControl.currentPageIndicatorImage = #imageLiteral(resourceName: "icon_currentPageIndicatorImage")
            }
        }, didSelectRow: nil)
    }

}

extension CycleViewController {
    
    class CycleCell: UITableViewCell {
        
        let cycleView = easy.CycleView()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            contentView.addSubview(cycleView)
            cycleView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
                make.height.equalTo(150).priority(.high)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    class CycleCell2: CycleCell {
        
    }
    
    class CycleCell3: CycleCell {
        
    }
    
    class CycleCell4: CycleCell {
        
    }
    
}
