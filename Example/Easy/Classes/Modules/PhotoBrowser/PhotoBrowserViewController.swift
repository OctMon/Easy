//
//  PhotoBrowserViewController.swift
//  Easy
//
//  Created by OctMon on 2018/11/21.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class PhotoBrowserViewController: easy.ViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.showPlaceholder(attributedString: "点我".getAttributedString) { [weak self] in
            guard let `self` = self else { return }
            let photoActionSheet = easy.PhotoActionSheet()
            photoActionSheet.sender = self
            photoActionSheet.showPreview(animated: animated)
            photoActionSheet.selectImageBlock = { (_, assets, _) in
                log.debug(easy.PhotoManager.requestAssetFileUrl(assets[0], complete: { (fileUrl) in
                    log.debug(fileUrl)
                }))
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func configure() {
        super.configure()
        
        
    }

}
