//
//  FoodItemView.swift
//  FC
//
//  Created by khoi tran on 1/17/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift

class FoodItemView: UIView, EcomDisplayProductProtocol {
    typealias Value = OrderItem
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var lblNote: UILabel? {
        return subTitleLabel
    }

    private lazy var disposeBag = DisposeBag()
    
    func display(item: OrderItem) {
        numberLabel.text = "\(item.qty ?? 1)x"
        titleLabel.text = item.name
        priceLabel.text = item.basePriceIncltaxFinal?.currency
        displayDetail(item: item)
    }
}
