//
//  WaterFlowLayoutViewController.swift
//  Easy
//
//  Created by OctMon on 2018/12/3.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class WaterFlowLayoutViewController: easy.ViewController, easy.CollectionListProtocol {
    
    typealias EasyCollectionListViewAssociatedType = CollectionListView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.appendRightBarButtonItem(title: "+") { [weak self] in
            let popMenu = easy.PopMenu()
            popMenu.show(point: CGPoint(x: app.screenWidth - 120, y: self?.navigationBottom ?? 0), items: self?.collectionListView.items.map { $0.name } ?? [], completion: { [weak self] (offset) in
                guard let self = self else { return }
                self.collectionListView.current = offset
                self.request()
            })
        }

        request()
    }
    
    override func configure() {
        super.configure()
        
        addCollectionView(in: view)
    }
    
    override func request() {
        super.request()
        
        let item = collectionListView.items[collectionListView.current]
        switch item {
        case .verticalEqualWidth:
            waterFlowLayout.scrollDirection = .vertical
            waterFlowLayout.flowStyle = .equalWidth
            waterFlowLayout.flowCount = 3
        case .verticalEqualHeight:
            waterFlowLayout.scrollDirection = .vertical
            waterFlowLayout.flowStyle = .equalHeight
        case .horizontalEqualHeight:
            waterFlowLayout.scrollDirection = .horizontal
            waterFlowLayout.flowStyle = .equalHeight
            waterFlowLayout.flowCount = 5
        }
        
        collectionList = (0..<3).map { _ in (0..<20).map { _ in UIColor.random } }
        collectionListView.randoms = (0..<3).map { _ in (0..<20).map { _ in CGFloat.random(in: 50..<(.screenWidth - 30) * 0.5) } }
        collectionView.reloadData()
        collectionView.setContentOffset(.zero, animated: false)
        self.navigationItem.title = collectionListView.items[collectionListView.current].name
    }

}

extension WaterFlowLayoutViewController {
    
    class CollectionListView: easy.CollectionListView {
        
        enum ItemStyle {
            case verticalEqualWidth
            case verticalEqualHeight
            case horizontalEqualHeight
            
            var name: String {
                switch self {
                case .verticalEqualWidth:
                    return "垂直等宽"
                case .verticalEqualHeight:
                    return "垂直等高"
                case .horizontalEqualHeight:
                    return "水平等高"
                }
            }
        }
        
        let items = [ItemStyle.verticalEqualWidth, .verticalEqualHeight, .horizontalEqualHeight]
        var current = 0
        var randoms: [[CGFloat]] = []
        
        override func configure() {
            super.configure()
            
            collectionView.do {
                $0.collectionViewLayout = waterFlowLayout.then {
                    $0.flowStyle = .equalWidth
                    $0.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                    $0.minimumLineSpacing = 5
                    $0.minimumInteritemSpacing = 5
                }
                $0.registerReusableView(ofKind: UICollectionView.elementKindSectionHeader)
                $0.registerReusableView(ofKind: UICollectionView.elementKindSectionFooter)
            }
            
            register(UIColor.self, cellClass: ImageLabelCollectionViewCell.self, configureCell: { (_, cell, indexPath, color) in
                if let cell = cell as? ImageLabelCollectionViewCell {
                    cell.label.text = indexPath.description
                }
                cell.backgroundColor = color
            }, didSelectRow: nil)
            
            setSizeForItemAt { [weak self] (listView, indexPath, _) -> CGSize in
                guard let self = self else { return .zero }
                let random = self.randoms[indexPath.section][indexPath.row]
                switch self.items[self.current] {
                case .verticalEqualWidth:
                    return CGSize(width: 0, height: random)
                case .verticalEqualHeight:
                    return CGSize(width: random, height: 100)
                case .horizontalEqualHeight:
                    return CGSize(width: random, height: 100)
                }
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            if kind == UICollectionView.elementKindSectionHeader {
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, for: indexPath, viewType: UICollectionReusableView.self)
                view.backgroundColor = UIColor.gray
                view.alpha = 0.5
                return view
            } else {
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, for: indexPath, viewType: UICollectionReusableView.self)
                view.backgroundColor = UIColor.lightGray
                view.alpha = 0.5
                return view
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            return CGSize(width: 0, height: 20)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
            return CGSize(width: 0, height: 10)
        }
        
    }
    
}
