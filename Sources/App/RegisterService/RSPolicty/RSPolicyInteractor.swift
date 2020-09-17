//  File name   : RSPolicyInteractor.swift
//
//  Author      : MacbookPro
//  Created date: 4/28/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import FirebaseAuth
import RIBs
import RxSwift
import CoreLocation
import RxCocoa
import FwiCore
import FwiCoreRX
import VatoNetwork
import Alamofire

protocol RSPolicyRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func showAlerError(text: String)
}

protocol RSPolicyPresentable: Presentable {
    var listener: RSPolicyPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol RSPolicyListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func moveBackListService(isFromManage: Bool)
    func moveToShorcut(isFromManage: Bool)
}

final class RSPolicyInteractor: PresentableInteractor<RSPolicyPresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: RSPolicyRouting?
    weak var listener: RSPolicyListener?
    var array: [ListServiceVehicel]
    var strHtml: String
    var itemCar: Int64
    var isFromManage: Bool
    /// Class's constructor.
    init(presenter: RSPolicyPresentable, array: [ListServiceVehicel], strHtml: String, itemCar: Int64, isFromManage: Bool) {
        self.array = array
        self.strHtml = strHtml
        self.itemCar = itemCar
        self.isFromManage = isFromManage
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        mUrl = self.strHtml
        
        // todo: Implement business logic here.
    }
    private lazy var network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
//    @Replay(queue: MainScheduler.asyncInstance) private var mIsSuccess: (Bool, String)
    private var isSuccessOb: PublishSubject<(Bool, String)> = PublishSubject.init()
    private var isSuccessObc: PublishSubject<String> = PublishSubject.init()
    @Replay(queue: MainScheduler.asyncInstance) private var mUrl: String
    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
}

// MARK: RSPolicyInteractable's members
extension RSPolicyInteractor: RSPolicyInteractable {
}

// MARK: RSPolicyPresentableListener's members
extension RSPolicyInteractor: RSPolicyPresentableListener {
    var urlObs: Observable<String> {
        return $mUrl.asObservable()
    }
    
    func moveToShorcut() {
        self.listener?.moveToShorcut(isFromManage: self.isFromManage)
    }
    
    var isSuccess: Observable<(Bool, String)> {
        return isSuccessOb.asObservable()
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return self.indicator.asObservable()
    }
    
    func submitbRegisterService() {
        var listService: [Int] = []
        for i in self.array {
            listService.append(i.serviceID)
        }
        let p: [String : Any] = ["service_ids": listService]
        let url = TOManageCommunication.path("/api/vehicle/\(self.itemCar)/services")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: p, useFullPath: true)
        network.request(using: router,
                        decodeTo: OptionalMessageDTO<ListRegisterService>.self,
                        method: .post,
                        encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                switch result {
                case .success(let d):
                    if d.fail == false {
                        if self?.isFromManage ?? false {
                            self?.isSuccessOb.onNext((true, "Kích hoạt dịch vụ thành công. Vui lòng vào Gara của bạn để chỉnh sửa bật/tắt nhận đơn."))
                        } else {
                            self?.isSuccessOb.onNext((true, d.message ?? ""))
                        }
                    } else {
                        self?.isSuccessOb.onNext((false, d.message ?? ""))
                    }
                case .failure(let e):
                    self?.isSuccessOb.onNext((false, e.localizedDescription))
                }
        }.disposeOnDeactivate(interactor: self)
    }
    
    func moveBackListService() {
        self.listener?.moveBackListService(isFromManage: self.isFromManage)
    }
    
}

// MARK: Class's private methods
private extension RSPolicyInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
