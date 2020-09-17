//
//  FavoritePlaceTableViewCell.swift
//  Vato
//
//  Created by vato. on 7/18/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import VatoNetwork
import RxSwift

class FavoritePlaceTableViewCell: UITableViewCell {
    var didselectMoreButton: ((FavoritePlaceTableViewCell) -> Void)?
    
    @IBOutlet weak var iconPlace: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var widthOfViewIcon: NSLayoutConstraint!
    @IBOutlet weak var widthOfViewAccessory: NSLayoutConstraint!
    @IBOutlet weak var buttonAccessoryMore: UIButton!
    @IBOutlet weak var viewAccessoryMore: UIView!
    
    internal lazy var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.buttonAccessoryMore.rx.tap
            .subscribe(){[weak self] event in
                guard let self = self else { return }
                self.didselectMoreButton?(self)
            }
            .disposed(by: disposeBag)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc static func newCell(reuseIdentifier: String) -> FavoritePlaceTableViewCell {
        let cell = Bundle.main.loadNibNamed(String(describing: self), owner: self, options: nil)?.first as! FavoritePlaceTableViewCell
        cell.setValue(reuseIdentifier, forKey: "reuseIdentifier")
        return cell
    }
    
    func displayData(model: PlaceModel?) {
        self.widthOfViewIcon.constant = 40
        self.titleLabel.text = model?.name
        self.subTitleLabel.text = model?.address
        if let imageName = model?.getIconName() {
            self.iconImageView.image = UIImage(named: imageName)
        }
        self.viewAccessoryMore.isHidden = false
        self.iconPlace.isHidden = !self.viewAccessoryMore.isHidden
    }
    
    func displayDataMapPlaceModel(model: MapModel.Place?) {
        self.widthOfViewIcon.constant = 0
        self.titleLabel.text = model?.primaryName
        self.subTitleLabel.text = model?.address
        self.iconImageView.image = nil
        self.widthOfViewAccessory.constant = 50
        self.viewAccessoryMore.isHidden = true
        self.iconPlace.isHidden = !self.viewAccessoryMore.isHidden
    }
    
}
