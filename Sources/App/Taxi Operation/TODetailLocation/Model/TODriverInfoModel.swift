//
//  TODriverInfo.swift
//  Vato
//
//  Created by khoi tran on 2/18/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation

enum VatoServiceType: Int, Codable, CaseIterable {
    case none = 0
    case car = 1
    case carPlus = 2
    case car7 = 4
    case moto = 8
    case motoPlus = 16
    case taxi = 32
    case taxi7 = 64
    case delivery = 128
    case buyTicket = 256
    case taxiAll = 96
}

enum TODriverSectionType: Int {
    case ready = 0
    case waiting
    
    case none
    func headerString(number: Int) ->  String {
        switch self {
        case .ready:
            return "Danh sách sẵn sàng (\(number))"
        case .waiting:
            return "Danh sách đợi (\(number))"
        default:
            return ""
        }
    }
}

enum TODriverStatus: String, Codable {
    case ready = "READY"
    case waiting = "WAITING"
    
    var section: TODriverSectionType {
        switch self {
        case .ready:
            return .ready
        case .waiting:
            return .waiting
        }
    }
}

struct TODriverInfoModel: Codable, TODriverInfoDisplay {
    
    var carType: String? {
        switch detailLocationVCType {
        case .taxi4:
            return "4 chỗ"
        case .taxi7:
            return "7 chỗ"
        default:
            return "4 chỗ"
        }
    }
    
    var vehiclePlate: String? {
        if let plateNumer = self.plateNumer, !plateNumer.isEmpty {
            return plateNumer
        }
        
        return vehicles?.first(where: { $0.taxi == true })?.plate
    }
    
        
    var coordinate: CLLocationCoordinate2D {
        guard let lat = lat, let lon = lon else {
            return kCLLocationCoordinate2DInvalid
        }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    
    var imageURL: String? {
        return avatar
    }
    var section: TODriverSectionType {
        return status?.section ?? .none
    }
    let id : Int64?
    let avatar : String?
    let phone : String?
    let status : TODriverStatus?
    let created_by : Int?
    let updated_by : Int?
    let created_at : Double?
    let updated_at : Double?
    let firebase_id : String?
    let fullname : String?
    let zone_id : Int?
    let serviceId : Int?
    let vehicle_id : Int64?
    var plateNumer: String?
    var avatar_url: String?
    var vehicle_type: Int?
    var lat: Double?
    var lon: Double?
    var orderNumber: Int?
    var userId: Int?
    var vehicles: [TOVehicleInfoModel]?

    var detailLocationVCType: TODetailLocationVCType {
        guard let vehicleType = vehicle_type else { return .all }
        switch vehicleType {
        case 1:
            return .taxi4
        case 2:
            return .taxi7
        default:
            return .all
        }
    }
    
    var driverStatusType: TODriverStatus {
        guard let status = status else { return .waiting }
        return status
    }
    
    enum CodingKeys: String, CodingKey {

        case id = "id"
        case avatar = "avatar_url"
        case phone = "phone"
        case status = "status"
        case created_by = "created_by"
        case updated_by = "updated_by"
        case created_at = "created_at"
        case updated_at = "updated_at"
        case firebase_id = "firebase_id"
        case fullname = "full_name"
        case zone_id = "zone_id"
        case serviceId = "service_id"
        case vehicle_id = "vehicle_id"
        case plateNumer = "vehicle_plate"
        case lat = "lat"
        case lon = "lon"
        case orderNumber = "order_number"
        case userId = "user_id"
        case vehicles = "vehicles"
        case vehicle_type = "vehicle_type"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int64.self, forKey: .id)
        avatar = try values.decodeIfPresent(String.self, forKey: .avatar)
        phone = try values.decodeIfPresent(String.self, forKey: .phone)
        status = try values.decodeIfPresent(TODriverStatus.self, forKey: .status)
        created_by = try values.decodeIfPresent(Int.self, forKey: .created_by)
        updated_by = try values.decodeIfPresent(Int.self, forKey: .updated_by)
        created_at = try values.decodeIfPresent(Double.self, forKey: .created_at)
        updated_at = try values.decodeIfPresent(Double.self, forKey: .updated_at)
        firebase_id = try values.decodeIfPresent(String.self, forKey: .firebase_id)
        fullname = try values.decodeIfPresent(String.self, forKey: .fullname)
        zone_id = try values.decodeIfPresent(Int.self, forKey: .zone_id)
        serviceId = try values.decodeIfPresent(Int.self, forKey: .serviceId)
        vehicle_id = try values.decodeIfPresent(Int64.self, forKey: .vehicle_id)
        plateNumer = try values.decodeIfPresent(String.self, forKey: .plateNumer)
        lat = try values.decodeIfPresent(Double.self, forKey: .lat)
        lon = try values.decodeIfPresent(Double.self, forKey: .lon)
        orderNumber = try values.decodeIfPresent(Int.self, forKey: .orderNumber)
        userId = try values.decodeIfPresent(Int.self, forKey: .orderNumber)
        vehicles = try values.decodeIfPresent([TOVehicleInfoModel].self, forKey: .vehicles)
        vehicle_type = try values.decodeIfPresent(Int.self, forKey: .vehicle_type)
    }
}


extension TODriverInfoModel: Equatable {
    static func == (lhs: TODriverInfoModel, rhs: TODriverInfoModel) -> Bool {
        return lhs.id == rhs.id
    }
}


extension TODriverInfoModel: Comparable {
    static func < (lhs: TODriverInfoModel, rhs: TODriverInfoModel) -> Bool {
        return lhs.orderNumber ?? 0 < rhs.orderNumber ?? 0

    }
    
    
}

