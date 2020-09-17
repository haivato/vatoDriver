//
//  AddImageCell.swift
//  FC
//
//  Created by vato. on 1/16/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit

class AddImageCell: UICollectionViewCell {

    var didSelectClear: ((_ sender: AddImageCell) -> Void)?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonClear: UIButton!
    
    
    @IBAction func didTouchClear(_ sender: Any) {
        self.didSelectClear?(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
