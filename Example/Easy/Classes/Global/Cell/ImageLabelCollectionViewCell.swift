//
//  ImageLabelCollectionViewCell.swift
//  Easy
//
//  Created by OctMon on 2018/11/26.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class ImageLabelCollectionViewCell: UICollectionViewCell {
    
    let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    let label = UILabel().then {
        $0.textColor = .red
        $0.textAlignment = .center
        $0.backgroundColor = .black
        $0.alpha = 0.5
        $0.numberOfLines = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        
        contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
