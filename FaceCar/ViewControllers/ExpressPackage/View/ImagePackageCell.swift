//
//  ImagePackageCell.swift
//  FC
//
//  Created by vato. on 8/21/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

class ImagePackageCell: UICollectionViewCell {
    var didSelectClear: ((_ sender: ImagePackageCell) -> Void)?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonClear: UIButton!
    
    
    @IBAction func didTouchClear(_ sender: Any) {
        self.didSelectClear?(self)
    }
}
