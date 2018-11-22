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

public extension EasyApp {
    
    static func showPhotoPick(in viewController: UIViewController, sourceTypes: [(UIImagePickerController.SourceType, String)] = [(.camera, "相机"), (.photoLibrary, "相册")], maxSelectCount: Int, allowsEditing: Bool = true, isAddCancelAction: Bool = true, selectImageHandler: (([UIImage], [PHAsset], Bool) -> Void)?) {
        let actionSheet = EasyActionSheet(title: nil)
        sourceTypes.forEach { (type, title) in
            if type == .camera && (EasyApp.isCameraAvailableFront || EasyApp.isCameraAvailableRear) || UIImagePickerController.isSourceTypeAvailable(type) {
                actionSheet.addAction(title: title, style: .default) { (_) in
                    switch type {
                    case .camera:
                        if let selectImageHandler = selectImageHandler {
                            let imagePickerController = UIImagePickerController()
                            imagePickerController.navigationBar.barTintColor = EasyGlobal.tint
                            imagePickerController.allowsEditing = allowsEditing
                            imagePickerController.sourceType = .camera
                            PickerControllerDelegate.shared.viewController = viewController
                            PickerControllerDelegate.shared.imageHandler = { image in
                                ZLPhotoManager.saveImage(toAblum: image, completion: { (isSuccess, asset) in
                                    if let asset = asset, isSuccess {
                                        selectImageHandler([image], [asset] , true)
                                    }
                                })
                            }
                            imagePickerController.delegate = PickerControllerDelegate.shared
                            viewController.present(imagePickerController, animated: true, completion: nil)
                        }
                    default:
                        if let selectImageHandler = selectImageHandler {
                            let photoActionSheet = Easy.PhotoActionSheet()
                            photoActionSheet.sender = viewController
                            photoActionSheet.configuration.allowEditImage = allowsEditing
                            photoActionSheet.configuration.maxSelectCount = maxSelectCount
                            photoActionSheet.configuration.maxPreviewCount = 0
                            photoActionSheet.configuration.allowTakePhotoInLibrary = false
                            photoActionSheet.showPhotoLibrary()
                            photoActionSheet.selectImageBlock = { (images, assets, isOriginal) in
                                selectImageHandler(images ?? [], assets, isOriginal)
                            }
                        }
                    }
                }
            }
        }
        if isAddCancelAction {
            actionSheet.addAction(title: "取消", style: .cancel) { (_) in
                
            }
        }
        actionSheet.show()
    }
    
}

private class PickerControllerDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    static var shared = PickerControllerDelegate()
    
    var viewController: UIViewController!
    var imageHandler: ((UIImage) -> Void)?
    
    private override init () { }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        viewController.dismiss(animated: true, completion: nil)
        var image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        if let image = image {
            imageHandler?(image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
