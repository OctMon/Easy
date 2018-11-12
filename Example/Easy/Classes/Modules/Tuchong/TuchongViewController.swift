//
//  TuchongViewController.swift
//  Easy
//
//  Created by OctMon on 2018/10/16.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

private let space: CGFloat = 2.5

class TuchongViewController: easy.ViewController, easy.CollectionListProtocol {
    
    typealias EasyCollectionListViewAssociatedType = TuchongCollectionListView
    
    private var poseID: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "图虫"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        
        if collectionViewListView.collectionViewDataSource.count == 0 {
            self.collectionViewListView.showLoading()
            self.request()
        }
    }
    
    override func configure() {
        super.configure()
        
        addCollectionView(in: view)
        collectionViewListView.addRefresh(isAddHeader: true, isAddFooter: true) { [weak self] in
            self?.request()
        }
    }
    
    override func request() {
        super.request()
        
        Tuchong.getTuchong(page: collectionViewListView.currentPage, poseId: collectionViewListView.firstPage == collectionViewListView.currentPage ? nil : poseID) { (result) in
            self.poseID = (result.models as? [Tuchong])?.last?.postID
            self.collectionViewListView.setRefresh(response: result)
        }
    }

}

class TuchongCollectionListView: easy.CollectionListView {
    
    override func configure() {
        super.configure()
        
        firstPage = 1
        ignoreTotalPage = true
        
        collectionViewWaterFlowLayout.do {
            $0.sectionSpacing = 0
            $0.minimumInteritemSpacing = space
            $0.minimumLineSpacing = space
            $0.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
        }
        
        collectionView.do {
//            $0.registerReusableCell(TuchongCollectionViewCell.self)
            $0.registerReusableView(supplementaryViewType: TuchongReusableView.self, ofKind: UICollectionView.elementKindSectionHeader)
            $0.registerReusableView(supplementaryViewType: TuchongReusableView.self, ofKind: UICollectionView.elementKindSectionFooter)
            collectionView.collectionViewLayout = collectionViewWaterFlowLayout
        }
        
        setCollectionView(numberOfSections: { (listView) -> Int in
            return listView.collectionViewDataSource.count
        }) { (listView, section) -> Int in
            return listView.collectionViewToDataSource(Tuchong.self)[section].images?.count ?? 0
        }
        
        setCollectionViewRegister(Tuchong.self, cellClass: TuchongCollectionViewCell.self, configureCell: { (cell, indexPath, any) in
            (cell as? TuchongCollectionViewCell)?.do {
                guard let image = any.images?[indexPath.row] else { return }
                $0.imageView.setFadeImage(url: image.imageURL, placeholderImage: UIColor.random.toImage)
                $0.label.text = "(" + indexPath.section.toString + "," + indexPath.row.toString + ")\n" + image.imgID.toStringValue
            }
        }) { (indexPath, any) in
            let photoView = UIView(frame: app.screenBounds).then {
                let imageView = UIImageView(frame: app.screenBounds).then {
                    $0.backgroundColor = UIColor.black
                    $0.contentMode = .scaleAspectFit
                    $0.setFadeImage(url: any.images?[indexPath.row].imageURL ?? "", placeholderImage: nil)
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
        
        setCollectionViewSizeForItemAt(Tuchong.self) { (indexPath, any) -> CGSize in
            guard let images = any.images else { return CGSize.zero }
            let model = images[indexPath.row]
            return images.count > 1 ? model.imageSize : CGSize(width: .screenWidth - space * 3, height: .screenWidth - space * 3)
        }
    }
    
    /*private func getImage(_ indexPath: IndexPath) -> Tuchong.Image? {
        return (collectionViewDataSource as? [Tuchong])?[indexPath.section].images?[indexPath.row]
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collectionViewDataSource.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (collectionViewDataSource as? [Tuchong])?[section].images?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let image = self.getImage(indexPath) else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(for: indexPath, with: TuchongCollectionViewCell.self)
        cell.do {
            $0.imageView.setFadeImage(url: image.imageURL, placeholderImage: UIColor.random.toImage)
            $0.label.text = "(" + indexPath.section.toString + "," + indexPath.row.toString + ")\n" + image.imgID.toStringValue
        }
        return cell
    }
    
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
     
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let models = collectionViewDataSource as? [Tuchong] else { return CGSize.zero }
        guard let images = models[indexPath.section].images else { return CGSize.zero }
        let model = images[indexPath.row]
        return images.count > 1 ? model.imageSize : CGSize(width: .screenWidth - space * 3, height: .screenWidth - space * 3)
    }*/
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, for: indexPath, viewType: TuchongReusableView.self)
            view.backgroundColor = UIColor.gray
            view.alpha = 0.5
            view.label.text = (collectionViewToDataSource(Tuchong.self))[indexPath.section].tags?.joined(separator: ",")
            return view
        } else {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, for: indexPath, viewType: TuchongReusableView.self)
            view.backgroundColor = UIColor.lightGray
            view.alpha = 0.5
            view.label.text = (collectionViewToDataSource(Tuchong.self))[indexPath.section].excerpt
            return view
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: .screenWidth - space * 2, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: .screenWidth - space * 2, height: 50)
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
