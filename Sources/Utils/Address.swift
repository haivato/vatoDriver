//  File name   : Address.swift
//
//  Author      : Vato
//  Created date: 9/25/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import GoogleMaps

struct Address: AddressProtocol {
    var isDatabaseLocal: Bool {
        return false
    }
    
    var streetNumber: String {
        return ""
    }
    var streetName: String {
        return ""
    }

    var placeId: String?
    
    var coordinate: CLLocationCoordinate2D
    var name: String?
    let thoroughfare: String
    let locality: String
    let subLocality: String
    let administrativeArea: String
    let postalCode: String
    let country: String
    let lines: [String]
    let favoritePlaceID: Int64
    var zoneId: Int = 0
    var isOrigin: Bool = false
    var counter: Int = 0

    var distance: Double?
    
    
    var hashValue: Int {
        let n = name ?? ""
        return n.hashValue |
            coordinate.value.hashValue |
            thoroughfare.hashValue |
            locality.hashValue |
            subLocality.hashValue |
            administrativeArea.hashValue |
            postalCode.hashValue |
            country.hashValue
    }
    
    func increaseCounter() {
        print("Increase!!!")
    }
    
    mutating func update(isOrigin: Bool) {
        self.isOrigin = isOrigin
    }
    
    mutating func update(zoneId: Int) {
        self.zoneId = zoneId
    }
    
    mutating func update(placeId: String?) {
        self.placeId = placeId
    }
    
    mutating func update(coordinate: CLLocationCoordinate2D?) {
        self.coordinate = coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
}

extension GMSAddress {
    var address: AddressProtocol {
        return Address(placeId: nil,
                       coordinate: coordinate,
                       name: thoroughfare ?? "",
                       thoroughfare: thoroughfare ?? "",
                       locality: locality ?? "",
                       subLocality: subLocality ?? "",
                       administrativeArea: administrativeArea ?? "",
                       postalCode: postalCode ?? "",
                       country: country ?? "",
                       lines: lines ?? [],
                       favoritePlaceID: 0,
                       zoneId: 0,
                       isOrigin: false,
                       counter: 0,
                       distance: nil)
    }
}
