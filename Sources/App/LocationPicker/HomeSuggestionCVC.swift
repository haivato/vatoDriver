//  File name   : HomeSuggestionCVC.swift
//
//  Author      : Vato
//  Created date: 9/17/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import SnapKit
import UIKit

final class HomeSuggestionCVC: UICollectionViewCell {
    /// Class's public properties.
    private(set) lazy var iconImageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 24.0, height: 24.0))
    private(set) lazy var titleLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 40.0))

    /// Class's private properties.
}

// MARK: Class's public methods
extension HomeSuggestionCVC {
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        visualize()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        localize()
    }
    
    func configure(with item: PlaceModel, fontTitle: UIFont) {
        self.titleLabel.text = item.name
        self.iconImageView.image = UIImage(named: item.getIconName())
        self.titleLabel.font = fontTitle
        
        self.titleLabel.textColor = Color.greyishBrown
        
        if item.typeId == .AddNew {
            self.iconImageView.tintColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
            self.titleLabel.textColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
        }
        
    }
}

// MARK: Class's private methods
private extension HomeSuggestionCVC {
    private func localize() {
        // todo: Localize view's here.
    }

    private func visualize() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)

        self.borderWidth = 0.5
        self.cornerRadius = 20
        self.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2)
        self.backgroundColor = .white
        
        iconImageView.snp.updateConstraints { make in
            make.leading.equalTo(self).offset(12)
            make.centerY.equalTo(self)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        
        titleLabel.snp.updateConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(8)
            make.right.equalTo(self).offset(-20.0)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
        }
    }
}
