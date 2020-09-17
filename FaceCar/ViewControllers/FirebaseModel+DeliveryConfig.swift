//
//  DeliveryConfig.swift
//  FC
//
//  Created by THAI LE QUANG on 8/21/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

extension FirebaseModel {
    struct DeliveryConfig: Codable, ModelFromFireBaseProtocol {
        let delivery_fail_reasons: [String]?
        let trip_canceled_reasons: [String]?
        
        /// Codable's keymap.
    }
}
