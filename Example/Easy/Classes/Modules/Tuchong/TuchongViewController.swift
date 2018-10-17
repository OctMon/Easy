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
    
    private let space: CGFloat = 2.5

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
        
        collectionViewWaterFlowLayout.sectionSpacing = 0
        collectionViewWaterFlowLayout.minimumInteritemSpacing = space
        collectionViewWaterFlowLayout.minimumLineSpacing = space
        collectionViewWaterFlowLayout.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
        collectionView.registerReusableView(supplementaryViewType: TuchongReusableView.self, ofKind: UICollectionView.elementKindSectionHeader)
//        collectionView.registerReusableView(supplementaryViewType: UICollectionReusableView.self, ofKind: UICollectionView.elementKindSectionFooter)
        
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
                $0.label.text = "(" + indexPath.section.toString + "," + indexPath.row.toString + ")\n" + image.imgID.toStringValue
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, for: indexPath, viewType: TuchongReusableView.self)
            view.backgroundColor = UIColor.gray
            view.alpha = 0.5
            view.label.text = (self.dataSource as? [Tuchong])?[indexPath.section].tags?.joined(separator: ",")
            return view
        } else {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, for: indexPath)
            view.backgroundColor = UIColor.lightGray
            view.alpha = 0.5
            return view
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: .screenWidth - space * 2, height: 50)
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        return CGSize(width: .screenWidth - space * 2, height: 50)
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let models = dataSource as? [Tuchong] else { return CGSize.zero }
        guard let images = models[indexPath.section].images else { return CGSize.zero }
        let model = images[indexPath.row]
        var scale: CGFloat = 0.5
        var column: CGFloat = 2
        if images.count == 1 {
            scale = 1
            column = 1
        }
        let width = (app.screenWidth - (column + 1) * space) * scale
        let height = CGSize(width: model.width?.toCGFloat ?? 1, height: model.height?.toCGFloat ?? 1).calcFlowHeight(in: width)
        return CGSize(width: width, height: height)
    }
    
}

class TuchongReusableView: UICollectionReusableView {
    
    let label = UILabel().then {
        $0.textColor = UIColor.red
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.adjustsFontSizeToFitWidth = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TuchongCollectionViewCell: UICollectionViewCell {
    
    let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    let label = UILabel().then {
        $0.textColor = UIColor.red
        $0.textAlignment = .center
        $0.backgroundColor = UIColor.black
        $0.alpha = 0.5
        $0.numberOfLines = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        
        addSubview(label)
        label.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
