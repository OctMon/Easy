//
//  TuchongViewController.swift
//  Easy
//
//  Created by OctMon on 2018/10/16.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class TuchongViewController: easy.ViewController {
    
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
        
        setCollectionView(numberOfSections: { [weak self] () -> Int in
            return self?.dataSource.count ?? 0
        }) { [weak self] (section) -> Int in
            return (self?.dataSource as? [Tuchong])?[section].images?.count ?? 0
        }
        
        setCollectionViewRegister(TuchongCollectionViewCell.self, layout: collectionViewWaterFlowLayout, configureCell: { [weak self] (cell, indexPath, _) in
            guard let image = self?.getImage(indexPath) else { return }
            (cell as? TuchongCollectionViewCell)?.do {
                $0.imageView.setFadeImage(url: image.imageURL, placeholderImage: UIColor.random.toImage)
                $0.label.text = "(" + indexPath.section.toString + "," + indexPath.row.toString + ")\n" + image.imgID.toStringValue
            }
        }, didSelectRow: nil)
    }
    
    private func getImage(_ indexPath: IndexPath) -> Tuchong.Image? {
        return (self.dataSource as? [Tuchong])?[indexPath.section].images?[indexPath.row]
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoView = UIView(frame: app.screenBounds).then {
            let imageView = UIImageView(frame: app.screenBounds).then {
                $0.backgroundColor = UIColor.black
                $0.contentMode = .scaleAspectFit
                $0.setFadeImage(url: self.getImage(indexPath)?.imageURL ?? "", placeholderImage: nil)
            }
            $0.addSubview(imageView)
            let button = UIButton(frame: CGRect(x: app.screenWidth - 80 - 30, y: app.screenHeight - device.safeBottomEdge - 50, width: 80, height: 44)).then {
                $0.setTitle("保存", for: .normal)
                $0.setBackgroundImage(easy.Global.tint.toImage, cornerRadius: 5)
                $0.setTitleColor(UIColor.white, for: .normal)
                $0.alpha = 0.5
            }
            $0.addSubview(button)
            button.tap(handler: { (gesture) in
                if let image = imageView.image, gesture.state == .ended {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    button.setTitle("保存成功", for: .normal)
                    button.isEnabled = false
                }
            })
        }
        let popupView = easy.PopupView(photoView)
        photoView.tap { (_) in
            popupView.dismiss()
        }
        popupView.showWithCenter()
    }
    
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
