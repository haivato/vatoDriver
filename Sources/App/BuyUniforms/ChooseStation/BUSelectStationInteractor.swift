//  File name   : BUSelectStationInteractor.swift
//
//  Author      : vato.
//  Created date: 3/14/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork

protocol BUSelectStationRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol BUSelectStationPresentable: Presentable {
    var listener: BUSelectStationPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol BUSelectStationListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func didSelect(item: FoodExploreItem)
    func selectStationMoveBack()
}

final class BUSelectStationInteractor: PresentableInteractor<BUSelectStationPresentable> {
    /// Class's public properties.
    weak var router: BUSelectStationRouting?
    weak var listener: BUSelectStationListener?
    let categoryId: Int
    let coordinate: CLLocationCoordinate2D
    /// Class's constructor.
    init(presenter: BUSelectStationPresentable,
         mutableStoreStream: MutableStoreStream,
         categoryId: Int,
         coordinate: CLLocationCoordinate2D)
    {
        self.categoryId = categoryId
        self.coordinate = coordinate
        self.mutableStoreStream = mutableStoreStream
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
    private let mutableStoreStream: MutableStoreStream
}

// MARK: BUSelectStationInteractable's members
extension BUSelectStationInteractor: BUSelectStationInteractable {
}

// MARK: BUSelectStationPresentableListener's members
extension BUSelectStationInteractor: BUSelectStationPresentableListener {
    func selectStationMoveBack() {
        self.listener?.selectStationMoveBack()
    }
   
    var selectedEvent: Observable<FoodExploreItem?>? {
        return mutableStoreStream.store.asObservable()
    }
    
    func didSelect(item: FoodExploreItem) {
        listener?.didSelect(item: item)
    }
    
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T> where T : Codable {
         let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
               return network.request(using: router, decodeTo: OptionalMessageDTO<T>.self).map { (r) -> T? in
                   switch r {
                   case .success(let response):
                       return response.data
                   case .failure(let e):
                       throw e
                   }
               }.filterNil()
    }
    
}

// MARK: Class's private methods
private extension BUSelectStationInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
