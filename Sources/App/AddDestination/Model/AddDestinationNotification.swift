//
//  AddDestinationNotification.swift
//  FC
//
//  Created by khoi tran on 3/30/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation

enum AddDestinationNotificationType: String, Codable {
    case changeDestination = "CHANGE_TRIP_DESTINATION"
}
enum AddDestinationActionType: String, Codable {
    case create = "CREATE"
    case accept = "ACCEPT"
    case reject = "REJECT"
}


struct AddDestinationNotification: Codable {
    struct PayLoad: Codable {
        let tripId: String?
        let orderId: Int?
        let status: AddDestinationActionType?
        let reason: String?
    }
    var type: AddDestinationNotificationType?
    var action: AddDestinationActionType?
    var expired_at: Double?
    var created_at: Double?
    var payload: PayLoad?
}


extension AddDestinationNotification {
    func isValid() -> Bool {
        guard let created_at = self.created_at else {
            return false
        }
        
        return Date().timeIntervalSince1970 - (created_at/1000.0) < 60
        
    }
}
