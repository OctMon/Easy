//
//  EasyPhotoBrowser.swift
//  Pods
//
//  Created by OctMon on 2018/11/21.
//

import UIKit
import ZLPhotoBrowser

public extension Easy {
    typealias PhotoBrowser = ZLPhotoBrowser
    typealias PhotoManager = ZLPhotoManager
    typealias PhotoActionSheet = ZLPhotoActionSheet
    typealias PhotoModel = ZLPhotoModel
    typealias PreviewPhotoType = ZLPreviewPhotoType
}

public extension Easy {
    
    static func PreviewPhotoGetDictFor(obj: Any, type: PreviewPhotoType) -> [AnyHashable : Any] {
        return GetDictForPreviewPhoto(obj, type)
    }
    
}
