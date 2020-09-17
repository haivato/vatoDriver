//
//  DriverBalance.swift
//  FC
//
//  Created by MacbookPro on 5/28/20.
//  Copyright © 2020 Vato. All rights reserved.
//

struct DriverBalance: Codable {
    let credit, creditPending, hardCash, hardCashPending : Double
    enum CodingKeys: String, CodingKey {
        case credit, creditPending, hardCash, hardCashPending
    }
    
}
