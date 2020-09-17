//
//  TaxiRequestSuccess.swift
//  FC
//
//  Created by vato. on 2/20/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation

class TaxiRequestSuccess: UIView {
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var indexLabel: UILabel?
    
    func display(item: TaxiOperationDisplay) {
        self.titleLabel?.text = "Xếp tài \(item.stationName ?? "") thành công"
        self.indexLabel?.text = "\(item.queue ?? "Hàng đợi") - #\(item.orderNumber ?? 1)"
    }
}
