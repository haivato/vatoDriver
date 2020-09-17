//
//  DummyRegisterService.swift
//  FC
//
//  Created by MacbookPro on 4/27/20.
//  Copyright © 2020 Vato. All rights reserved.
//
import UIKit

struct DummyRegisterService {
    let title: String
    let isCheck: Bool
    let isNew: Bool
}
struct ListServiceVehicel: Codable {
    let displayName: String?
    let isNew: Bool?
    let name: String?
    let serviceID: Int
    let status: ServiceActive?

    enum CodingKeys: String, CodingKey {
        case displayName, isNew, name
        case serviceID = "serviceId"
        case status
    }
}
enum ServiceActive: Int, Codable {
    case NOT_YET = 0
    case INIT = 1
    case APPROVE = 2
    case REJECT = 3
}
struct UrlPolicy: Codable {
    let key: String
}
struct ListRegisterService: Codable {
    let createdBy, updatedBy, createdAt, updatedAt: Int?
    let id, vehicleID, driverID, status: Int?
    let serviceIDs: [Int]

    enum CodingKeys: String, CodingKey {
        case createdBy, updatedBy, createdAt, updatedAt, id
        case vehicleID = "vehicleId"
        case driverID = "driverId"
        case serviceIDs = "serviceIds"
        case status
    }
}
