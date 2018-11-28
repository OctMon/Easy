//
//  EasyMarqueeLabel.swift
//  Easy
//
//  Created by OctMon on 2018/11/6.
//

import UIKit

public extension Easy {
    typealias MarqueeLabel = EasyMarqueeLabel
}

public class EasyMarqueeLabel: UIView {
    
    deinit {
        EasyLog.debug(toDeinit)
    }

    private var current = 0
    private var timer: Timer?
    private var tapHandler: ((Int) -> Void)?
    
    public var automaticInterval: TimeInterval = 3
    public var dataSource: [NSAttributedString] = [] {
        didSet {
            reload()
        }
    }
    public var numberOfLines: Int = 1 {
        willSet {
            firstLabel.numberOfLines = newValue
            secondLabel.numberOfLines = newValue
        }
    }
    
    private let firstLabel = UILabel()
    private let secondLabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        
        firstLabel.frame = CGRect(x: 0, y: 0, width: width, height: height)
        addSubview(firstLabel)
        
        secondLabel.frame = CGRect(x: 0, y: height, width: width, height: height)
        addSubview(secondLabel)
        
        tap { [weak self] (_) in
            guard let self = self else { return }
            var index = 0
            if self.dataSource.count > 1 {
                if self.current == 0 {
                    index = self.dataSource.count - 1
                } else {
                    index = self.current - 1
                }
            }
            self.tapHandler?(index)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func tapClick(_ handler: @escaping (Int) -> Void) {
        tapHandler = handler
    }
    
    private func reload() {
        firstLabel.attributedText = dataSource.first
        
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
        
        guard dataSource.count > 1 else {
            return
        }
        
        current = 1
        secondLabel.attributedText = dataSource[current]
        timer = EasyApp.runLoop(seconds: automaticInterval, delay: automaticInterval) { [weak self] (_) in
            self?.loop()
        }
    }
    
    private func loop() {
        UIView.animate(withDuration: 0.75, animations: {
            if self.firstLabel.y > self.secondLabel.y {
                self.firstLabel.y = 0
                self.secondLabel.y = -self.firstLabel.height
            } else {
                self.firstLabel.y = -self.firstLabel.height
                self.secondLabel.y = 0
            }
        }) { (_) in
            var tmpLable = self.firstLabel
            if self.firstLabel.y > self.secondLabel.y {
                tmpLable = self.secondLabel
            }
            tmpLable.y = self.firstLabel.height
            
            if self.current + 1 < self.dataSource.count {
                self.current += 1
            } else if self.current + 1 == self.dataSource.count {
                self.current = 0
            }
            tmpLable.attributedText = self.dataSource[self.current]
        }
    }
    
}
