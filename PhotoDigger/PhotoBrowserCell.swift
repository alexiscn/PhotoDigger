//
//  PhotoBrowserCell.swift
//  PhotoDigger
//
//  Created by xu.shuifeng on 07/03/2018.
//  Copyright © 2018 shuifeng.me. All rights reserved.
//

import UIKit
import Photos

class PhotoBrowserCell: UICollectionViewCell {
    
    let imageView: UIImageView
    
    var assetIdentifier: String
    
    override init(frame: CGRect) {
        imageView = UIImageView(frame: CGRect(origin: .zero, size: frame.size))
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        assetIdentifier = ""
        super.init(frame: frame)
        backgroundView = imageView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
