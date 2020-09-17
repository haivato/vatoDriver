//
//  FavoritePlaceManager.swift
//  FC
//
//  Created by vato. on 7/24/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import VatoNetwork
import RxSwift
import Alamofire

class FavoritePlaceManager: NSObject {
    @objc static fileprivate(set) var shared = FavoritePlaceManager()
    private lazy var disposeBag = DisposeBag()
    
    @objc var activeFavoriteModeModel: ActiveFavoriteModeModel?
    
    @objc func getStatusFavMode(complete: ((_ error: NSError?) -> Void)?) {
        FirebaseTokenHelper.instance.eToken.filterNil()
            .take(1)
            .timeout(7.0, scheduler: SerialDispatchQueueScheduler(qos: .background))
            .flatMap { (authToken) -> Observable<(HTTPURLResponse, Data)> in
                self.activeFavoriteModeModel = nil
                return Requester.request(using: VatoAPIRouter.getStatusFavMode(authToken: authToken))
            }.map {
                $0.1
            }.subscribe(onNext: { (data) in
                DispatchQueue.main.async {
                    guard let responseManager = ResponseManager.create(data: data) else { return }
                    if let activeFavoriteModeModel = ActiveFavoriteModeModel.create(json: responseManager.data) {
                        self.activeFavoriteModeModel = activeFavoriteModeModel
                    }
                    complete?(responseManager.error)
                }
            }, onError: { error in
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                    complete?(error as NSError)
                }
            }).disposed(by: disposeBag)
    }
    
    @objc func turnOffFavoriteMode(tripId: String, complete: ((_ error: NSError?) -> Void)?) {
        guard let activeId = self.activeFavoriteModeModel?.getID() else {
//            let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: [NSLocalizedDescriptionKey: "Có lỗi xảy ra"])
            complete?(nil)
            return
        }
        SessionManager.shared.firebaseToken()
            .flatMap { (authToken) -> Observable<(HTTPURLResponse, Data)> in
                return Requester.request(using: VatoAPIRouter.driverTurnOffFavMode(authToken: authToken, activeId: activeId, tripId: tripId), method: .put,
                                         encoding: JSONEncoding.default)
            }.map {
                $0.1
            }.subscribe(onNext: { (data) in
                DispatchQueue.main.async {
                    guard let responseManager = ResponseManager.create(data: data) else { return }
                    if responseManager.error == nil {
                        self.activeFavoriteModeModel = nil
                    }
                    complete?(responseManager.error)
                }
            }, onError: { error in
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                    complete?(error as NSError)
                }
            }).disposed(by: disposeBag)
    }
}
