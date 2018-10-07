//
//  EasyGestureRecognizer.swift
//  Easy
//
//  Created by OctMon on 2018/9/28.
//

import UIKit

private class EasyTapGestureRecognizer: UITapGestureRecognizer {
    
    private var handler: ((UITapGestureRecognizer) -> Void)?
    
    @objc convenience init(numberOfTapsRequired: Int = 1, numberOfTouchesRequired: Int = 1, handler: @escaping (UITapGestureRecognizer) -> Void) {
        self.init()
        self.numberOfTapsRequired = numberOfTapsRequired
        self.numberOfTouchesRequired = numberOfTouchesRequired
        self.handler = handler
        addTarget(self, action: #selector(EasyTapGestureRecognizer.action(_:)))
    }
    
    @objc private func action(_ tapGestureRecognizer: UITapGestureRecognizer) {
        handler?(tapGestureRecognizer)
    }
    
}

private class EasyLongPressGestureRecognizer: UILongPressGestureRecognizer {
    
    private var handler: ((UILongPressGestureRecognizer) -> Void)?
    
    @objc convenience init(numberOfTapsRequired: Int = 0, numberOfTouchesRequired: Int = 1, handler: @escaping (UILongPressGestureRecognizer) -> Void) {
        self.init()
        self.numberOfTapsRequired = numberOfTapsRequired
        self.numberOfTouchesRequired = numberOfTouchesRequired
        self.handler = handler
        addTarget(self, action: #selector(EasyLongPressGestureRecognizer.action(_:)))
    }
    
    @objc private func action(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        handler?(longPressGestureRecognizer)
    }
    
}

private class EasyPanGestureRecognizer: UIPanGestureRecognizer {
    
    private var handler: ((UIPanGestureRecognizer) -> Void)?
    
    @objc convenience init(minimumNumberOfTouches: Int = 1, handler: @escaping (UIPanGestureRecognizer) -> Void) {
        self.init()
        self.minimumNumberOfTouches = minimumNumberOfTouches
        self.handler = handler
        addTarget(self, action: #selector(EasyPanGestureRecognizer.action(_:)))
    }
    
    @objc private func action(_ panGestureRecognizer: UIPanGestureRecognizer) {
        handler?(panGestureRecognizer)
    }
    
}

private class EasySwipeGestureRecognizer: UISwipeGestureRecognizer {
    
    private var handler: ((UISwipeGestureRecognizer) -> Void)?
    
    @objc convenience init(direction: UISwipeGestureRecognizer.Direction, numberOfTouchesRequired: Int = 1, handler: @escaping (UISwipeGestureRecognizer) -> Void) {
        self.init()
        self.direction = direction
        self.numberOfTouchesRequired = numberOfTouchesRequired
        self.handler = handler
        addTarget(self, action: #selector(EasySwipeGestureRecognizer.action(_:)))
    }
    
    @objc private func action(_ swipeGestureRecognizer: UISwipeGestureRecognizer) {
        handler?(swipeGestureRecognizer)
    }
    
}

private class EasyPinchGestureRecognizer: UIPinchGestureRecognizer {
    
    private var handler: ((UIPinchGestureRecognizer) -> Void)?
    
    @objc convenience init(handler: @escaping (UIPinchGestureRecognizer) -> Void) {
        self.init()
        self.handler = handler
        addTarget(self, action: #selector(EasyPinchGestureRecognizer.action(_:)))
    }
    
    @objc private func action(_ pinchGestureRecognizer: UIPinchGestureRecognizer) {
        handler?(pinchGestureRecognizer)
    }
    
}

private class EasyRotationGestureRecognizer: UIRotationGestureRecognizer {
    
    private var handler: ((UIRotationGestureRecognizer) -> Void)?
    
    @objc convenience init(handler: @escaping (UIRotationGestureRecognizer) -> Void) {
        self.init()
        self.handler = handler
        addTarget(self, action: #selector(EasyRotationGestureRecognizer.action(_:)))
    }
    
    @objc private func action(_ rotationGestureRecognizer: UIRotationGestureRecognizer) {
        handler?(rotationGestureRecognizer)
    }
    
}

public extension UIView {
    
    /// 点按
    ///
    /// - Parameters:
    ///   - numberOfTapsRequired: 手势点击数
    ///   - numberOfTouchesRequired: 手指个数
    ///   - handler: 使用 [unowned self] 或 [weak self] 避免循环引用
    /// - Returns: UITapGestureRecognizer
    @discardableResult
    func tap(numberOfTapsRequired: Int = 1, numberOfTouchesRequired: Int = 1, handler: @escaping (UITapGestureRecognizer) -> Void) -> UITapGestureRecognizer {
        isUserInteractionEnabled = true
        let tapGestureRecognizer = EasyTapGestureRecognizer(numberOfTapsRequired: numberOfTapsRequired, numberOfTouchesRequired: numberOfTouchesRequired, handler: handler)
        addGestureRecognizer(tapGestureRecognizer)
        return tapGestureRecognizer
    }
    
    /// 长按
    ///
    /// - Parameters:
    ///   - numberOfTapsRequired: 手势点击数
    ///   - numberOfTouchesRequired: 手指个数
    ///   - handler: 使用 [unowned self] 或 [weak self] 避免循环引用
    /// - Returns: UILongPressGestureRecognizer
    @discardableResult
    func longPress(numberOfTapsRequired: Int = 0, numberOfTouchesRequired: Int = 1, handler: @escaping (UILongPressGestureRecognizer) -> Void) -> UILongPressGestureRecognizer {
        isUserInteractionEnabled = true
        let longPressGestureRecognizer = EasyLongPressGestureRecognizer(numberOfTapsRequired: numberOfTapsRequired, numberOfTouchesRequired: numberOfTouchesRequired, handler: handler)
        addGestureRecognizer(longPressGestureRecognizer)
        return longPressGestureRecognizer
    }
    
    /// 拖动
    ///
    /// - Parameters:
    ///   - minimumNumberOfTouches: 最少手指个数
    ///   - handler: 使用 [unowned self] 或 [weak self] 避免循环引用
    /// - Returns: UIPanGestureRecognizer
    @discardableResult
    func pan(minimumNumberOfTouches: Int = 1, handler: @escaping (UIPanGestureRecognizer) -> Void) -> UIPanGestureRecognizer {
        isUserInteractionEnabled = true
        let longPressGestureRecognizer = EasyPanGestureRecognizer(minimumNumberOfTouches: minimumNumberOfTouches, handler: handler)
        addGestureRecognizer(longPressGestureRecognizer)
        return longPressGestureRecognizer
    }
    
    /// 轻扫，支持四个方向的轻扫，但是不同的方向要分别定义轻扫手势
    ///
    /// - Parameters:
    ///   - direction: 方向
    ///   - numberOfTouchesRequired: 手指个数
    ///   - handler: 使用 [unowned self] 或 [weak self] 避免循环引用
    /// - Returns: UISwipeGestureRecognizer
    @discardableResult
    func swipe(direction: UISwipeGestureRecognizer.Direction, numberOfTouchesRequired: Int = 1, handler: @escaping (UISwipeGestureRecognizer) -> Void) -> UISwipeGestureRecognizer {
        isUserInteractionEnabled = true
        let swpieGestureRecognizer = EasySwipeGestureRecognizer(direction: direction, numberOfTouchesRequired: numberOfTouchesRequired, handler: handler)
        addGestureRecognizer(swpieGestureRecognizer)
        return swpieGestureRecognizer
    }
    
    /// 捏合
    ///
    /// - Parameter handler: 使用 [unowned self] 或 [weak self] 避免循环引用
    /// - Returns: UIPinchGestureRecognizer
    @discardableResult
    func pinch(handler: @escaping (UIPinchGestureRecognizer) -> Void) -> UIPinchGestureRecognizer {
        isUserInteractionEnabled = true
        let pinchGestureRecognizer = EasyPinchGestureRecognizer(handler: handler)
        addGestureRecognizer(pinchGestureRecognizer)
        return pinchGestureRecognizer
    }
    
    /// 旋转
    ///
    /// - Parameter handler: 使用 [unowned self] 或 [weak self] 避免循环引用
    /// - Returns: UIRotationGestureRecognizer
    @discardableResult
    func rotation(handler: @escaping (UIRotationGestureRecognizer) -> Void) -> UIRotationGestureRecognizer {
        isUserInteractionEnabled = true
        let rotationGestureRecognizer = EasyRotationGestureRecognizer(handler: handler)
        addGestureRecognizer(rotationGestureRecognizer)
        return rotationGestureRecognizer
    }
    
}
