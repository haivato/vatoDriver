//  File name   : TOOrderInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 2/19/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Alamofire

protocol TOOrderRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToLocation(pickUpStationId: Int?, firestore_listener_path: String?)
}

protocol TOOrderPresentable: Presentable {
    var listener: TOOrderPresentableListener? { get set }
    
    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol TOOrderListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func TOOrderMoveBack()
}

final class TOOrderInteractor: PresentableInteractor<TOOrderPresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: TOOrderRouting?
    weak var listener: TOOrderListener?
    
    struct Configs {
        static let url: (String) -> String = { p in
            #if DEBUG
            return "https://api-dev.vato.vn\(p)"
            #else
            return "https://api.vato.vn\(p)"
            #endif
        }
    }
    /// Class's constructor.
    override init(presenter: TOOrderPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        requestStationLocations()
//        source.generateDummy()
        
        // todo: Implement business logic here.
    }
    
    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    /// Class's private properties.
    private lazy var source: TOOrderManageData = TOOrderManageData()
    private lazy var network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
    @VariableReplay(wrappedValue: []) private var mData: [TOPickupLocation]
}

// MARK: TOOrderInteractable's members
extension TOOrderInteractor: TOOrderInteractable {
    func TODetailLocationMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
}

// MARK: TOOrderPresentableListener's members
extension TOOrderInteractor: TOOrderPresentableListener {
    var eLoadingObser: Observable<(Bool, Double)> {
        return indicator.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    
    var values: Observable<TOOrderData> {
        return source.$mSource.observeOn(MainScheduler.asyncInstance)
    }
    
    func TOOrderMoveBack() {
        listener?.TOOrderMoveBack()
    }
    
    func routeToLocation(pickUpStationId: Int?, firestore_listener_path: String?) {
        router?.routeToLocation(pickUpStationId: pickUpStationId, firestore_listener_path: firestore_listener_path)
    }
    
    
}

// MARK: Class's private methods
private extension TOOrderInteractor {
    private func setupRX() {
        Observable.combineLatest(TOManageCommunication.shared.event, $mData).bind(onNext: { [weak self] (mListEvent, data) in
            let eventJoineds = mListEvent.filter { $0.type == .approve }
            let eventRequesteds = mListEvent.filter { $0.type == .watingResponse }
            
            var locationJoineds: [TOPickupLocation] = []
            var locationRequesteds: [TOPickupLocation] = []
            var locationNearby: [TOPickupLocation] = []
            
            let datas = data.sorted(by: { $0.currentDistance ?? 0 < $1.currentDistance ?? 0 })
            
            datas.forEach { (m) in
                if let event = eventJoineds.first(where: { $0.stationId == m.id }) {
                    var m1 = m
                    m1.queueCurrentIndex = "\(event.queue ?? "") #\(event.orderNumber ?? 1)"
                    locationJoineds.addOptional(m1)
                } else if eventRequesteds.contains(where: { $0.stationId == m.id }) { locationRequesteds.addOptional(m) }
                else { locationNearby.addOptional(m) }
            }
            
            self?.source.mSource = [TOOrderSectionType.joined: locationJoineds,
                                 TOOrderSectionType.requestOrder: locationRequesteds,
                                 TOOrderSectionType.listLocation: locationNearby]
        }).disposeOnDeactivate(interactor: self)
    }
    
    func requestStationLocations() {
        let url = TOManageCommunication.path("/taxi/drivers/pickup-stations")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true)
        
        network
            .request(using: router, decodeTo: OptionalMessageDTO<[TOPickupLocation]>.self)
            .trackProgressActivity(indicator)
            .bind { [weak self] (result) in
                guard let me = self else { return }
                switch result {
                case .success(let s):
                    if let data = s.data {
                        me.mData = data
                    }
                case .failure(let e):
                    print(e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
        
    }
       
}
