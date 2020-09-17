//  File name   : ChooseStationTVC.swift
//
//  Author      : Dung Vu
//  Created date: 9/20/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import FwiCore
import UIKit

final class ChooseStationTVC: UITableViewCell, UpdateDisplayProtocol {
    /// Class's public properties.
    @IBOutlet weak var lblName: UILabel?
    @IBOutlet weak var viewSelect: UIView?
    @IBOutlet weak var imageSelected: UIImageView!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    /// Class's private properties.
    
    func setupDisplay(item: FoodExploreItem?) {
        lblName?.text = item?.name
        subTitleLabel?.text = item?.address
        distance.text = item?.distance
    }
}

// MARK: Class's public methods
extension ChooseStationTVC {
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        localize()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        viewSelect?.isHidden = !selected
        imageSelected?.isHidden = !selected
    }
}

// MARK: Class's private methods
private extension ChooseStationTVC {
    private func localize() {
        // todo: Localize view's here.
    }
}
