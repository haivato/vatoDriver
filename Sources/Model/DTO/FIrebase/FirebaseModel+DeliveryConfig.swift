//
//  FirebaseModel+DeliveryConfig.swift
//  FC
//
//  Created by THAI LE QUANG on 8/21/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation



extension FirebaseModel {
    struct DeliveryConfig: Codable, ModelFromFireBaseProtocol {
        let delivery_failed_reasons: [DeliveryReasonItem]?
        let trip_canceled_reasons: [DeliveryReasonItem]?
        
        /// Codable's keymap.
    }
    
    struct DeliveryReasonItem: Codable, ModelFromFireBaseProtocol {
        var id: Int?
        let value: String?
        var showOtherReason: Bool {
            if id == -1 {
                return true
            }
            return false
        }
        /// Codable's keymap.
    }
    struct DriverOnlineStatus: Codable, ModelFromFireBaseProtocol {
        let id: Int?
        let lastOnline: Double?
        let status: OnlineStatusType?
        var location: LocationDriverOnline?
        enum CodingKeys: String, CodingKey {

            case id = "id"
            case lastOnline = "lastOnline"
            case status = "status"
            case location = "location"
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decodeIfPresent(Int.self, forKey: .id)
            lastOnline = try values.decodeIfPresent(Double.self, forKey: .lastOnline)
            status = try values.decodeIfPresent(OnlineStatusType.self, forKey: .status)
            location = try values.decodeIfPresent(LocationDriverOnline.self, forKey: .location)
        }
    }
    struct LocationDriverOnline: Codable {
        let geohash: String?
        let lat: Double?
        let lon: Double?
        enum CodingKeys: String, CodingKey {

            case geohash = "geohash"
            case lat = "lat"
            case lon = "lon"
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            geohash = try values.decodeIfPresent(String.self, forKey: .geohash)
            lat = try values.decodeIfPresent(Double.self, forKey: .lat)
            lon = try values.decodeIfPresent(Double.self, forKey: .lon)
        }
    }

}
