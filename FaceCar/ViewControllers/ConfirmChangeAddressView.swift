//
//  ConfirmChangeAddressView.swift
//  FC
//
//  Created by khoi tran on 3/26/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation


class ConfirmChangeAddressView: UIView, AlertApplyStyleProtocol, UpdateDisplayProtocol {
    
    @IBOutlet private weak var lblReason: UILabel!
    @IBOutlet private weak var lblOldAddress: UILabel!
    @IBOutlet private weak var lblNewAddress: UILabel!
    @IBOutlet private weak var lblOldPrice: UILabel!
    @IBOutlet private weak var lblNewPrice: UILabel!
    
    func apply(view: UIView) {}
    
    func updateOldPriceView(oldPrice: String?) {
        lblOldPrice.text = oldPrice
    }
    
    func setupDisplay(item: AddDestinationRequestDetail?) {
        guard let item = item else { return }
        
        lblReason.text = item.reason
        lblNewPrice.text = item.fare?.currency
        
        
        lblOldAddress.text = item.points?.first?.address
        lblNewAddress.text = item.points?.last?.address
    }
    
}




