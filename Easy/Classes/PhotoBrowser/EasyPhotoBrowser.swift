//
//  EasyPhotoBrowser.swift
//  Easy
//
//  Created by OctMon on 2018/11/21.
//

import UIKit
import ZLPhotoBrowser
import Photos

public extension Easy {
    typealias PhotoManager = ZLPhotoManager
    typealias PhotoActionSheet = ZLPhotoPreviewSheet
    typealias PhotoModel = ZLPhotoModel
    typealias PhotoConfiguration = ZLPhotoConfiguration
}

public extension EasyApp {
    
    static func showPhotoPick(in viewController: UIViewController, sourceTypes: [(UIImagePickerController.SourceType, String)] = [(.camera, "相机"), (.photoLibrary, "相册")], cancelTitle: String? = "取消", configurationHandler: ((Easy.PhotoConfiguration) -> Void)?, selectImageHandler: @escaping (([UIImage], [PHAsset], Bool) -> Void)) {
        let actionSheet = EasyActionSheet(title: nil)
        sourceTypes.forEach { (type, title) in
            if type == .camera && (EasyApp.isCameraAvailableFront || EasyApp.isCameraAvailableRear) || UIImagePickerController.isSourceTypeAvailable(type) {
                actionSheet.addAction(title: title, style: .default) { (_) in
                    switch type {
                    case .camera:
                        let imagePickerController = UIImagePickerController()
                        let configuration = Easy.PhotoConfiguration.default()
                        configurationHandler?(configuration)
                        imagePickerController.allowsEditing = configuration.allowEditImage
                        imagePickerController.sourceType = .camera
                        imagePickerController.delegate = PickerControllerDelegate.shared
                        PickerControllerDelegate.shared.viewController = viewController
                        PickerControllerDelegate.shared.selectImageHandler = { (image, asset) in
                            EasyApp.runInMain(handler: {
                                selectImageHandler([image], [asset] , true)
                            })
                        }
                        viewController.present(imagePickerController, animated: true, completion: nil)
                    default:
                        let photoActionSheet = Easy.PhotoActionSheet()
                        photoActionSheet.showPhotoLibrary(sender: viewController)
                        photoActionSheet.selectImageBlock = { (results, isOriginal) in
                            selectImageHandler(results.map { $0.image }, results.map { $0.asset }, isOriginal)
                        }
                    }
                }
            }
        }
        if let cancelTitle = cancelTitle {
            actionSheet.addAction(title: cancelTitle, style: .cancel) { (_) in
                
            }
        }
        actionSheet.show()
    }
    
}

private class PickerControllerDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    static var shared = PickerControllerDelegate()
    
    weak var viewController: UIViewController?
    var selectImageHandler: ((UIImage, PHAsset) -> Void)?
    
    private override init () { }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        viewController?.dismiss(animated: true, completion: nil)
        var image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        if let image = image {
            ZLPhotoManager.saveImageToAlbum(image: image, completion: { [weak self] (isSuccess, asset) in
                if let asset = asset, isSuccess {
                    self?.selectImageHandler?(image, asset)
                }
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        viewController?.dismiss(animated: true, completion: nil)
    }
}
