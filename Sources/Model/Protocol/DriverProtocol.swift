//  File name   : DriverProtocol.swift
//
//  Author      : Dung Vu
//  Created date: 2/24/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

@objc
protocol VatoDriverProtocol: NSObjectProtocol {
    var firebaseId: String? { get }
    var userId: UInt64 { get }
    var serviceId: Int { get }
    var serviceName: String? { get }
    var actived: Bool { get }
    var plate: String? { get }
    var taxiBrandId: UInt64 { get }
    var services: [Int] {get}
    var marketName: String? {get}
}

extension VatoDriverProtocol {
    var taxiDriver: Bool {
        let lisetServicesTaxi = services.filter { (value) -> Bool in
            return value == 32 || value == 64 || value == 96
        }
        return actived && lisetServicesTaxi.count > 0
    }

}


