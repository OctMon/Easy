//
//  EasyShadowView.swift
//  Pods
//
//  Created by OctMon on 2021/4/1.
//

import UIKit

public extension Easy {
    typealias ShadowView = EasyShadowView
}

/// let shadowView = easy.ShadowView().then {
///     $0.layer.cornerRadius = imageView.layer.cornerRadius
///     contentView.insertSubview($0, belowSubview: imageView)
///     $0.snp.makeConstraints { (make) in
///         make.edges.equalTo(imageView)
///     }
/// }
public class EasyShadowView: UIView {
    private var shadowColor: UIColor?
    private var shadowOpacity: Float = 1
    private var shadowOffset: CGSize = CGSize(width: 0, height: 3)
    private var shadowRadius: CGFloat = 5

    public override func layoutSubviews() {
        super.layoutSubviews()

        updateShadow()
    }

    public func updateShadow(color: UIColor?, offset: CGSize, opacity: Float, radius: CGFloat) {
        self.shadowColor = color
        self.shadowOffset = offset
        self.shadowOpacity = opacity
        self.shadowRadius = radius

        updateShadow()
    }

    private func updateShadow() {
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: layer.cornerRadius).cgPath
    }
}

