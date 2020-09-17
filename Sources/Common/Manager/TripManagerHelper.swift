//
//  AutoReceiveTripManager.swift
//  FC
//
//  Created by vato. on 7/24/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import VatoNetwork
import RxSwift

struct SaleOder: Codable {
    var baseGrandTotal: Int64?
}

@objcMembers
class TripManagerHelper: NSObject {
    @objc static fileprivate(set) var shared = TripManagerHelper()
    private lazy var disposeBag = DisposeBag()
    func getTripFoodDetail(tripId: String,
                           complete: ((_ baseGrandTotal: NSInteger, _ error: NSError?) -> Void)?) {
        FirebaseTokenHelper
            .instance
            .eToken
            .filterNil()
            .take(1)
            .flatMap { Requester.responseDTO(decodeTo: OptionalMessageDTO<SaleOder>.self,
                                             using: VatoFoodApi.getSaleOrder(authenToken: $0, tripId: tripId),
                                             method: .get) }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (r) in
                let baseGrandTotal = r.response.data?.baseGrandTotal
                complete?(NSInteger(baseGrandTotal ?? 0), nil)
                }, onError: { (e) in
                    complete?(0, e as NSError)
            }).disposed(by: disposeBag)
        
    }
}
