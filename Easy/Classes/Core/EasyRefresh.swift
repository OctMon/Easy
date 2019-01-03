//
//  EasyRefresh.swift
//  Easy
//
//  Created by OctMon on 2018/10/12.
//

import UIKit

#if canImport(MJRefresh)
import MJRefresh

public extension Easy {
    typealias refresh = EasyRefresh
}

public class EasyRefresh: MJRefreshComponent {
    
    static func setHeader(_ header: MJRefreshGifHeader) {
        header.isAutomaticallyChangeAlpha = true
        header.setTitle(EasyGlobal.headerStateIdle, for: MJRefreshState.idle)
        header.setTitle(EasyGlobal.headerStatePulling, for: MJRefreshState.pulling)
        header.setTitle(EasyGlobal.headerStateRefreshing, for: MJRefreshState.refreshing)
        header.lastUpdatedTimeLabel.isHidden = true
    }
    
    static func setFooter(_ footer: MJRefreshAutoNormalFooter) {
        footer.height = EasyGlobal.footerRefreshHeight
        footer.stateLabel.textColor = EasyGlobal.footerStateLabelTextColor
        footer.stateLabel.font = EasyGlobal.footerStateLabelFont
        footer.setTitle(EasyGlobal.footerStateNoMoreData, for: MJRefreshState.noMoreData)
        footer.isRefreshingTitleHidden = true
        footer.isHidden = true
    }
    
}

public extension EasyRefresh {
    
    static func headerWithHandler(_ handler: @escaping () -> Void) -> MJRefreshGifHeader {
        let header: MJRefreshGifHeader = MJRefreshGifHeader(refreshingBlock: handler)
        setHeader(header)
        return header
    }
    
    static func footerWithHandler(_ handler: @escaping () -> Void) -> MJRefreshAutoNormalFooter {
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: handler)!
        setFooter(footer)
        return footer
    }
    
}
#endif
