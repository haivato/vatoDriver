//
//  ShowPlaceVM.swift
//  Vato
//
//  Created by vato. on 7/20/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import VatoNetwork

struct ShowPlaceVM {
//    private let model: PlaceModel?
    private var updatePlaceDisposable: Disposable?
    
    func findSuggestionGoogle(by keyword: String) -> Observable<[MapModel.Place]> {
        
        var currentLocation = CLLocation(latitude: 0, longitude: 0)
        if let location = GoogleMapsHelper.shareInstance().currentLocation {
            currentLocation = location
        }
        
        return SessionManager.shared.firebaseToken()
            .flatMap { MapAPI.findPlace(with: keyword, currentLocation: currentLocation.coordinate, authToken: $0) }
    }
    
    mutating func getDetailLocation(place: MapModel.Place, completion: ((MapModel.Place) -> Void)?) {
        if let _ = place.location {
            completion?(place)
        } else {
            guard let placeId = place.placeId else {
                return
            }
            
            self.updatePlaceDisposable?.dispose()
            self.updatePlaceDisposable = nil
            updatePlaceDisposable = SessionManager.shared.firebaseToken()
                .flatMap { MapAPI.placeDetails(with: placeId, authToken: $0) }
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { (result) in
                    var newPlace = place
                    newPlace.location = result.location
                    if let address = result.fullAddress,
                        address.count > 0 {
                        newPlace.address = address
                    }
                    completion?(newPlace)
                })
            
        }
    }
}
