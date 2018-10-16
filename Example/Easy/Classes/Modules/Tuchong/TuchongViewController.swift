//
//  TuchongViewController.swift
//  Easy
//
//  Created by OctMon on 2018/10/16.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class TuchongViewController: easy.BaseViewController {
    
    private var poseID: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "图虫"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        
        if dataSource.count == 0 {
            self.view.showLoading()
            self.request()
        }
    }
    
    override func configure() {
        super.configure()
        
        firstPage = 1
        ignoreTotalPage = true
        
        appendRefresh(collectionView, isApeendHeader: true, isApeendFooter: true)
        
        collectionViewWaterFlowLayout.minimumInteritemSpacing = 5
        collectionViewWaterFlowLayout.minimumLineSpacing = 5
        collectionViewWaterFlowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        setCollectionView(numberOfSections: { () -> Int in
            return self.dataSource.count
        }) { (section) -> Int in
            return (self.dataSource as? [Tuchong])?[section].images?.count ?? 0
        }
        
        setCollectionViewRegister([TuchongCollectionViewCell.self], layout: collectionViewWaterFlowLayout, returnCell: { (_) -> AnyClass? in
            return TuchongCollectionViewCell.self
        }, configureCell: { (cell, indexPath, any) in
            guard let model = any as? Tuchong else { return }
            guard let image = model.images?[indexPath.row] else { return }
            (cell as? TuchongCollectionViewCell)?.do {
                $0.imageView.setFadeImage(url: image.imageURL, placeholderImage: UIColor.random.toImage)
            }
        }) { (indexPath, any) in
            
        }
    }
    
    override func request() {
        super.request()
        
        Tuchong.getTuchong(page: currentPage, poseId: firstPage == currentPage ? nil : poseID) { (result) in
            self.poseID = (result.models as? [Tuchong])?.last?.postID
            self.setRefresh(self.collectionView, response: result)
        }
    }

}

extension TuchongViewController {
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let models = dataSource as? [Tuchong]
        guard let model = models?[indexPath.section].images?[indexPath.row] else { return CGSize.zero }
        let width = (app.screenWidth - (2 + 1) * collectionViewWaterFlowLayout.minimumInteritemSpacing) * 0.5
        let height = CGSize(width: model.width?.toCGFloat ?? 1, height: model.height?.toCGFloat ?? 1).calcFlowHeight(in: width)
        return CGSize(width: width, height: height)
    }
    
}

class TuchongCollectionViewCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        addSubview(imageView)
        
        imageView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
}
