//  File name   : AddDestinationModel.swift
//
//  Author      : Dung Vu
//  Created date: 3/24/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

struct AddDestinationInfo: AddressProtocol {
    var coordinate: CLLocationCoordinate2D = .init()
    var name: String? = "Test"
    var thoroughfare: String = "ABC"
    var streetNumber: String = "DEF"
    var streetName: String = ""
    var locality: String = ""
    var subLocality: String = "Hello world"
    var administrativeArea: String = ""
    var postalCode: String = ""
    var country: String = ""
    
    var lines: [String] = []
    
    var isDatabaseLocal: Bool = false
    
    var hashValue: Int = 150
    
    var zoneId: Int = 0
    
    var favoritePlaceID: Int64 = 0
    
    var isOrigin: Bool = false
    
    var counter: Int = 0
    
    var placeId: String?
    
    var distance: Double?
    
    func increaseCounter() {}
    func update(isOrigin: Bool) {}
    func update(zoneId: Int) {}
    func update(placeId: String?) {}
    func update(coordinate: CLLocationCoordinate2D?) {}
}

struct AnyKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init(name: String) {
        stringValue = name
    }
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = String(intValue)
    }
}

struct Coordinate: Codable {
    let lat: Double
    let lng: Double
    
    init(from lat: Double, lng: Double) {
        self.lat = lat
        self.lng = lng
    }
    
    var valid: Bool {
        return lat != 0 || lng != 0
    }
}

// MARK: Codable
extension Coordinate {
    /// Codable's keymap.
    private enum CodingKeys: String, CodingKey {
        case lat = "lat"
        case lng = "lon"
    }
    
    var location: CLLocation {
        return CLLocation(latitude: lat, longitude: lng)
    }
}

struct TripWayPoint: Codable, Equatable {
    let lat: Double
    let lon: Double
    let address: String
    var name: String?
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    static func ==(lhs: TripWayPoint, rhs: TripWayPoint) -> Bool {
        return lhs.lat == rhs.lat && lhs.lon == rhs.lon && lhs.address == rhs.address
    }
}

struct AddDestinationTripInfo: Codable {
    struct Trip: Codable {
        struct Source: Codable {
            var userType: String?
            var editable: Bool?
        }
        
        struct ExtraData: Codable {
            var startLocation: Coordinate?
            var endLocation: Coordinate?
        }
        
        var fromSource: Source?
        var startLocation: Coordinate? {
            return extraData?.startLocation
        }
        var startName: String?
        var startAddress: String?
        var endAddress: String?
        var endName: String?
        var serviceId: Int
        var promotionValue: UInt64?
        var type: Int
        var wayPoints: [TripWayPoint]?
        
        var endLat: Double?
        var endLon: Double?
        var endLocation: Coordinate? {
            return extraData?.endLocation
        }
        
        var startLat: Double?
        var startLon: Double?
        
        var additionPrice: UInt64?
        var price: UInt64
        var farePrice: UInt64?
        var fareClientSupport: UInt64?
        var extraData: ExtraData?
        var oPrice: UInt64 {
            let fPrice = self.farePrice.orNil(0)
            let bookPrice = (fPrice > 0 && self.price != 0) ? fPrice : self.price
            return bookPrice + self.additionPrice.orNil(0)
        }
        
        var fPrice: UInt64 {
            let r = oPrice
            let p = (promotionValue ?? 0) + fareClientSupport.orNil(0)
            return r > p ? r - p : 0
        }
    }
    var trip: Trip?
}

extension AddDestinationTripInfo.Trip {
    func getStartAddress() -> AddressProtocol {
        var coordinate = kCLLocationCoordinate2DInvalid
        if let startLat = self.startLat, let startLon = self.startLon {
            coordinate = CLLocationCoordinate2D(latitude: startLat, longitude: startLon)
        }
        return TripMapAddress(coordinate: coordinate, name: self.startName, subLocality: self.startAddress ?? "", isOrigin: true)
    }
    
    func getEndAddress() -> AddressProtocol? {
        
        guard let endLat = self.endLat, let endLon = self.endLon, endLat != 0, endLon != 0 else {
            return nil
           

        }
        let coordinate = CLLocationCoordinate2D(latitude: endLat, longitude: endLon)
                   return TripMapAddress(coordinate: coordinate, name: self.endName, subLocality: self.endAddress ?? "", isOrigin: false)
    }
    
    func getWayPointsAddress() -> [AddressProtocol] {
        guard let wayPoints = wayPoints else {
            return []
        }
        
        return wayPoints.map { TripMapAddress(coordinate: CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon), name: $0.address, subLocality: $0.address, isOrigin: false) }
    }
    
    func getAddresses() -> [AddressProtocol] {
        var result:[AddressProtocol] = []
        
        result.append(self.getStartAddress())
        result.append(contentsOf: self.getWayPointsAddress())
            if let endAddress = self.getEndAddress() {
            result.append(endAddress)
        }
        
        return result
    }
}

extension AddDestinationTripInfo.Trip {
    func getPrice() -> UInt64 {
        let bookPrice = ((self.farePrice ?? 0 > 0 && self.price != 0) ? self.farePrice : self.price) ?? 0;
        return bookPrice + (self.additionPrice ?? 0)
    }
}
