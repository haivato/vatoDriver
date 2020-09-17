//
//  RequestFailCollectionViewCell.swift
//  FC
//
//  Created by vato. on 2/19/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit

class RequestFailCollectionViewCell: UICollectionViewCell, UpdateDisplayProtocol {
    var didSelectButton: ((_ type: MarketingPointButtonType, TaxiOperationDisplay) -> Void)?
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var operatorNameLabel: UILabel!
    @IBOutlet private weak var reasonLabel: UILabel!
    private var currentItem: TaxiOperationDisplay?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func didTouchClear(_ sender: Any) {
        guard let currentItem = currentItem else { return }
        didSelectButton?(.clear, currentItem)
    }
    
    func setupDisplay(item: TaxiOperationDisplay?) {
        currentItem = item
        titleLabel.text = "Xếp tài \(item?.stationName ?? "") thất bại"
        operatorNameLabel.text = item?.operator_name
        reasonLabel.text = item?.reason
    }

}
