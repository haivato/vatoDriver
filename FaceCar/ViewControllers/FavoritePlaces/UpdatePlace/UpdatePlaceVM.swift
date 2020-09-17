//
//  UpdatePlaceVM.swift
//  Vato
//
//  Created by vato. on 7/19/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import RxSwift
import VatoNetwork
import Alamofire

struct UpdatePlaceVM {
     var model: PlaceModel?
    //    let modelObser = ReplaySubject<PlaceModel>.create(bufferSize: 1)
    
    init(model: PlaceModel?) {
        self.model = model
        //        if let model = self.model {
        //            self.modelObser.onNext(model)
        //        }
    }
    
    
    func getAddress() -> String? {
        return self.model?.address
    }
    
    func isAllowEditName() -> Bool {
        if self.model?.typeId == .Orther {
            return true
        }
        return false
    }
    
    func generateShowPlaceVM() -> ShowPlaceVM {
        return ShowPlaceVM()
    }
    
    func generateSearchPlaceVM() -> SearchPlaceVM {
        return SearchPlaceVM()
    }
    
    mutating func updateModel(model: MapModel.Place) {
        var copyModel = self.model
        copyModel?.address = model.address
        if let latStr = model.location?.lat {
            copyModel?.lat = String(describing: latStr)
        }
        if let lonStr = model.location?.lon {
            copyModel?.lon = String(describing: lonStr)
        }
        self.model = copyModel
        //        if let abc = self.model {
        //            self.modelObser.onNext(abc)
        //        }
    }
    
    mutating func updateModelFromDetail(model: MapModel.PlaceDetail) {
        var copyModel = self.model
        copyModel?.address = model.fullAddress
        if let latStr = model.location?.lat {
            copyModel?.lat = String(describing: latStr)
        }
        if let lonStr = model.location?.lon {
            copyModel?.lon = String(describing: lonStr)
        }
        self.model = copyModel
        //        if let abc = self.model {
        //            self.modelObser.onNext(abc)
        //        }
    }
    
    mutating func updateName(name: String?) {
        self.model?.name = name
    }
    
    func createFavPlace() -> Observable<Data>{
        guard let name = self.model?.name?.trim(),
            let address = self.model?.address,
            let typeId = self.model?.typeId.rawValue,
            let lat = self.model?.lat,
            let long = self.model?.lon else { return Observable.empty() }
        
       
        return SessionManager.shared.firebaseToken()
            .flatMap { (authToken) -> Observable<(HTTPURLResponse, Data)> in
                return Requester.request(using: VatoAPIRouter.createFavPlace(authToken: authToken,
                                                                             name: name,
                                                                             address: address,
                                                                             typeId: typeId,
                                                                             lat: "\(lat)", lon: "\(long)",isDriver: false),
                    method: .post,
                    encoding: JSONEncoding.default)
            }.map {
                $0.1
                
        }
        
        
        
        
        /*
        return authStream.firebaseAuthToken.flatMap { key -> Observable<(HTTPURLResponse, PromotionData)> in
            Requester.requestDTO(using: VatoAPIRouter.createFavPlace(authToken: key,
                                                                     name: name,
                                                                     address: address,
                                                                     typeId: typeId,
                                                                     lat: "\(lat)", lon: "\(long)",isDriver: false),
                                 method: .post,
                                 encoding: JSONEncoding.default,
                                 block: nil)
            }.map {
                let data = $0.1
                guard data.status == 200 else {
                    throw NSError(domain: NSURLErrorDomain, code: data.status, userInfo: [NSLocalizedDescriptionKey: data.message ?? ""])
                }
                return ""
        }
        */
        
        
        /*
        let router = authStream.firebaseAuthToken.take(1).map {
            VatoAPIRouter.createFavPlace(authToken: $0,
                                         name: name,
                                         address: address,
                                         typeId: typeId,
                                         lat: "\(lat)",
                                         lon: "\(long)",
                                         isDriver: false)
        }
        return router.flatMap {
//            Requester.responseDTO(decodeTo: OptionalMessageDTO<String>.self, using: $0, method: .post)
            Requester.responseDTO(decodeTo: OptionalMessageDTO<PlaceModel>.self, using: $0, method: .post, encoding: JSONEncoding.default)
            }.map { r in
                if let e = r.response.error {
                    throw e
                } else {
                    //                    let list = r.response.data.orNil(default: [])
                    //                    self.listFavoritePlace = list
                    //                    return list
                    return ""
                }
            }.catchError { (e) in
                printDebug(e)
                return Observable.just("")
        }
 */
    }
    
}
