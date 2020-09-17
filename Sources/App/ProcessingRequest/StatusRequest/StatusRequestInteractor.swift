//  File name   : StatusRequestInteractor.swift
//
//  Author      : MacbookPro
//  Created date: 4/4/20
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

protocol StatusRequestRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func showAlerError(message: String)
}

protocol StatusRequestPresentable: Presentable {
    var listener: StatusRequestPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol StatusRequestListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func statusRequesttMoveBack()
}

final class StatusRequestInteractor: PresentableInteractor<StatusRequestPresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: StatusRequestRouting?
    weak var listener: StatusRequestListener?
    private var item: RequestResponseDetail?
    private var itemFood: UserRequestTypeFireStore?
    /// Class's constructor.
    init(presenter: StatusRequestPresentable, item: RequestResponseDetail?, itemFood: UserRequestTypeFireStore?, keyFood: String?) {
        self.item = item
        self.itemFood = itemFood
        self.keyFood = keyFood
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        // todo: Implement business logic here.
        getCurrentStatusRequest()
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    @Replay(queue: MainScheduler.asyncInstance) private var mDisplayName: String
    var typeRequest: ProcessRequestType = .INIT
    private lazy var network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
    @Replay(queue: MainScheduler.asyncInstance) private var mitemRequestOb: RequestResponseDetail
    private var zoneID: String?
    private var keyFood: String?
    /// Class's private properties.
}

// MARK: StatusRequestInteractable's members
extension StatusRequestInteractor: StatusRequestInteractable {
}

// MARK: StatusRequestPresentableListener's members
extension StatusRequestInteractor: StatusRequestPresentableListener {
    var keyFoodVC: String? {
        return self.keyFood
    }
    
    
    var itemRequest: RequestResponseDetail? {
        return self.item
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return self.indicator.asObservable()
    }
    
    func createRequestFood(content: String) {
        guard let id = self.itemFood?.id else { return }
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let zoneID = self.zoneID ?? "0"
        let p: [String : Any] = ["request_type_id": id,
                 "content": content,
                 "zone_id": zoneID,
                 "app_version": appVersion]
        let url = TOManageCommunication.path("/support/requests")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: p, useFullPath: true)
        network.request(using: router,
                                      decodeTo: OptionalMessageDTO<RequestResponseDetail>.self,
                                      method: .post,
                                      encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                switch result {
                case .success(let d):
                    if d.fail == false {
                        self?.getCurrentStatusRequest()
                    } else {
                        self?.router?.showAlerError(message: d.message ?? "")
                    }
                case .failure(let e):
                    self?.router?.showAlerError(message: e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
    
    var itemFoodVC: UserRequestTypeFireStore? {
        return self.itemFood
    }
    
    var itemRequestObsr: Observable<RequestResponseDetail> {
        return $mitemRequestOb
    }
    
    func updateStatus(item: RequestResponseDetail?) {
        if let item = item {
            let p = ["content": item.content ?? "",
                     "status": item.status.rawValue] as [String : Any]
            guard let id = item.id else { return }
            let url = TOManageCommunication.path("/support/requests/\(id)/status")
                    let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: p, useFullPath: true)
                    let dispose = network.request(using: router,
                                                  decodeTo: OptionalMessageDTO<RequestResponseDetail>.self,
                                                  method: .put,
                                                  encoding: JSONEncoding.default)
                        .trackProgressActivity(self.indicator)
                        .bind { [weak self](result) in
                            switch result {
                            case .success(let d):
                                if d.fail == false {
                                    if item.status == .CLOSE {
                                        self?.listener?.statusRequesttMoveBack()
                                    } else {
                                        self?.getCurrentStatusRequest()
                                    }
                                } else {
                                    self?.router?.showAlerError(message: d.message ?? "")
                                }
                            case .failure(let e):
                                self?.router?.showAlerError(message: e.localizedDescription)
                            }
            }.disposeOnDeactivate(interactor: self)
        }
    }
    
    func moveToWeb() {
        let url: URL = "https://vato.vn/quy-che-hoat-dong-va-dieu-khoan"
        let viewController = WebVC(with: url, title: nil, type: .default)
        viewController.modalPresentationStyle = .fullScreen
        self.router?.viewControllable.uiviewController.present(viewController, animated: true, completion: nil)
    }

    var titleNameObs: Observable<String> {
        return $mDisplayName
    }
    
    func statusRequesttMoveBack() {
        self.listener?.statusRequesttMoveBack()
    }
    
}

// MARK: Class's private methods
private extension StatusRequestInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
        self.getLatestLocation()
    }
    private func getLatestLocation() {
        let d = UserManager.shared.getCurrentUser()?.user?.nickname
        let f = UserManager.shared.getCurrentUser()?.user?.fullName
        if let zoneID = UserManager.shared.getCurrentUser()?.zoneId {
            self.zoneID = String(zoneID)
        }
        let displayName = d?.orEmpty(f ?? "")
        self.mDisplayName = displayName ?? ""
    }
    func getCurrentStatusRequest() {
        let url = TOManageCommunication.path("/support/requests/current")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true)
        
        network
            .request(using: router, decodeTo: OptionalMessageDTO<RequestResponseDetail>.self)
            .trackProgressActivity(self.indicator)
            .bind { [weak self] (result) in
                guard let me = self else { return }
                switch result {
                case .success(let s):
                    guard let data = s.data else { return }
                    me.mitemRequestOb = data
                case .failure(let e):
                    self?.router?.showAlerError(message: e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
        
    }
}
