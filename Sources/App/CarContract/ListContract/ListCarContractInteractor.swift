//  File name   : ListCarContractInteractor.swift
//
//  Author      : Phan Hai
//  Created date: 09/09/2020
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

protocol ListCarContractRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func moveContractDetail(item: ContractHistoryType)
}

protocol ListCarContractPresentable: Presentable {
    var listener: ListCarContractPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol ListCarContractListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func moveBackHome()
}

final class ListCarContractInteractor: PresentableInteractor<ListCarContractPresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: ListCarContractRouting?
    weak var listener: ListCarContractListener?

    /// Class's constructor.
    override init(presenter: ListCarContractPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        
        // todo: Implement business logic here.
    }
    @Replay(queue: MainScheduler.asyncInstance) private var mItem: Bool

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
}

// MARK: ListCarContractInteractable's members
extension ListCarContractInteractor: ListCarContractInteractable {
    func backCarContract() {
        self.router?.dismissCurrentRoute(completion: {
            self.mItem = true
        })
    }
    
    func routeToHome() {
        self.router?.dismissCurrentRoute(completion: {
            self.mItem = true
        })
    }
    
}

// MARK: ListCarContractPresentableListener's members
extension ListCarContractInteractor: ListCarContractPresentableListener {
    var itemGetList: Observable<Bool> {
        return self.$mItem
    }

    func moveBackHome() {
        self.listener?.moveBackHome()
    }
    func requestList(params: [String : Any]) -> Observable<ResponsePagingContract<ContractHistoryType>> {
        let url = TOManageCommunication.path("/rental-car/driver/orders?\(params.queryString)")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        return network.request(using: router,
        decodeTo: MessageDTO<ResponsePagingContract<ContractHistoryType>>.self,
        method: .get,
        encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .map { (r) -> ResponsePagingContract<ContractHistoryType>? in
            switch r {
            case .success(let response):
                return response.data
            case .failure(let e):
                throw e
            }
        }.filterNil()
        }
    
    func select(item: ContractHistoryType) {
        self.router?.moveContractDetail(item: item)
    }
    
}

// MARK: Class's private methods
private extension ListCarContractInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
