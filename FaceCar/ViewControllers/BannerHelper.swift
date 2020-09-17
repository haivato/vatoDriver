//
//  BannerHelpert.swift
//  FC
//
//  Created by vato. on 3/2/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import VatoNetwork
import FwiCore
import SnapKit

@objcMembers
final class BannerHelper: NSObject, Weakifiable {
    private struct Config {
        static let kPrefixImageViewFooter = "driver_bg_footer_top_main"
        static let kTagImageViewFooter = 4582
        static let kTimeImageDuration = 5 // senconds
    }
    private lazy var disposeBag = DisposeBag()
    static let instance = BannerHelper()
    private lazy var network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
    @Replay(queue: MainScheduler.asyncInstance) private var mListBanner: [VatoHomeLandingItem]
    private var disposeListen: Disposable?
    
    func requestBanner() {
        let ignoreCache = true
        let request = VatoLocationManager.shared
            .geoHash()
            .flatMap { [weak self] (hash) -> Observable< Swift.Result<OptionalMessageDTO<[VatoHomeLandingItem]>, Error>> in
            guard let wSelf = self else { return Observable.empty() }
            let hash = hash
            var params: JSON = ["position": -1]
            params["geohash"] = hash

            let router = VatoAPIRouter.customPath(authToken: "", path: "landing-page/home_driver/sections/items", header: nil, params: params, useFullPath: false)
            return wSelf.network.request(using: router, decodeTo: OptionalMessageDTO<[VatoHomeLandingItem]>.self, ignoreCache: ignoreCache)
        }
        
        request.bind(onNext: weakify({ (result, wSelf) in
            switch result {
            case .success(let r):
                wSelf.mListBanner = (r.data ?? []).filter(\.status)
            case .failure(let e):
                #if DEBUG
                print(e.localizedDescription)
                #endif
            }
        })).disposed(by: disposeBag)
    }
    
    func loadFooterBanner() -> UIView? {
        disposeListen?.dispose()
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        let imageView = VatoScrollView<VatoBannerView<VatoHomeLandingItem>>.init(edge: .zero, sizeItem: CGSize(width: UIScreen.main.bounds.width, height: 69), spacing: 0, type: .banner, bottomPageIndicator: -10)
        imageView.selected.bind { (item) in
            guard let p = item.action.data?.url ,
                let url = URL(string: p) else { return }
            let topVC = UIApplication.topViewController()
            WebVC.loadWeb(on: topVC, url: url, title: nil)
        }.disposed(by: disposeBag)
        
        imageView >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
                make.height.equalTo(70)
            }
        }
        
        disposeListen = $mListBanner.bind { [weak imageView] (items) in
            imageView?.setupDisplay(item: items)
        }
        
        
        return view
    }
}
