//
//  ScanViewController.swift
//  Easy
//
//  Created by OctMon on 2018/10/14.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class ScanViewController: easy.BaseViewController {

    private var scanView: easy.Scan!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard app.authorizationStatusMediaTypeVideo else {
            view.showPlaceholder(attributedString: "AVCaptureDevice.authorizationStatus(for: AVMediaType.video) != .denied".getAttributedString)
            return
        }
        
        let size: CGFloat = view.frame.width * 0.7
        let x = view.frame.width * 0.5 - size * 0.5
        let y = (view.frame.height + navigationBottom) * 0.5 - size * 0.5
        
        let expansionView = UIView(frame: view.bounds)
        
        UILabel().do {
            expansionView.addSubview($0)
            $0.text = "请放入框内扫描"
            $0.textColor = UIColor.white
            $0.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(y - 50)
            }
        }
        
        scanView = easy.Scan(showInView: view, scanRect: CGRect(x: x, y: y, width: size, height: size), expansionViewHandler: { () -> UIView in
            return expansionView
        }).then {
            $0.cornerRadius = 5
            $0.strokeColor = UIColor.random
            $0.didOutput(metadataObjectsHandler: { [weak self] (metadataObjects) in
                self?.scanView.stopRunning()
                let result = metadataObjects.map { $0.type.rawValue + "\n->\n" + ($0.stringValue ?? "") }
                alert(message: result.joined(separator: "\n")).showOk({ [weak self] (_) in
                    self?.scanView.startRunning()
                })
            })
            $0.startRunning()
        }
        
        navigationItem.appendRightBarButtonItem(title: "相册") { [weak self] in
            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
                return
            }
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            self?.scanView.stopRunning()
            self?.present(picker, animated: true, completion: nil)
        }
    }

}

extension ScanViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        guard let detectorQRCode = image.detectorQRCode else {
            alert(message: "无效二维码").showOk({ [weak self] (_) in
                self?.scanView.startRunning()
            })
            return
        }
        let result = detectorQRCode.map { ($0.messageString ?? "") }
        alert(message: result.joined(separator: "\n")).showOk({ [weak self] (_) in
            self?.scanView.startRunning()
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
