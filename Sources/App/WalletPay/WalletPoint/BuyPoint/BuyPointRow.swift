//
//  BuyPointRow.swift
//  FC
//
//  Created by admin on 5/21/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import Eureka

struct BuyPointCellModel: Equatable {
    static func == (lhs: BuyPointCellModel, rhs: BuyPointCellModel) -> Bool {
        return lhs.item.type == rhs.item.type
    }
    
    let item: TopupLinkConfigureProtocol
}

