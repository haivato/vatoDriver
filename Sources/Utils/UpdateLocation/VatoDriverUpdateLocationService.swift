//  File name   : VatoDriverUpdateLocationService.swift
//
//  Author      : Dung Vu
//  Created date: 6/30/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import RxCocoa
import FirebaseFirestore
import VatoNetwork
import FirebaseDatabase
import FirebaseAuth

@objcMembers
final class VatoDriverUpdateLocationService: NSObject {
    static let shared = VatoDriverUpdateLocationService()
    private lazy var disposeBag = DisposeBag()
    @Replay(queue: SerialDispatchQueueScheduler.init(qos: .default)) private var updateLastOnlineMaxDistance: Double?
    @Replay(queue: SerialDispatchQueueScheduler.init(qos: .default)) private var updateLastOnlineMaxInterval: Int?
    private var disposeUpdateLocation: Disposable?
    private var disposeUpdateLocationTrip: Disposable?
        
    @VariableReplay private var _locations: [CLLocationCoordinate2D] = []
    
    var polylineInTrip: String {
        let temp = _locations
        let result = encodeCoordinates(temp)
        return result
    }
    
    private override init() {
        super.init()
    }
    
    private func clearLocations() {
        _locations = []
    }
    
    private func updateCacheLocation(_ new: CLLocationCoordinate2D) {
        var temp = _locations
        temp.append(new)
        _locations = temp
    }
    
    func syncCloud(location: CLLocationCoordinate2D) {
        let geohash = Geohash.encode(latitude: location.latitude, longitude: location.longitude, length: 12)
        let databaseRef = Database.database().reference()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let hash = uid.javaHash() % 10
        let ref = databaseRef.child("DriverOnline").child("\(hash)").child(uid)
        let params: JSON = ["lat": location.latitude, "lon": location.longitude, "geohash": geohash]
        
        var updateJSON: JSON = ["location": params]
        let status = UserDefaults.standard.integer(forKey: "kKeyLastOnlineState")
        if status > 0 {
            updateJSON["lastOnline"] = UInt64(Date().timeIntervalSince1970 * 1000)
        }
        ref.updateChildValues(updateJSON) { (e, _) in
            assert(e == nil, e?.localizedDescription ?? "")
        }
    }
    
    private func updateLocation(e1: Observable<Double>, e2: Observable<Int>, block: @escaping (CLLocationCoordinate2D) -> ()) -> Disposable {
        let location = VatoLocationManager.shared.$locations.map { $0.last?.coordinate }.filterNil()
        let update1 = e1.flatMap { (distance) -> Observable<CLLocationCoordinate2D> in
            return location.distinctUntilChanged { (c1, c2) -> Bool in
                abs(c1.distance(to: c2)) < distance
            }
        }
        
        let update2 = e2.flatMap { (time) in
            return Observable<Int>.interval(.seconds(time), scheduler: SerialDispatchQueueScheduler.init(qos: .default)).startWith(-1)
        }.map { (_) -> CLLocationCoordinate2D? in
            return VatoLocationManager.shared.location?.coordinate
        }.filterNil()
        
        return Observable.merge([update1, update2]).bind(onNext: block)
    }
    
    // MARK: -- Public method
    func loadConfig() {
        let documentRef = Firestore.firestore().documentRef(collection: .configData, storePath: .custom(path: "Driver"), action: .read)
        documentRef.find(action: .get, json: nil).bind(onNext: { snapshot in
            self.updateLastOnlineMaxDistance = snapshot?.data()?.value("UpdateLastOnlineMaxDistance", defaultValue: 20)
            self.updateLastOnlineMaxInterval = snapshot?.data()?.value("UpdateLastOnlineMaxInterval", defaultValue: 30)
            self.disposeUpdateLocation = self.updateLocation(e1: self.$updateLastOnlineMaxDistance.filterNil().take(1),
                                e2: self.$updateLastOnlineMaxInterval.filterNil().take(1)) { (location) in
                                    DispatchQueue.main.async {
                                        self.syncCloud(location: location)
                                    }
            }
        }).disposed(by: disposeBag)
    }
    
    func startUpdateLocation(tripId: String, inTrip: Bool) {
        disposeUpdateLocationTrip?.dispose()
        let p = inTrip ? "IntripDriverLocations" : "ReceiveDriverLocations"
        let tripRef = Firestore.firestore().document("Trip/\(tripId)").collection(p)
        disposeUpdateLocationTrip = updateLocation(e1: Observable.just(30), e2: Observable.just(10)) { (location) in
            self.updateCacheLocation(location)
            let date = Date()
            let params: JSON = ["lat": location.latitude,
                                "lon": location.longitude,
                                "timestamp": Int64(date.timeIntervalSince1970 * 1000)]
            tripRef.addDocument(data: params) { (e) in
                assert(e == nil, e?.localizedDescription ?? "")
            }
        }
    }
    
    func stopUpdate() {
        clearLocations()
        disposeUpdateLocation?.dispose()
        disposeUpdateLocationTrip?.dispose()
    }
    
    func stopUpdateTripLocation() {
        clearLocations()
        disposeUpdateLocationTrip?.dispose()
    }
}
