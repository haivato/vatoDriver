//  File name   : TOPickupInvitation.swift
//
//  Author      : Dung Vu
//  Created date: 2/21/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

struct TOPickupInvitation: Codable, Hashable {
    let id : Int?
    let created_by : Int?
    let updated_by : Int?
    let expired_at : Double?
    let created_at : Double?
    let updated_at : Double?
    let user_id : Int?
    let pickup_station_id : Int?
    let lat : Double?
    let lon : Double?
    let pickup_station_name : String?
    let reason_description : String?
    let status : TaxiRequestAction?
    var firestore_listener_path: String?

    func isExpire() -> Bool  {
        return Double(FireBaseTimeHelper.default.currentTime) > (self.expired_at ?? 0)
    }
    
    func hash(into hasher: inout Hasher) {
        var new = Hasher()
        new.combine(pickup_station_id ?? 0)
        hasher = new
    }
    
    static func ==(lhs: TOPickupInvitation, rhs: TOPickupInvitation) -> Bool {
        return lhs.pickup_station_id == rhs.pickup_station_id
    }
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case created_by = "created_by"
        case updated_by = "updated_by"
        case created_at = "created_at"
        case updated_at = "updated_at"
        case user_id = "user_id"
        case pickup_station_id = "pickup_station_id"
        case pickup_station_name = "pickup_station_name"
        case status = "status"
        case reason_description = "reason_description"
        case lat = "lat"
        case lon = "lon"
        case expired_at = "expired_at"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        created_by = try values.decodeIfPresent(Int.self, forKey: .created_by)
        updated_by = try values.decodeIfPresent(Int.self, forKey: .updated_by)
        created_at = try values.decodeIfPresent(Double.self, forKey: .created_at)
        updated_at = try values.decodeIfPresent(Double.self, forKey: .updated_at)
        user_id = try values.decodeIfPresent(Int.self, forKey: .user_id)
        pickup_station_id = try values.decodeIfPresent(Int.self, forKey: .pickup_station_id)
        pickup_station_name = try values.decodeIfPresent(String.self, forKey: .pickup_station_name)
        status = try values.decodeIfPresent(TaxiRequestAction.self, forKey: .status)
        reason_description = try values.decodeIfPresent(String.self, forKey: .reason_description)
        lat = try values.decodeIfPresent(Double.self, forKey: .lat)
        lon = try values.decodeIfPresent(Double.self, forKey: .lon)
        expired_at = try values.decodeIfPresent(Double.self, forKey: .expired_at)
    }
    
    var currentDistance: Double? {
        guard let currentLocation = GoogleMapsHelper.shareInstance().currentLocation,
            let lat = lat,
            let lon = lon else {
                return nil
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        return currentLocation.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
    }
    
    
    var distanceStr: String? {
        guard let d = self.currentDistance else { return "" }
        if d >= 1000 {
            return String(format: "Cách %.2fkm", d/1000)
        } else {
            return String(format: "Cách %.0fm", d)
        }
    }
}

struct TOPickupRegistration : Codable {
    let id : Int?
    let address : String?
    let distance : Int?
    let created_by : Int?
    let updated_by : Int?
    let created_at : Double?
    let updated_at : Double?
    let pickup_station_id : Int?
    let pickup_station_name : String?
    let group_id : Int?
    let status : TaxiRequestAction?
    let reason_id : Int?
    let reason_description : String?
    let type : String?
    let lat : Double?
    let lon : Double?
    let order_number : Int?
    var firestore_listener_path: String?
    
    enum CodingKeys: String, CodingKey {

        case id = "id"
        case address = "address"
        case distance = "distance"
        case created_by = "created_by"
        case updated_by = "updated_by"
        case created_at = "created_at"
        case updated_at = "updated_at"
        case pickup_station_id = "pickup_station_id"
        case pickup_station_name = "pickup_station_name"
        case group_id = "group_id"
        case status = "status"
        case reason_id = "reason_id"
        case reason_description = "reason_description"
        case type = "type"
        case lat = "lat"
        case lon = "lon"
        case order_number = "order_number"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        address = try values.decodeIfPresent(String.self, forKey: .address)
        distance = try values.decodeIfPresent(Int.self, forKey: .distance)
        created_by = try values.decodeIfPresent(Int.self, forKey: .created_by)
        updated_by = try values.decodeIfPresent(Int.self, forKey: .updated_by)
        created_at = try values.decodeIfPresent(Double.self, forKey: .created_at)
        updated_at = try values.decodeIfPresent(Double.self, forKey: .updated_at)
        pickup_station_id = try values.decodeIfPresent(Int.self, forKey: .pickup_station_id)
        pickup_station_name = try values.decodeIfPresent(String.self, forKey: .pickup_station_name)
        group_id = try values.decodeIfPresent(Int.self, forKey: .group_id)
        status = try values.decodeIfPresent(TaxiRequestAction.self, forKey: .status)
        reason_id = try values.decodeIfPresent(Int.self, forKey: .reason_id)
        reason_description = try values.decodeIfPresent(String.self, forKey: .reason_description)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        lat = try values.decodeIfPresent(Double.self, forKey: .lat)
        lon = try values.decodeIfPresent(Double.self, forKey: .lon)
        order_number = try values.decodeIfPresent(Int.self, forKey: .order_number)
    }

}


extension TOPickupInvitation: TOOrderProtocol {
    var pickupStationId: Int? {
        return pickup_station_id
    }
    
    var nameLocation: String? {
        return pickup_station_name
    }
    
    var distance: String? {
        return ""
    }
    
    var subTitle: String? {
        return ""
    }
    
    var attribute: NSAttributedString? {
        return nil
    }
}
