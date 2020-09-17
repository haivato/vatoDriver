//
//  AddDestinationRequestDetail.swift
//  FC
//
//  Created by khoi tran on 3/30/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation


struct AddDestinationRequestDetail: Codable {
    struct Address: Codable {
        let address: String?
        let lat: Double?
        let lon: Double?
    }
    
    let additionPrice: Int?
    let createdAt: String?
    let createdBy: Double?
    let distance: Double?
    let driverId: Int?
    
    let duration: Int?
    let expiredAt: String?
    let fare: Int?
    let fee: Int?
    let id: Int?
    let organizationId: Int?
    let points:[Address]?
    
    let reason: String?
    let status: String?
    let tripId: String?
    let updatedAt: String?
    let updatedBy: Double?
}
