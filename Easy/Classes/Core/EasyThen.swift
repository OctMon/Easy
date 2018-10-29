//
//  EasyThen.swift
//  Pods
//
//  Created by OctMon on 2018/10/29.
//

import UIKit

public extension Easy {
    typealias Then = EasyThen
}

public protocol EasyThen {}

public extension EasyThen where Self: Any {
    
    /**
     ```
     let frame = CGRect().with {
     $0.origin.x = 10
     $0.size.width = 100
     }
     ```
     */
    func with(_ block: (inout Self) throws -> Void) rethrows -> Self {
        var copy = self
        try block(&copy)
        return copy
    }
    
    /**
     ```
     UserDefaults.standard.do {
     $0.set("octmon", forKey: "username")
     $0.set("octmon@qq.com", forKey: "email")
     $0.synchronize()
     }
     ```
     */
    func `do`(_ block: (Self) throws -> Void) rethrows {
        try block(self)
    }
    
}

public extension EasyThen where Self: AnyObject {
    
    /**
     ```
     let label = UILabel().then {
     $0.textAlignment = .center
     $0.textColor = UIColor.black
     $0.text = "Hello, World!"
     }
     ```
     */
    func then(_ block: (Self) throws -> Void) rethrows -> Self {
        try block(self)
        return self
    }
    
}

extension NSObject: EasyThen {}

extension CGPoint: EasyThen {}
extension CGRect: EasyThen {}
extension CGSize: EasyThen {}
extension CGVector: EasyThen {}

extension UIEdgeInsets: EasyThen {}
extension UIOffset: EasyThen {}
extension UIRectEdge: EasyThen {}
