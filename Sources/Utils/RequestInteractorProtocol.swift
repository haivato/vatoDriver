//  File name   : RequestInteractorProtocol.swift
//
//  Author      : Dung Vu
//  Created date: 11/21/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import VatoNetwork

protocol LocationRequestProtocol: RequestInteractorProtocol {
    func lookupAddress(for location: CLLocationCoordinate2D, maxDistanceHistory: Double) -> Observable<AddressProtocol>
}

extension LocationRequestProtocol {
    func lookupAddress(for location: CLLocationCoordinate2D, maxDistanceHistory: Double) -> Observable<AddressProtocol> {
        return request(map: { MapAPI.geocoding(authToken: $0, lat: location.latitude, lng: location.longitude) })
                .timeout(.seconds(30), scheduler: MainScheduler.asyncInstance)
                .map { v -> AddressProtocol in
                    let new = MarkerHistory.init(with: v)
                    return new.address
                }.catchErrorJustReturn(MapInteractor.Config.defaultMarker.address)

    }
}
