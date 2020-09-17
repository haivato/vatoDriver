//
//  OrderContract.swift
//  Vato
//
//  Created by an.nguyen on 8/28/20.
//  Copyright © 2020 Vato. All rights reserved.
//

struct OrderContractData: Codable, ResponsePagingProtocol {
    var next: Bool {
        return true
    }
    
    let items: [OrderContract]?
    let total: Int?
    enum CodingKeys: String, CodingKey {
        case items = "items"
        case total = "total"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        items = try values.decodeIfPresent([OrderContract].self, forKey: .items)
        total = try values.decodeIfPresent(Int.self, forKey: .total)
    }
}
struct ResponsePagingContract<T: Codable>: Codable {
        let items: [T]?
        let total: Int?
        var indexPage: Int?
        var sizePage: Int?
        var totalRows: Int?
        var totalPage: Int? {
            return total
        }
        var currentPage: Int?
        var next: Bool {
            let result = currentPage != totalPage
            return result
        }
}

struct OrderContract: Codable {
    

    
    let order_id: String?
    var order_status: ContractStatus?
    let other_email: String?
    let other_grant: Bool?
    let other_name: String?
    let other_phone: String?
    let pickup: DropOffCarContract?
    let dropoff: DropOffCarContract?
    let pickup_time: Double?
    let dropoff_time: Double?
    let trip_type: String?
    var trip_status: TripContractStatus?
    let num_of_people: Int?
    let vehicle_seat: String?
    let vehicle_rank: String?
    let driver_gender: DriverGender?
    let require_bill: Bool?
    let cost: CostOrderContract?
    let order_code: String?
    let clientID: Int?
    let note: String?
    let request_id: Int?
    let createdAt: Double?
    let user: UserContract?
    let driverInfo: DriverInfoContract?
    
    enum CodingKeys: String, CodingKey {
        case clientID = "client_id"
        case order_id = "order_id"
        case order_status = "order_status"
        case pickup = "pickup"
        case dropoff = "dropoff"
        case pickup_time = "pickup_time"
        case dropoff_time = "dropoff_time"
        case trip_type = "trip_type"
        case num_of_people = "num_of_people"
        case vehicle_seat = "vehicle_seat"
        case vehicle_rank = "vehicle_rank"
        case driver_gender = "driver_gender"
        case require_bill = "require_bill"
        case cost = "cost"
        case order_code = "order_code"
        case trip_status = "trip_status"
        case note = "note"
        case other_email = "other_email"
        case other_grant = "other_grant"
        case other_name = "other_name"
        case other_phone = "other_phone"
        case request_id = "request_id"
        case createdAt = "created_at"
        case user = "user"
        case driverInfo = "driver_info"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        clientID = try values.decodeIfPresent(Int.self, forKey: .clientID)
        order_id = try values.decodeIfPresent(String.self, forKey: .order_id)
        order_status = try values.decodeIfPresent(ContractStatus.self, forKey: .order_status)
        pickup = try values.decodeIfPresent(DropOffCarContract.self, forKey: .pickup)
        dropoff = try values.decodeIfPresent(DropOffCarContract.self, forKey: .dropoff)
        pickup_time = try values.decodeIfPresent(Double.self, forKey: .pickup_time)
        dropoff_time = try values.decodeIfPresent(Double.self, forKey: .dropoff_time)
        trip_type = try values.decodeIfPresent(String.self, forKey: .trip_type)
        num_of_people = try values.decodeIfPresent(Int.self, forKey: .num_of_people)
        vehicle_seat = try values.decodeIfPresent(String.self, forKey: .vehicle_seat)
        vehicle_rank = try values.decodeIfPresent(String.self, forKey: .vehicle_rank)
        driver_gender = try values.decodeIfPresent(DriverGender.self, forKey: .driver_gender)
        require_bill = try values.decodeIfPresent(Bool.self, forKey: .require_bill)
        cost = try values.decodeIfPresent(CostOrderContract.self, forKey: .cost)
        order_code = try values.decodeIfPresent(String.self, forKey: .order_code)
        trip_status = try values.decodeIfPresent(TripContractStatus.self, forKey: .trip_status)
        note = try values.decodeIfPresent(String.self, forKey: .note)
        other_email = try values.decodeIfPresent(String.self, forKey: .other_email)
        other_grant = try values.decodeIfPresent(Bool.self, forKey: .other_grant)
        other_name = try values.decodeIfPresent(String.self, forKey: .other_name)
        other_phone = try values.decodeIfPresent(String.self, forKey: .other_phone)
        request_id = try values.decodeIfPresent(Int.self, forKey: .request_id)
        createdAt = try values.decodeIfPresent(Double.self, forKey: .createdAt)
        user = try values.decodeIfPresent(UserContract.self, forKey: .user)
        driverInfo = try values.decodeIfPresent(DriverInfoContract.self, forKey: .driverInfo)
    }
    
}
struct CostOrderContract: Codable {
    let deposit: Double?
    let total: Double?
    enum CodingKeys: String, CodingKey {
        case deposit = "deposit"
        case total = "total"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        deposit = try values.decodeIfPresent(Double.self, forKey: .deposit)
        total = try values.decodeIfPresent(Double.self, forKey: .total)
    }
}
struct DropOffCarContract: Codable {
    let address: String?
    let lat: Double?
    let lon: Double?
    let name: String?
    let placeID: String?
    
    enum CodingKeys: String, CodingKey {
        case address = "address"
        case lat = "lat"
        case lon = "lon"
        case name = "name"
        case placeID = "place_id"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        address = try values.decodeIfPresent(String.self, forKey: .address)
        lat = try values.decodeIfPresent(Double.self, forKey: .lat)
        lon = try values.decodeIfPresent(Double.self, forKey: .lon)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        placeID = try values.decodeIfPresent(String.self, forKey: .placeID)
        
    }
}
enum DriverGender: String, Codable {
    case MALE = "MALE"
    case FEMALE = "FEMALE"
    case ALL = "ALL"
}
enum TripTypeCarContract: String, Codable {
    case FLEXIBLE = "FLEXIBLE"
    case ONE_WAY = "ONE_WAY"
    case ROUND_TRIP = "ROUND_TRIP"
}

struct UserContract: Codable, UserDisplayProtocol {
    var fullName: String? {
        return name
    }
    
    var avatarUrl: String? {
        return avatar_url
    }
    
    let name, phone, email: String?
    let avatar_url: String?
    let firebase_id: String?
    let id: Int?
    
    enum CodingKeys: String, CodingKey {
        case name, phone, email
        case avatar_url = "avatar_url"
        case firebase_id = "firebase_id"
        case id = "id"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        phone = try values.decodeIfPresent(String.self, forKey: .phone)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        avatar_url = try values.decodeIfPresent(String.self, forKey: .avatar_url)
        firebase_id = try values.decodeIfPresent(String.self, forKey: .firebase_id)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
    }
}
struct DriverInfoContract: Codable {
    let avatar_url: String?
    let email: String?
    let firebase_id: String?
    let id: Int?
    let name: String?
    let phone: String?
    let vehicle_name: String?
    let vehicle_plate: String?
    enum CodingKeys: String, CodingKey {
        case avatar_url = "avatar_url"
        case email = "email"
        case firebase_id = "firebase_id"
        case id = "id"
        case name = "name"
        case phone = "phone"
        case vehicle_name = "vehicle_name"
        case vehicle_plate = "vehicle_plate"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        avatar_url = try values.decodeIfPresent(String.self, forKey: .avatar_url)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        firebase_id = try values.decodeIfPresent(String.self, forKey: .firebase_id)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        phone = try values.decodeIfPresent(String.self, forKey: .phone)
        vehicle_name = try values.decodeIfPresent(String.self, forKey: .vehicle_name)
        vehicle_plate = try values.decodeIfPresent(String.self, forKey: .vehicle_plate)
    }
}
struct OptionContract: Codable {
    let driver_genders: [String: String]?
    let trip_types: [String: String]?
    let vehicle_ranks: [String: String]?
    let vehicle_seats: [String: String]?
}

enum ContractStatus: String, Codable {
    case initOrder = "NEW"
    case confirmed = "CONFIRMED"
    case clientCancelOrder = "CLIENT_CANCELED"
    case adminCancelOrder = "ADMIN_CANCELED"
    case deposited = "DEPOSITED"
    case finished = "FINISHED"
//    case assigned = "ASSIGNED"
//    case driverAccepted = "DRIVER_ACCEPTED"

    var statusText: String {
        switch self {
        case .deposited:
            return "Đặt chuyến đi thành công"
        case .confirmed:
            return "Đã xác nhận"
        case .initOrder:
            return "Khởi tạo"
        case .clientCancelOrder, .adminCancelOrder:
            return "Đã huỷ"
        case .finished:
            return "Đã hoàn thành"
//        case .assigned:
//            return "Đã tìm tài xế"
//        case .driverAccepted:
//            return "Tài xế nhận"
        }
    }
        
        var statusColor: UIColor {
            switch self {
            case .deposited:
                return #colorLiteral(red: 0.2980392157, green: 0.7098039216, blue: 0.03137254902, alpha: 1)
            case .confirmed:
                return #colorLiteral(red: 0.2901960784, green: 0.5647058824, blue: 0.8862745098, alpha: 1)
            case .initOrder:
                return #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            case .clientCancelOrder, .adminCancelOrder:
                return #colorLiteral(red: 1, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
            case .finished:
                return #colorLiteral(red: 0.6156862745, green: 0.3411764706, blue: 0.8549019608, alpha: 1)
    //        case .assigned:
    //            return #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
    //        case .driverAccepted:
    //            return #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            }
        }
}

