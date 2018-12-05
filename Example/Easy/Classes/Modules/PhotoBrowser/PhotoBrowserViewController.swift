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
        
        navigationItem.appendRightBarButtonTitleItem("📷") { [weak self] in
            guard let self = self else { return }
            app.showPhotoPick(in: self, configurationHandler: { configuration in
                configuration.maxSelectCount = Int.max
                configuration.allowEditImage = true
            }, selectImageHandler: { [weak self] (images, assets, isOriginal) in
                self?.collectionList = images
                self?.collectionView.reloadData()
            })
        }
    }
    
    override func configure() {
        super.configure()
        
        addCollectionView(in: view)
        
        let space: CGFloat = 2.5
        waterFlowLayout.do {
            $0.minimumInteritemSpacing = space
            $0.minimumLineSpacing = space
            $0.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
        }
        collectionView.do {
            $0.collectionViewLayout = waterFlowLayout
        }
        
        collectionListView.register(UIImage.self, cellClass: ImageLabelCollectionViewCell.self, configureCell: { (_, cell, _, image) in
            if let cell = cell as? ImageLabelCollectionViewCell {
                cell.imageView.image = image
            }
        }) { [weak self] (listView, indexPath, image) in
            let photoActionSheet = easy.PhotoActionSheet()
            photoActionSheet.sender = self
            let photos = listView.list.map({ (any) -> [AnyHashable : Any] in
                return easy.PreviewPhotoGetDictFor(obj: any, type: easy.PreviewPhotoType.uiImage)
            })
            photoActionSheet.previewPhotos(photos, index: indexPath.row, hideToolBar: true, complete: { (any) in
                
            })
        }
        
        collectionListView.setSizeForItemAt(UIImage.self) { (_, _, image) -> CGSize in
            return CGSize(width: 0, height: CGSize(width: image.size.width, height: image.size.height).calcFlowHeight(in: (app.screenWidth - space * 3) / 2))
        }
    }

}
