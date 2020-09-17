//  File name   : CarContractInteractor.swift
//
//  Author      : Phan Hai
//  Created date: 28/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import CoreLocation
import RxCocoa
import FwiCore
import FwiCoreRX
import VatoNetwork
import Alamofire

protocol CarContractRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToContractDetail(item: OrderContract)
    func routeToChatWithVato()
    func showAlertError(text: String)
}

protocol CarContractPresentable: Presentable {
    var listener: CarContractPresentableListener? { get set }
    
    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol CarContractListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func moveBackHome()
}

final class CarContractInteractor: PresentableInteractor<CarContractPresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: CarContractRouting?
    weak var listener: CarContractListener?
    
    /// Class's constructor.
    override init(presenter: CarContractPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        getListOrder()
        getListOrderPast()
        ConfigRentalCarManager.shared.load()
        // todo: Implement business logic here.
    }
    @Replay(queue: MainScheduler.asyncInstance) private var mListOrderActive: [OrderContract]
    @Replay(queue: MainScheduler.asyncInstance) private var mListOrderPast: [OrderContract]
    
    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    /// Class's private properties.
}

// MARK: CarContractInteractable's members
extension CarContractInteractor: CarContractInteractable {
    func routeToHome() {
        self.router?.dismissCurrentRoute(completion: {
            self.getListOrder()
            self.getListOrderPast()
        })
    }
    
    func moveBackOrderContract() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func backCarContract() {
        self.router?.dismissCurrentRoute(completion: {
            self.getListOrder()
        })
    }
    func refreshListActive() {
        self.getListOrder()
    }
    func refreshListPast() {
        self.getListOrderPast()
    }
}

// MARK: CarContractPresentableListener's members
extension CarContractInteractor: CarContractPresentableListener {
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T> where T : Decodable, T : Encodable {
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
    
    var eLoading: Observable<ActivityProgressIndicator.Element> {
        return self.indicator.asObservable()
    }
    var listOrderActive: Observable<[OrderContract]> {
        return self.$mListOrderActive
    }
    var listOrderPast: Observable<[OrderContract]> {
        return self.$mListOrderPast
    }
    func moveBackHome() {
        self.listener?.moveBackHome()
    }
    func routeToContractDetail(item: OrderContract) {
        self.router?.routeToContractDetail(item: item)
    }
    func routeToChatWithVato() {
        self.router?.routeToChatWithVato()
    }
    func cancelOrderContract(orderID: Int) {
        guard let id = UserManager.shared.getCurrentUser()?.user.id else {
            return
        }
        //        let params: JSON = ["page": 0, "size": 10, "filter": "ACTIVE"]
        let p = TOManageCommunication.path("/rental-car/driver/\(id)/orders/\(orderID)/status")
        let router = VatoAPIRouter.customPath(authToken: "", path: p, header: nil, params: nil, useFullPath: true)
        
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: router, decodeTo: OptionalMessageDTO<OrderContractData>.self)
            .trackProgressActivity(self.indicator)
            .bind { (result) in
                switch result {
                case .success(let r):
                    if r.fail == false {
                        self.mListOrderActive = r.data?.items ?? []
                    } else {
                        self.router?.showAlertError(text: r.message ?? "")
                    }
                case .failure(let e):
                    self.router?.showAlertError(text: e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
}

// MARK: Class's private methods
private extension CarContractInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
    private func getListOrder() {
        let p: [String: Any] = ["page": 0, "size": 10, "filter": "ACTIVE"]
        let url = TOManageCommunication.path("/rental-car/driver/orders?\(p.queryString)")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: router,
                        decodeTo: OptionalMessageDTO<OrderContractData>.self,
                        method: .get,
                        encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { (result) in
                switch result {
                case .success(let r):
                    if r.fail == false {
                        guard let data = r.data else {
                            return
                        }
                        self.mListOrderActive = data.items ?? []
                    } else {
                        self.router?.showAlertError(text: r.message ?? "")
                    }
                case .failure(let e):
                    self.router?.showAlertError(text: e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
    private func getListOrderPast() {
        let p: [String: Any] = ["page": 0, "size": 10, "filter": "PAST"]
        let url = TOManageCommunication.path("/rental-car/driver/orders?\(p.queryString)")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true)
        
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
            network.request(using: router,
                            decodeTo: OptionalMessageDTO<OrderContractData>.self,
                            method: .get,
                            encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { (result) in
                switch result {
                case .success(let r):
                    if r.fail == false {
                        guard let data = r.data else {
                            return
                        }
                        self.mListOrderPast = data.items ?? []
                    } else {
                        self.router?.showAlertError(text: r.message ?? "")
                    }
                case .failure(let e):
                    self.router?.showAlertError(text: e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
}
