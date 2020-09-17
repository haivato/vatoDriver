//  File name   : AddressProtocol.swift
//
//  Author      : Vato
//  Created date: 9/25/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import GoogleMaps


protocol AddressProtocol {
    var coordinate: CLLocationCoordinate2D { get set}

    var name: String? { get set }
    var thoroughfare: String { get }

    var streetNumber: String { get }
    var streetName: String { get }
    var locality: String { get }
    var subLocality: String { get }
    var administrativeArea: String { get }
    var postalCode: String { get }
    var country: String { get }
    var lines: [String] { get }
    var isDatabaseLocal: Bool { get }
    var hashValue: Int { get }
    var zoneId: Int { get set }
    var favoritePlaceID: Int64 { get }
    var isOrigin: Bool { get set }
    var counter: Int { get set }
    
    var placeId: String? { get set }
    var distance: Double? { get set }
    
    func increaseCounter()
    mutating func update(isOrigin: Bool)
    mutating func update(zoneId: Int)
    mutating func update(placeId: String?)
    mutating func update(coordinate: CLLocationCoordinate2D?)
}

extension AddressProtocol {
    @discardableResult
    func createMarker(for mapView: GMSMapView,
                      customMarker: (() -> GMSMarker)? = nil,
                      with icon: UIImage? = nil,
                      block: ((GMSMarker) -> Void)? = nil) -> GMSMarker {
        let marker = (customMarker?() ?? GMSMarker(position: coordinate)) >>> {
            block?($0) ?? {
                $0.icon = icon
                $0.title = thoroughfare
            }($0)
            $0.map = mapView
        }
        marker.tracksViewChanges = false
        return marker
    }

    var primaryText: String {
        let v = name ?? ""
        let text = !v.isEmpty ? v : thoroughfare
        return (text.lowercased() == Text.unnamedRoad.text.lowercased() ? Text.unnamedRoad.localizedText : text.capitalized)
    }

    var secondaryText: String {
//        guard let line = lines.first?.capitalized else {
//            return ""
//        }

//        var subString = line[line.startIndex..<line.endIndex]

        // Remove thoroughfare
//        if thoroughfare.count > 0 && line.contains(thoroughfare) {
//            let start = line.startIndex
//            let end = subString.index(start, offsetBy: thoroughfare.count)
//
//            subString.removeSubrange(line.startIndex...end)
//        }
        return subLocality
    }
    
    func isValidCoordinate() -> Bool {
        return (coordinate.latitude != 0 && coordinate.longitude != 0)
    }
}
