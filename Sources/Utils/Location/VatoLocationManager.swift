//  File name   : VatoLocationManager.swift
//
//  Author      : Dung Vu
//  Created date: 1/31/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import RxCocoa
import FirebaseFirestore

@objcMembers
final class VatoLocationManager: CLLocationManager, Weakifiable {
    typealias LocationChanged = (_ location: CLLocation?, _ error:Error?) -> ()
    static let shared = VatoLocationManager()
    @VariableReplay(wrappedValue: []) private (set) var locations: [CLLocation]
    var locationChanged: LocationChanged?

    private var bgTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    private var isRunning = false
    private var registeredAppState: Bool = false
    private lazy var disposeBag = DisposeBag()
    private var disposeKeepAlive: Disposable?
    private var current: Date?
    @Replay(queue: MainScheduler.asyncInstance) private var geoHashLenght: Int?
    
    override init() {
        super.init()
        configure()
        requestAlwaysAuthorization()
    }
    
    func loadLenghtGeohash() {
        let documentRef = Firestore.firestore().documentRef(collection: .configData, storePath: .custom(path: "Client"), action: .read)
        documentRef.find(action: .get, json: nil).bind(onNext: weakify({ (snapshot, wSelf) in
            let geoHashLenght: Int? = snapshot?.data()?.value("promotionNewsGeohashLength", defaultValue: nil)
            wSelf.geoHashLenght = geoHashLenght
        })).disposed(by: disposeBag)
    }
    
    func geoHash() -> Observable<String?> {
        $geoHashLenght.take(1).flatMap { (lenght) -> Observable<String?> in
            if let lenght = lenght,
                let coord = self.location?.coordinate
            {
                return Observable.create { (s) -> Disposable in
                    let queue = DispatchQueue(label: "com.vato.encodeGeohash", qos: .default)
                    queue.async {
                        let result = Geohash.encode(latitude: coord.latitude, longitude: coord.longitude, length: lenght)
                        s.onNext(result)
                        s.onCompleted()
                    }
                    return Disposables.create()
                }
            } else {
                return Observable.just(nil)
            }
        }
    }
    
    private func configure() {
        pausesLocationUpdatesAutomatically = false
//        allowsBackgroundLocationUpdates = true
        self.activityType = .otherNavigation
        self.delegate = self
    }
    
    override func requestAlwaysAuthorization() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            super.requestAlwaysAuthorization()
        default:
            print("No available!!!!")
        }
    }
    
    private func registerAppState() {
        guard !registeredAppState else {
            return
        }
        defer { registeredAppState = true }
        
        NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification).map{ _ in }.do(onNext: { (_) in
            self.current = Date()
        }).bind(onNext: keepAlive).disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification).skip(1).map{ _ in }.bind(onNext: endTask).disposed(by: disposeBag)
        
    }

    override func startUpdatingLocation() {
        if isRunning { stopUpdatingLocation() }
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            isRunning = true
            desiredAccuracy = kCLLocationAccuracyBestForNavigation
            distanceFilter = 10
            registerAppState()
            super.startUpdatingLocation()
        default:
            print("No available!!!!")
        }
    }
    
    override func stopUpdatingLocation() {
        isRunning = false
        super.stopUpdatingLocation()
    }
    
}

// MARK: - Delegate
extension VatoLocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationChanged?(nil, error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationChanged?(locations.last, nil)
        self.locations = locations
    }
}

// MARK: - Task
extension VatoLocationManager {
    private func keepAlive() {
        disposeKeepAlive?.dispose()
        endForegroundTask()
        disposeKeepAlive = Observable<Int>.interval(.seconds(5), scheduler: MainScheduler.asyncInstance).startWith(-1).bind(onNext: { (_) in
            self.endForegroundTask()
            self.bgTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                print(#function)
                self.keepAlive()
            })
        })
    }
    
    private func endTask() {
        defer {
            if let date = self.current {
                let timeLive = abs(date.timeIntervalSinceNow)
                LogEventHelper.log(key: "Application_Driver_Time_Live", params: ["TimeLive": timeLive])
            }
        }
        disposeKeepAlive?.dispose()
        endForegroundTask()
    }
    
    private func endForegroundTask() {
        guard bgTask != .invalid else {
            return
        }
        
        UIApplication.shared.endBackgroundTask(bgTask)
        bgTask = .invalid
    }
}

