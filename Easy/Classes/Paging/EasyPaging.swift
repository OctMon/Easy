//
//  EasyPaging.swift
//  Easy
//
//  Created by OctMon on 2018/10/27.
//

import UIKit
import PagingKit

public extension Easy {
    typealias Paging = EasyPaging
}

public struct EasyPaging {
    private init() {}
}

public extension Easy.Paging {
    typealias MenuView = PagingMenuView
    typealias MenuViewController = PagingMenuViewController
    typealias ContentViewController = PagingContentViewController
    typealias MenuViewCell = PagingMenuViewCell
    typealias MenuViewTitleLabelCell = TitleLabelMenuViewCell
}

public extension EasyBaseViewController {
    
    private static var sizingCell = TitleLabelMenuViewCell(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    
    func setPaging(dataSource: [(menu: String, content: UIViewController)]) {
        pagingDataSource = dataSource
        
        pagingMenuViewController.register(type: TitleLabelMenuViewCell.self, forCellWithReuseIdentifier: TitleLabelMenuViewCell.toString)
        pagingMenuViewController.registerFocusView(view: UnderlineFocusView())
        
        pagingMenuViewController.reloadData()
        pagingContentViewController.reloadData()
    }
    
}

extension EasyBaseViewController: PagingMenuViewControllerDataSource, PagingMenuViewControllerDelegate {
    
    open func numberOfItemsForMenuViewController(viewController: PagingMenuViewController) -> Int {
        return pagingDataSource.count
    }
    
    open func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: TitleLabelMenuViewCell.toString, for: index)  as! TitleLabelMenuViewCell
        cell.titleLabel.text = pagingDataSource[index].menu
        return cell
    }
    
    open func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
        EasyBaseViewController.sizingCell.titleLabel.text = pagingDataSource[index].menu
        var referenceSize = UIView.layoutFittingCompressedSize
        referenceSize.height = viewController.view.bounds.height
        let size = EasyBaseViewController.sizingCell.systemLayoutSizeFitting(referenceSize)
        return size.width
    }
    
    open func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        pagingContentViewController.scroll(to: page, animated: true)
    }
    
}

extension EasyBaseViewController: PagingContentViewControllerDataSource, PagingContentViewControllerDelegate {
    
    open func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return pagingDataSource.count
    }
    
    open func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        return pagingDataSource[index].content
    }
    
    open func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        pagingMenuViewController.scroll(index: index, percent: percent, animated: false)
    }
    
}
