//
//  PhotoBrowserViewController.swift
//  Easy
//
//  Created by OctMon on 2018/11/21.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class PhotoBrowserViewController: easy.ViewController, easy.CollectionListProtocol {
    
    typealias EasyCollectionListViewAssociatedType = easy.CollectionListView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.appendRightBarButtonItem(title: "📷") { [weak self] in
            let photoActionSheet = easy.PhotoActionSheet()
            photoActionSheet.sender = self
            photoActionSheet.showPreview(animated: true)
            photoActionSheet.selectImageBlock = { (images, assets, _) in
                self?.collectionList = images ?? []
                self?.collectionView.reloadData()
            }
        }
    }
    
    override func configure() {
        super.configure()
        
        addCollectionView(in: view)
        
        let space: CGFloat = 2.5
        waterFlowLayout.do {
            $0.sectionSpacing = 0
            $0.minimumInteritemSpacing = space
            $0.minimumLineSpacing = space
            $0.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
        }
        collectionView.do {
            $0.collectionViewLayout = waterFlowLayout
        }
        
        collectionListView.register(UIImage.self, cellClass: TuchongCollectionViewCell.self, configureCell: { (_, cell, _, image) in
            if let cell = cell as? TuchongCollectionViewCell {
                cell.imageView.image = image
            }
        }) { (listView, indexPath, image) in
            let photoActionSheet = easy.PhotoActionSheet()
            photoActionSheet.sender = self
            let photos = listView.list.map({ (any) -> [AnyHashable : Any] in
                return easy.PreviewPhotoGetDictFor(obj: any, type: easy.PreviewPhotoType.uiImage)
            })
            photoActionSheet.previewPhotos(photos, index: indexPath.row, hideToolBar: true, complete: { (any) in
                
            })
        }
        
        collectionListView.setSizeForItemAt(UIImage.self) { (_, _, image) -> CGSize in
            let imageWidth = (app.screenWidth - space * 3) / 2
            let imageHeight = CGSize(width: image.size.width, height: image.size.height).calcFlowHeight(in: imageWidth)
            return CGSize(width: imageWidth, height: imageHeight)
        }
    }

}
