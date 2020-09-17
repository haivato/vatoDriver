//
//  TOShortcutAutoReceiveTripTVC.swift
//  Vato
//
//  Created by khoi tran on 2/17/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import RxSwift
class TOShortcutAutoReceiveTripTVC: UITableViewCell, UpdateDisplayProtocol {
    var didSelectswitch: ((_ switchOnOff: UISwitch?) -> Void)?
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var switchOnOff: UISwitch!
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var descriptionView: UIView!
    private lazy var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupDisplayIndex(index: IndexPath) {
        self.containerView?.backgroundColor = index.row % 2 == 0 ? UIColor.white : UIColor(red: 255.0/255.0, green: 246.0/255.0, blue: 244/255.0, alpha: 1.0)
    }
    
    func setupDisplay(item: TOShortcutCellDisplay?) {
        
        guard let item = item else { return }
        self.lblName.text = item.name
        
        if let description = item.description, !description.isEmpty {
            self.lblDescription.text = item.description
            self.descriptionView.isHidden = false
        } else {
            self.descriptionView.isHidden = true
        }
        self.iconView.image = item.icon
    }
    
    @IBAction func didTouchSwitch(_ sender: Any) {
        didSelectswitch?(switchOnOff)
    }
    
    
}
