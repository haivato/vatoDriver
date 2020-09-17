//  File name   : VatoPermission.swift
//
//  Author      : Dung Vu
//  Created date: 2/19/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import FwiCore
import RxSwift
import VatoNetwork

@objcMembers
final class VatoPermission: NSObject, Weakifiable {
    struct Claim: Codable {
        var taxi_arrangement_registration: Bool
    }
    
    struct Permission: Codable, Equatable {
        var claims: Claim
        var uid: String
        
        static func ==(lhs: Permission, rhs: Permission) -> Bool {
            return lhs.uid == rhs.uid
        }
    }
    
    /// Class's public properties.
    typealias Element = [String: Permission]
    static let shared = VatoPermission()
    private lazy var disposeBag = DisposeBag()
    @CacheFile(fileName: "permission_taxi") private var cached: [Element]
    private var permissonTaxi: [UInt64: Bool] = [:]
    private lazy var defaultReachabilityService: DefaultReachabilityService? = try? DefaultReachabilityService()
    
    private func findingPermission(from customToken: String) -> Permission? {
        let components = customToken.components(separatedBy: ".")
        for s in components {
            guard let data = Data(base64Encoded: s) else {
                continue
            }
            do {
                let model = try Permission.toModel(from: data)
                return model
            } catch {
                print(error.localizedDescription)
                continue
            }
        }
        return nil
    }
    
    func cachePermission(customToken: String) {
        guard let model = findingPermission(from: customToken) else {
            return
        }
        let key = model.uid
        _cached.add(item: [key: model])
        _cached.save()
    }
    
    
    func cleanUp() {
        self.permissonTaxi = [:]
    }
    
    private func requestPermissionTaxi() -> Observable<Bool> {
        return TOManageCommunication.shared.$user.filterNil().take(1).flatMap { [weak self] (d) -> Observable<Bool>  in
            if let p = self?.permissonTaxi[d.userId] {
                return Observable.just(p)
            } else {
                let p = TOManageCommunication.path("/taxi/users/\(d.userId)")
                let router = VatoAPIRouter.customPath(authToken: "", path: p, header: nil, params: nil, useFullPath: true)
                let provider = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
                
                let request: Observable<Swift.Result<OptionalMessageDTO<TaxiPermisson>, Error>>
                
                if let tracker = self?.defaultReachabilityService {
                    request = provider
                        .request(using: router, decodeTo: OptionalMessageDTO<TaxiPermisson>.self).map({ (r) -> Swift.Result<OptionalMessageDTO<TaxiPermisson>, Error> in
                            switch r {
                            case .success:
                                return r
                            case .failure(let e):
                                if (e as NSError).code == NSURLErrorNotConnectedToInternet {
                                    throw e
                                } else {
                                    return r
                                }
                            }
                        }).retryOnBecomesReachable(tracker)
                } else {
                    request = provider
                    .request(using: router, decodeTo: OptionalMessageDTO<TaxiPermisson>.self)
                }
                
                return request
                    .do(onNext: { [weak self](r) in
                        guard let t = try? r.get() else {
                            return
                        }
                        self?.permissonTaxi[d.userId] = t.data?.organization?.configs?.enable_pickup
                    })
                    .map { try $0.get().data?.organization?.configs?.enable_pickup ?? false }
                    .catchErrorJustReturn(false)
            }
        }
    }
    
    
    func hasPermissionTaxi(uid: String?) -> Observable<Bool> {
        guard let uid = uid, !uid.isEmpty else {
            return Observable.just(false)
        }
        
        let eventTaxi = TOManageCommunication.shared.$user.filterNil().map { $0.taxiDriver }
        let cachedLoad = requestPermissionTaxi()
        
        let sources = [eventTaxi, cachedLoad]
        return Observable.combineLatest(sources)
            .map { $0.reduce(true, { $0 && $1 }) }
            .distinctUntilChanged()
            .observeOn(MainScheduler.asyncInstance)
    }
    
    // Objc
    func permissonTaxi(uid: String?, completion: ((Bool) -> ())?) {
        hasPermissionTaxi(uid: uid).bind { (grant) in
            completion?(grant)
        }.disposed(by: disposeBag)
    }
}


