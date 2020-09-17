//
//  FoodExploreItem.swift
//  FC
//
//  Created by vato. on 3/11/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import CoreLocation

struct FoodExploreItem : Codable {
    let createdBy : TimeInterval?
    let updatedBy : TimeInterval?
    let createdAt : TimeInterval?
    let updatedAt : TimeInterval?
    let id : Int?
    var name : String?
    let address : String?
    var lat : Double?
    var lon : Double?
    let bannerImage : [String]?
    let otherImage : [String]?
    let phoneNumber : String?
    let status : Int
    let zoneName : String?
    let zoneId : Int?
    let urlRefer : String?
    
    var imageURL: String? {
        return bannerImage?.first
    }
    
    var currentDistance: Double? {
        guard let currentLocation = GoogleMapsHelper.shareInstance().currentLocation,
            let long = self.lon,
            let lat = self.lat,
            CLLocationCoordinate2D(latitude: lat, longitude: long) != kCLLocationCoordinate2DInvalid else {
                return nil
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
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
    
    enum CodingKeys: String, CodingKey {

        case createdBy = "createdBy"
        case updatedBy = "updatedBy"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
        case id = "id"
        case name = "name"
        case address = "address"
        case lat = "lat"
        case lon = "lon"
        case bannerImage = "bannerImage"
        case otherImage = "otherImage"
        case phoneNumber = "phoneNumber"
        case status = "status"
        case zoneName = "zoneName"
        case zoneId = "zoneId"
        case urlRefer = "urlRefer"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        createdBy = try values.decodeIfPresent(TimeInterval.self, forKey: .createdBy)
        updatedBy = try values.decodeIfPresent(TimeInterval.self, forKey: .updatedBy)
        createdAt = try values.decodeIfPresent(TimeInterval.self, forKey: .createdAt)
        updatedAt = try values.decodeIfPresent(TimeInterval.self, forKey: .updatedAt)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        address = try values.decodeIfPresent(String.self, forKey: .address)
        lat = try values.decodeIfPresent(Double.self, forKey: .lat)
        lon = try values.decodeIfPresent(Double.self, forKey: .lon)
        bannerImage = try values.decodeIfPresent([String].self, forKey: .bannerImage)
        otherImage = try values.decodeIfPresent([String].self, forKey: .otherImage)
        phoneNumber = try values.decodeIfPresent(String.self, forKey: .phoneNumber)
        status = try values.decode(Int.self, forKey: .status)
        zoneName = try values.decodeIfPresent(String.self, forKey: .zoneName)
        zoneId = try values.decodeIfPresent(Int.self, forKey: .zoneId)
        urlRefer = try values.decodeIfPresent(String.self, forKey: .urlRefer)
    }

}


struct FoodStoreResponse : Codable {
    var listStore: [FoodExploreItem]?
    var indexPage: Int?
    var totalPage: Int?
    
    var next: Bool {
        guard let idx = indexPage, let total = totalPage  else {
            return false
        }
        
        return idx < total
    }
}
