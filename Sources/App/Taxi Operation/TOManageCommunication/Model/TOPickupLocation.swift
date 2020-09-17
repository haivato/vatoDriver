//  File name   : TOPickupLocation.swift
//
//  Author      : Dung Vu
//  Created date: 2/21/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import CoreLocation

struct TOPickupLocation: Codable, TOOrderProtocol {
    
    var queueCurrentIndex: String?
    var approveModel: TaxiOperationDisplay?
    struct Config {
        static let maxDistance = 500.0
    }
    
    var pickupStationId: Int? {
        return id
    }
    
    var nameLocation: String? {
        return "Điểm \(name ?? "")"
    }
    
    var currentDistance: Double? {
        guard let currentLocation = GoogleMapsHelper.shareInstance().currentLocation, let coordinate = address?.coordinate, coordinate != kCLLocationCoordinate2DInvalid else {
            return nil
        }
        
        return currentLocation.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
    }
    
    
    var distance: String? {
        guard let d = self.currentDistance else { return "" }
        if d >= 1000 {
            return String(format: "Cách %.2fkm", d/1000)
        } else {
            return String(format: "Cách %.0fm", d)
        }
    }
    
    var subTitle: String? {
        if (queueCurrentIndex ?? "").isEmpty == false {
            return queueCurrentIndex
        }
        
        guard let availableSlot = self.available_slot else { return "" }
        if availableSlot <= 0 {
            return "Đã đủ"
        }
        return "Còn \(availableSlot) tài"
    }
    
    var isFull: Bool {
        guard let availableSlot = self.available_slot else { return true }
        return availableSlot <= 0
        
    }
    
    var attribute: NSAttributedString? {
        let d = distance ?? ""
        let s = subTitle ?? ""
        
        if (queueCurrentIndex ?? "").isEmpty == false  {
            return NSMutableAttributedString(attributedString: "\(d) • \(s)".attribute)
        }
        
        let f = NSMutableAttributedString(attributedString: d.attribute)
        let color = self.isFull ? #colorLiteral(red: 0.2980392157, green: 0.7098039216, blue: 0.03137254902, alpha: 1) : #colorLiteral(red: 0.8823529412, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
        
        if !s.isEmpty {
            let f1 = " • ".attribute
            let f2 = s.attribute >>> .color(c: color)
            f.append(f1)
            f.append(f2)
        }
        return f
    }
    
    
    struct Permission : Codable {
        let id : Int?
        let role : String?
        let active : Bool?
        let created_by : Int?
        let updated_by : Int?
        let created_at : Double?
        let updated_at : Double?
        let pickup_station_id : Int?
        let user_id : Int?
        
        enum CodingKeys: String, CodingKey {
            
            case id = "id"
            case role = "role"
            case active = "active"
            case created_by = "created_by"
            case updated_by = "updated_by"
            case created_at = "created_at"
            case updated_at = "updated_at"
            case pickup_station_id = "pickup_station_id"
            case user_id = "user_id"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decodeIfPresent(Int.self, forKey: .id)
            role = try values.decodeIfPresent(String.self, forKey: .role)
            active = try values.decodeIfPresent(Bool.self, forKey: .active)
            created_by = try values.decodeIfPresent(Int.self, forKey: .created_by)
            updated_by = try values.decodeIfPresent(Int.self, forKey: .updated_by)
            created_at = try values.decodeIfPresent(Double.self, forKey: .created_at)
            updated_at = try values.decodeIfPresent(Double.self, forKey: .updated_at)
            pickup_station_id = try values.decodeIfPresent(Int.self, forKey: .pickup_station_id)
            user_id = try values.decodeIfPresent(Int.self, forKey: .user_id)
        }
    }
    
    struct Address : Codable {
        let lat : Double?
        let lon : Double?
        let address : String?
        
        var coordinate: CLLocationCoordinate2D {
            guard let lat = lat, let lon = lon else {
                return kCLLocationCoordinate2DInvalid
            }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        
        enum CodingKeys: String, CodingKey {
            
            case lat = "lat"
            case lon = "lon"
            case address = "address"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            lat = try values.decodeIfPresent(Double.self, forKey: .lat)
            lon = try values.decodeIfPresent(Double.self, forKey: .lon)
            address = try values.decodeIfPresent(String.self, forKey: .address)
        }
    }
    
    let id : Int?
    let name : String?
    let address : Address?
    let radius : Int?
    let created_by : Int?
    let updated_by : Int?
    let created_at : Double?
    let updated_at : Double?
    let max_ready : Int?
    let max_queue : Int?
    let available_slot : Int?
    let request_time : Int?
    let register_expired_in : Int?
    let invite_expired_in : Int?
    let permissions: [Permission]?
    let order_number : Int?
    var drivers: [TODriverInfoModel]?
    var firestore_listener_path : String?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case name = "name"
        case address = "address"
        case radius = "radius"
        case created_by = "created_by"
        case updated_by = "updated_by"
        case created_at = "created_at"
        case updated_at = "updated_at"
        case max_ready = "max_ready"
        case max_queue = "max_queue"
        case available_slot = "available_slot"
        case request_time = "request_time"
        case register_expired_in = "register_expired_in"
        case invite_expired_in = "invite_expired_in"
        case permissions = "permissions"
        case order_number = "order_number"
        case firestore_listener_path = "firestore_listener_path"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        address = try values.decodeIfPresent(Address.self, forKey: .address)
        radius = try values.decodeIfPresent(Int.self, forKey: .radius)
        created_by = try values.decodeIfPresent(Int.self, forKey: .created_by)
        updated_by = try values.decodeIfPresent(Int.self, forKey: .updated_by)
        created_at = try values.decodeIfPresent(Double.self, forKey: .created_at)
        updated_at = try values.decodeIfPresent(Double.self, forKey: .updated_at)
        max_ready = try values.decodeIfPresent(Int.self, forKey: .max_ready)
        max_queue = try values.decodeIfPresent(Int.self, forKey: .max_queue)
        available_slot = try values.decodeIfPresent(Int.self, forKey: .available_slot)
        request_time = try values.decodeIfPresent(Int.self, forKey: .request_time)
        register_expired_in = try values.decodeIfPresent(Int.self, forKey: .register_expired_in)
        invite_expired_in = try values.decodeIfPresent(Int.self, forKey: .invite_expired_in)
        permissions = try values.decodeIfPresent([Permission].self, forKey: .permissions)
        order_number = try values.decodeIfPresent(Int.self, forKey: .order_number)
        firestore_listener_path = try values.decodeIfPresent(String.self, forKey: .firestore_listener_path)
    }
    
}

extension TOPickupLocation: PickupLocationProtocol {
    var pickupId: Int? {
        return id
    }
}

extension TOPickupLocation {
    func isClose() -> Bool {
        guard let currentLocation = GoogleMapsHelper.shareInstance().currentLocation, let coordinate = address?.coordinate, coordinate != kCLLocationCoordinate2DInvalid else {
            return false
        }
        
        if currentLocation.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) > Config.maxDistance {
            return false
        }
        
        return true
    }
}


struct TOPickupRequest: Codable {
    let id: Int
    let expired_at: TimeInterval
    var station_id: Int = 0
    
    var expired: Bool {
        return FireBaseTimeHelper.default.currentTime > expired_at
    }
    
    init(id: Int, expired_at: TimeInterval, station_id: Int) {
        self.id = id
        self.expired_at = expired_at
        self.station_id = station_id
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        expired_at = try values.decode(TimeInterval.self, forKey: .expired_at)
        
    }
}

extension TOPickupLocation: TODetailLocationProtocol {
    var canRequestTaxiQueue: Bool {
        guard let distance = currentDistance, let idUser = TOManageCommunication.shared.user?.userId else {
            return true
        }
        let listDriver = self.drivers?.filter({ $0.id == Int64(idUser) }) ?? []
        
        return distance < 1000 || listDriver.count > 0
    }
    
    
    var info: [String]? {
        if let approveModel = approveModel,
            approveModel.stationId == self.pickupStationId {
            var infos: [String] = []
            infos.append(approveModel.queue ?? "Danh sách sẵn sàng")
            infos.append("Vị trí: #\(approveModel.orderNumber ?? 1)")
            return infos
        }
        
        var infos: [String] = []
        let listReady = self.drivers?.filter({ $0.status == .ready }) ?? []
        let listWaiting = self.drivers?.filter({ $0.status == .waiting }) ?? []
        infos.append(self.distance ?? "")
        infos.append("Danh sách sẵn sàng: \(listReady.count)")
        infos.append("Danh sách đợi: \(listWaiting.count)")
        return infos
    }

}



