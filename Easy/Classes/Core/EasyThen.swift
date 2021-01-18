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
    
    @inlinable
    func with(_ block: (inout Self) throws -> Void) rethrows -> Self {
        var copy = self
        try block(&copy)
        return copy
    }
    
    @inlinable
    func `do`(_ block: (Self) throws -> Void) rethrows {
        try block(self)
    }
    
}

public extension EasyThen where Self: AnyObject {
    
    @inlinable
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

extension Array: EasyThen {}
extension Dictionary: EasyThen {}
extension Set: EasyThen {}

extension UIEdgeInsets: EasyThen {}
extension UIOffset: EasyThen {}
extension UIRectEdge: EasyThen {}
