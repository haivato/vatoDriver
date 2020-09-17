//
//  TOShortcutTVC.swift
//  Vato
//
//  Created by khoi tran on 2/17/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import RxSwift

enum TOShortcutCellType: String, Codable {
    case normal
    case badge
}

enum TOShortCutType: String, Codable {
    case digitalClock = "list_group"
    case quickSupport = "find_driver"
    case orderTaxi = "report"
    case autoReceiveTrip = "autoReceiveTrip"
    case buyUniforms = "buy_uniforms"
    case favPlace = "favourite_place"
    case processingRequest = "processingRequest"
    case registerFood = "register_food"
    case registerService = "register_service"
}

protocol TOShortcutCellDisplay {
    
    var name: String? { get }
    var description: String? { get }
    var cellType: TOShortcutCellType { get }
    var isNew: Bool? { get }
    var badgeNumber: Int? { get }
    var icon: UIImage? { get }
}



class TOShortcutTVC: UITableViewCell, UpdateDisplayProtocol {
   
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var dotView: UIView!
    
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var lblBadgeNumber: UILabel!
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
        
        switch item.cellType {
        case .badge:
            self.dotView.isHidden = true
            if let badgeNumber = item.badgeNumber {
                self.badgeView.isHidden = !(badgeNumber > 0)
                self.lblBadgeNumber.text = (badgeNumber < 100) ? "\(badgeNumber)" : "99+"
            }
        case .normal:
            self.badgeView.isHidden = true
            let isNew = item.isNew ?? false
            self.dotView.isHidden = !isNew
        }
        self.iconView.image = item.icon
    }
    
}
