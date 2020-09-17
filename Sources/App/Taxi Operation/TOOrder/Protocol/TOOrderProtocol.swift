//  File name   : TOOrderProtocol.swift
//
//  Author      : Dung Vu
//  Created date: 2/19/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

protocol TOOrderProtocol {
    var nameLocation: String? { get }
    var distance: String? { get }
    var subTitle: String? { get }
    
    var attribute: NSAttributedString? { get }
    var pickupStationId: Int? { get }
    var firestore_listener_path: String? { get }
}


