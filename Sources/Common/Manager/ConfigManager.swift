//  File name   : ConfigManager.swift
//
//  Author      : Dung Vu
//  Created date: 8/26/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import Firebase
import RxSwift
import FwiCore
import VatoNetwork
import Alamofire
import FirebaseRemoteConfig

@objcMembers
final class ConfigManager: NSObject, Weakifiable {
    static let shared = ConfigManager()
    private var isDigital: PublishSubject<Bool> = PublishSubject.init()
    private typealias ConfigData = Data
    private lazy var remoteConfig: RemoteConfig = {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 5
        remoteConfig.configSettings = settings
        return remoteConfig
    }()
    private lazy var disposeBag = DisposeBag()
    @Replay(queue: MainScheduler.asyncInstance) private var temp: ConfigData
    func loadConfig() {
        let key = "driver_features"
        loadRemoteConfig(key: key).bind(onNext: { data in
            self.temp = data
        }).disposed(by: disposeBag)
    }

    private func loadRemoteConfig(key: String) -> Observable<ConfigData> {
        return Observable.create { (s) -> Disposable in
            self.remoteConfig.fetchAndActivate { (status, e) in
                if let e = e {
                    return s.onError(e)
                }
                let values = self.remoteConfig[key]
                self.findDriverfeatures(value: values)
                s.onNext(values.dataValue)
                s.onCompleted()
            }
            return Disposables.create()
        }
    }

    struct Configs {
        static let api: (_ path:String) -> String = { p in
            #if DEBUG
                return "https://api-dev.vato.vn\(p)"
            #else
                return "https://api.vato.vn\(p)"
            #endif
        }
    }

    private func findDriverfeatures(value: RemoteConfigValue){
        let json = value.json
        if let json = json {
            let isTaxi = json["realityTrip"] as? Bool ?? false
            self.isDigital.onNext(isTaxi)
        }
    }
    func getRemoteConfigDigitalType(completion: ((Bool) -> ())?) {
        self.isDigital.bind { (isCheck) in
            completion?(isCheck)
        }.disposed(by: disposeBag)
    }

    private func cacheConfig(url: URL?, data: Data) {
        do {
            try data.write(url)
        } catch {
            print(error.localizedDescription)
        }
    }

}

extension RemoteConfigValue {
    var json: [String: Any]? {
        let j = try? JSONSerialization.jsonObject(with: dataValue, options: [])
        return j as? [String: Any]
    }
}

