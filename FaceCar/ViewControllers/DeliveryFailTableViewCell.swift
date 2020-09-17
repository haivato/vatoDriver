//
//  DeliveryFailTableViewCell.swift
//  FC
//
//  Created by THAI LE QUANG on 8/21/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

class DeliveryFailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgCheck.image = UIImage(named: "ic_check-1")
        lblTitle.text = nil
    }
    
    @objc static func newCell(reuseIdentifier: String) -> DeliveryFailTableViewCell {
        let cell = Bundle.main.loadNibNamed(String(describing: self), owner: self, options: nil)?.first as! DeliveryFailTableViewCell
        cell.setValue(reuseIdentifier, forKey: "reuseIdentifier")
        return cell
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        imgCheck?.image = self.isSelected ? UIImage(named: "ic_check-1") : UIImage(named: "ic_uncheck-1")
    }
    
    func visulizeCell(with item: String?) {
        lblTitle.text = item
    }
}
