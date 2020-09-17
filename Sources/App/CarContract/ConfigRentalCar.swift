//
//  ConfigRentalCar.swift
//  FC
//
//  Created by Phan Hai on 08/09/2020.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import VatoNetwork
import Alamofire
import RxSwift

struct ConfigRentalCar {
    static let api: (_ path:String) -> String = { p in
        #if DEBUG
//        return "http://192.168.1.45:9090\(p)" //"https://api-dev.vato.vn\(p)"
        return "https://api-dev.vato.vn\(p)"
        #else
        return "https://api.vato.vn\(p)"
        #endif
    }
}

final class ConfigRentalCarManager {
    static let shared = ConfigRentalCarManager()
    private lazy var disposeBag = DisposeBag()
    
    @Replay(queue: MainScheduler.asyncInstance) var options: OptionContract?
    var defaultOption: OptionContract?

    func load() {
        getAllOptions()
    }

    private func getAllOptions() {
        var params = [String: Any]()
        params["all"] = true
        //        let p = ConfigManager.Configs.api("/rental-car/orders/options")
        let p = ConfigRentalCar.api("/rental-car/orders/options")
        let router = VatoAPIRouter.customPath(authToken: "", path: p, header: nil, params: params, useFullPath: true)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: router,
                        decodeTo: OptionalMessageDTO<OptionContract>.self,
                        method: .get)
//            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                guard let wSelf = self else { return }
                switch result {
                case .success(let d):
                    if d.fail {
                    } else {
                        if let r = d.data {
                            wSelf.options = r
                            wSelf.defaultOption = r
                        }
                    }
                case .failure(let e):
                    break
                }
        }.disposed(by: disposeBag)
    }
}

