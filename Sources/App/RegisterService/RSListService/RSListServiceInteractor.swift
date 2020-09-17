//  File name   : RSListServiceInteractor.swift
//
//  Author      : MacbookPro
//  Created date: 4/27/20
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

enum RegisterServiceType {
    case haveCar
    case openFirst
}

protocol RSListServiceRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func registerService(type: RegisterServiceType, listCar: [CarInfo])
    func detactCurrentChild()
    func moveToPolicy(array: [ListServiceVehicel], strHtml: String, itemCar: Int64, isFromManage: Bool)
    func showAlerError(text: String)
    
}

protocol RSListServicePresentable: Presentable {
    var listener: RSListServicePresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol RSListServiceListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func moveBackTOShortcut()
    func moveBackToManageCar()
    func moveToBackHome()
}

final class RSListServiceInteractor: PresentableInteractor<RSListServicePresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: RSListServiceRouting?
    weak var listener: RSListServiceListener?
    private var listCar: [CarInfo]?
    private let listService: [CarInfo]?
    private let carManage: FCUCar?
    private let isFromManageCar: Bool
    /// Class's constructor.
    init(presenter: RSListServicePresentable, listCar: [CarInfo]?, listService: [CarInfo]?, isFromManageCar: Bool, carManage: FCUCar?) {
        self.listCar = listCar
        self.listService = listService
        self.carManage = carManage
        self.isFromManageCar = isFromManageCar
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        mtypeRegister = typeRegister
        if let carManage = self.carManage {
            mDisplayNameCar = carManage.marketName
            mDisplayNumberCar = carManage.plate
        }
        // todo: Implement business logic here.
    }
    private var typeRegister: RegisterServiceType = .openFirst
    private var typeRegisterObs: PublishSubject<RegisterServiceType> = PublishSubject.init()
    @Replay(queue: MainScheduler.asyncInstance) private var mtypeRegister: RegisterServiceType
    private var typeRegisterHaveCar: RegisterServiceType = .haveCar
    @Replay(queue: MainScheduler.asyncInstance) private var mDisplayName: String
    @Replay(queue: MainScheduler.asyncInstance) private var mCarInfo: CarInfo
    @Replay(queue: MainScheduler.asyncInstance) private var mListService: [ListServiceVehicel]
    @Replay(queue: MainScheduler.asyncInstance) private var mDisplayNameCar: String
    @Replay(queue: MainScheduler.asyncInstance) private var mDisplayNumberCar: String
    private lazy var network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
    private var itemCar: CarInfo?
    private let disposeBag = DisposeBag()
    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
}

// MARK: RSListServiceInteractable's members
extension RSListServiceInteractor: RSListServiceInteractable {


    func moveToShorcut(isFromManage: Bool) {
        if isFromManage {
            self.listener?.moveToBackHome()
        } else {
            self.listener?.moveBackTOShortcut()
        }
    }
    
    func moveBackListService(isFromManage: Bool)  {
            router?.dismissCurrentRoute(completion: nil)
    }
    
    func selectCar(itemCar: CarInfo) {
        typeRegister = .haveCar
        self.mCarInfo = itemCar
        self.itemCar = itemCar
        self.mDisplayNameCar = itemCar.marketName ?? ""
        self.mDisplayNumberCar = itemCar.plate ?? ""
        router?.detactCurrentChild()
        let idString = String(itemCar.id)
        getListServiceType(id: idString )
    }
    
    func dimiss(type: RegisterServiceType) {
        
    }
    
    func dimiss() {
        switch self.typeRegister {
        case .openFirst:
            router?.detactCurrentChild()
            self.listener?.moveBackTOShortcut()
        default:
            router?.detactCurrentChild()
        }
        
    }
    
}

// MARK: RSListServicePresentableListener's members
extension RSListServiceInteractor: RSListServicePresentableListener {
    func showAlert(text: String) {
        self.router?.showAlerError(text: text)
    }
    
    var displayName: Observable<String> {
        return $mDisplayNameCar
    }
    
    var displayNumber: Observable<String> {
        return $mDisplayNumberCar
    }
    
    var listServiceObs: Observable<[ListServiceVehicel]> {
        return $mListService.asObservable()
    }
    
    
    func moveToPolicy(array: [ListServiceVehicel]) {
        let text = array.map { "service=\($0.serviceID)" }.joined(separator: "&")
        let url = TOManageCommunication.path("/api/service-policies?\(text)")
        FirebaseTokenHelper.instance.eToken.filterNil().take(1).flatMap { (token) -> Observable<(HTTPURLResponse, Data)> in
            let router = VatoAPIRouter.customPath(authToken: token, path: url, header: nil, params: nil, useFullPath: true)
            return Requester.request(using: router)
        }.trackProgressActivity(self.indicator).subscribe { (event) in
            switch event {
            case .next(let item):
                let data = item.1
                let html = String(data: data, encoding: .utf8)
                
                if let html = html {
                    if self.isFromManageCar {
                        self.router?.moveToPolicy(array: array, strHtml: html, itemCar: self.carManage?.id ?? 0, isFromManage: true)
                    } else {
                        self.router?.moveToPolicy(array: array, strHtml: html, itemCar: self.itemCar?.id ?? 0 , isFromManage: false)
                    }
                    
                }
            case .error(let e):
                print(e.localizedDescription)
            default:
                break
            }
        }.disposeOnDeactivate(interactor: self)
        
    }
    
    var itemCarObs: Observable<CarInfo> {
        return $mCarInfo.asObservable()
    }
    
    var titleNameObs: Observable<String> {
        return $mDisplayName.asObservable()
    }
    
    func moveBackShortcut() {
        
        if self.isFromManageCar {
            self.listener?.moveBackToManageCar()
        } else {
            self.listener?.moveBackTOShortcut()
        }
    }
    
    
    func moveToRegisterService() {
        self.router?.registerService(type: typeRegister, listCar: self.listCar ?? [])
    }
    
}

// MARK: Class's private methods
private extension RSListServiceInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
        if self.isFromManageCar {
            if let id = self.carManage?.id {
                 self.getListServiceType(id: String(id))
                self.getListCar()
            }
        } else {
            $mtypeRegister.asObservable().bind { (type) in
                switch type {
                case .openFirst:
                    self.router?.registerService(type: type, listCar: self.listCar ?? [])
                case .haveCar:
                    break
                }
            }.disposed(by: disposeBag)

        }
        self.getName()
    }
    func getListCar() {
        let p: [String: Any] = ["page": 0, "size": 10]
        let url = TOManageCommunication.path("/api/vehicle")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: p, useFullPath: true)
        
        network
            .request(using: router, decodeTo: OptionalMessageDTO<[CarInfo]>.self)
            .trackProgressActivity(self.indicator)
            .bind { [weak self] (result) in
                guard let me = self else { return }
                switch result {
                case .success(let s):
                    me.listCar = s.data ?? []
                case .failure(let e):
                    print(e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
    private func getName() {
        let d = UserManager.shared.getCurrentUser()?.user?.nickname
        let f = UserManager.shared.getCurrentUser()?.user?.fullName
        
        let displayName = d?.orEmpty(f ?? "")
        self.mDisplayName = displayName ?? ""
        
    }
    func getListServiceType(id: String) {
        
        let url = TOManageCommunication.path("/api/vehicle/\(id)/services")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true)
        
        network
            .request(using: router, decodeTo: OptionalMessageDTO<[ListServiceVehicel]>.self)
            .trackProgressActivity(self.indicator)
            .bind { [weak self] (result) in
                guard let me = self else { return }
                switch result {
                case .success(let s):
                    
                    if s.fail == false {
                        me.mListService = s.data ?? []
                    } else {
                        me.mListService = []
                        self?.router?.showAlerError(text: s.message ?? "")
                    }
                case .failure(let e):
                    self?.router?.showAlerError(text: e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }

}
