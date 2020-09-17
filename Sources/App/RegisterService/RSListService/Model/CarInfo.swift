
protocol DisplayInfoCar {
    var name: String {get}
    var number: String{get}
}

struct CarInfo: Codable, DisplayInfoCar {
    var name: String {
        return self.marketName ?? ""
    }
    
    var number: String {
        return self.plate ?? ""
    }
    
    let id: Int64
    let type, rank, userID: Int
    let plate, color, brand, marketName: String?
    let image: String?
    let active: Bool?
    let taxiBrand: Int?
    let availableServices: [AvailableService]?
    let colorCode: String?

    enum CodingKeys: String, CodingKey {
        case id, type, rank
        case userID = "userId"
        case plate, color, brand, marketName, image, active, taxiBrand, availableServices, colorCode
    }
}

// MARK: - AvailableService
struct AvailableService: Codable {
    
    let id: Int?
    let name, displayName: String?
    let serviceID: Int?
    let force: Bool?
    let active: Bool?
    let enable: Bool?
    let transport: Transport?
    let rank: Int?
    let vehicleTypes: [Int]?
    let segment: String?
    let configs: Configs?
    let rideRailingConfig: RideRailingConfig?

    enum CodingKeys: String, CodingKey {
        case id, name, displayName
        case serviceID = "serviceId"
        case force, active, enable, transport, rank, vehicleTypes, segment, configs, rideRailingConfig
    }
}

// MARK: - Configs
struct Configs: Codable {
    let rideHailing: RideHailing?
    let requiredAcceptTerms: Bool?
    let termsURL: String?
    let trackingSMS: Bool?

    enum CodingKeys: String, CodingKey {
        case rideHailing = "ride_hailing"
        case requiredAcceptTerms = "required_accept_terms"
        case termsURL = "terms_url"
        case trackingSMS = "tracking_sms"
    }
}

// MARK: - RideHailing
struct RideHailing: Codable {
    let maxOrders, maxRadius, maxTimeout: Int?
    let steps: [ScanCondition]?

    enum CodingKeys: String, CodingKey {
        case maxOrders = "max_orders"
        case maxRadius = "max_radius"
        case maxTimeout = "max_timeout"
        case steps
    }
}

// MARK: - ScanCondition
struct ScanCondition: Codable {
    let radius, timeout, maxDrivers: Int?

    enum CodingKeys: String, CodingKey {
        case radius, timeout
        case maxDrivers = "max_drivers"
    }
}

// MARK: - RideRailingConfig
struct RideRailingConfig: Codable {
    let maxOrders, maxTimeout: Int?
    let scanConditions: [ScanCondition]?

    enum CodingKeys: String, CodingKey {
        case maxOrders = "max_orders"
        case maxTimeout = "max_timeout"
        case scanConditions = "scan_conditions"
    }
}

enum Segment: String, Codable {
    case a = "a"
    case b = "b"
    case d = "d"
}

enum Transport: String, Codable {
    case bike = "bike"
    case car = "car"
}
