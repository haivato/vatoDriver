//  File name   : TODetailLocationInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 2/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Alamofire
import KeyPathKit
import FirebaseFirestore
struct JoinPickUpDriverResponse: Codable {
    let id: Int?
    let expired_at: Double?
}

enum OnlineStatusType: Int, Codable {
    case DRIVER_UNREADY = 0
    case DRIVER_READY = 10
    case DRIVER_BUSY = 20
}

protocol TODetailLocationRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func showAlertError(text: String)
}

protocol TODetailLocationPresentable: Presentable {
    var listener: TODetailLocationPresentableListener? { get set }
    // todo: Declare methods the interactor can invoke the presenter to present data.
    func showAlertConfirm()
}

protocol TODetailLocationListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func TODetailLocationMoveBack()
}

final class TODetailLocationInteractor: PresentableInteractor<TODetailLocationPresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: TODetailLocationRouting?
    weak var listener: TODetailLocationListener?
    
    /// Class's constructor.
    init(presenter: TODetailLocationPresentable,
         pickUpStationId: Int?,
         firestore_listener_path: String?) {
        self.pickUpStationId = pickUpStationId
        self.firestore_listener_path = firestore_listener_path
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        
        // todo: Implement business logic here.
        self.getLocationInfo()
        self.listenStationQueue()
    }
    
    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    /// Class's private properties.
    @VariableReplay(wrappedValue: nil) private var mItem: TODetailLocationProtocol?
    @Replay(queue: MainScheduler.asyncInstance) private var mListDriver: ListPickUpDriver
    @VariableReplay(wrappedValue: TODetailLocationVC.ActionButtonType.request) private var mActionButtonType: TODetailLocationVC.ActionButtonType
    internal var pickUpStationId: Int?
    private lazy var network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
    private lazy var firebaseDatabase = Database.database().reference()
    private let firestore_listener_path: String?
    private var driveOnline: FirebaseModel.DriverOnlineStatus?
    var approveModel: TaxiOperationDisplay?
    
    func getLocationInfo() {
        guard let pickupStationId = self.pickUpStationId else { return }
        let stationDetailUrl = TOManageCommunication.path("/taxi/pickup-stations/\(pickupStationId)")
        let stationDetaiRouter = VatoAPIRouter.customPath(authToken: "", path: stationDetailUrl, header: nil, params: nil, useFullPath: true)
        
        
        let d1 = network.request(using: stationDetaiRouter, decodeTo: OptionalMessageDTO<TOPickupLocation>.self).map { (r) -> TOPickupLocation? in
            switch r {
            case .success(let s):
                return s.data
            case .failure(_):
                return nil
            }
        }
        
        let listDriverUrl = TOManageCommunication.path("/taxi/pickup-stations/\(pickupStationId)/drivers")
        let listDriverRouter = VatoAPIRouter.customPath(authToken: "", path: listDriverUrl, header: nil, params: nil, useFullPath: true)
        
        let d2 = network
            .request(using: listDriverRouter, decodeTo: OptionalMessageDTO<[TODriverInfoModel]>.self)
            .trackProgressActivity(indicator)
            .map { (r) -> [TODriverInfoModel]? in
                switch r {
                case .success(let s):
                    return s.data
                case .failure(_):
                    return nil
                }
        }
        
        Observable.zip(d1, d2).bind {[weak self] (pickUpLocation, listDriver) in
            guard let wSelf = self else { return }
            
            guard var location = pickUpLocation else { return }
            location.drivers = listDriver
            
            wSelf.mItem = location
            wSelf.mItem?.approveModel = wSelf.approveModel
            
            let d = listDriver?.groupBy(\.detailLocationVCType)
            let taxi4 = d?[.taxi4]?.groupBy(\.driverStatusType)
            let taxi7 = d?[.taxi7]?.groupBy(\.driverStatusType)
            
            let taxi4Ready = (taxi4?[.ready] ?? []).sorted(by: { $0.orderNumber ?? 0 < $1.orderNumber ?? 0 })
            let taxi4Waiting = (taxi4?[.waiting] ?? []).sorted(by: { $0.orderNumber ?? 0 < $1.orderNumber ?? 0 })
            
            let taxi7Ready = (taxi7?[.ready] ?? []).sorted(by: { $0.orderNumber ?? 0 < $1.orderNumber ?? 0 })
            let  taxi7Waiting = (taxi7?[.waiting] ?? []).sorted(by: { $0.orderNumber ?? 0 < $1.orderNumber ?? 0 })
            
            
            let allReady = (taxi4Ready + taxi7Ready).sorted(by: { $0.orderNumber ?? 0 < $1.orderNumber ?? 0 })
            let allWaiting = (taxi4Waiting + taxi7Waiting).sorted(by: { $0.orderNumber ?? 0 < $1.orderNumber ?? 0 })
            
            wSelf.mListDriver = [.all: [.ready: allReady, .waiting: allWaiting],
                                 .taxi4: [.ready: taxi4Ready, .waiting: taxi4Waiting],
                                 .taxi7: [.ready: taxi7Ready, .waiting: taxi7Waiting]]
        }.disposeOnDeactivate(interactor: self)
        
        TOManageCommunication.shared.event.bind { [weak self] (l) in
            if let approveModel = l.first(where: { $0.type == .approve && $0.stationId == self?.pickUpStationId }) {
                self?.approveModel = approveModel
                self?.mItem?.approveModel = approveModel
            } else {
                self?.approveModel = nil
                self?.mItem?.approveModel = nil
            }
        }.disposeOnDeactivate(interactor: self)
    }
    
    func actionButtonDidPressed() {
        switch mActionButtonType {
        case .request:
            guard let status = self.driveOnline?.status else {
                return
            }
            if status == .DRIVER_READY {
                self.requestJoinPickupStation()
            } else {
                self.router?.showAlertError(text: "Bạn hãy Online để tham gia xếp tài")
            }
            
        case .leaveQueue:
            self.presenter.showAlertConfirm()
        default:
            return
        }
    }
    
    func requestJoinPickupStation() {
        $mItem.take(1).map {
            TOManageCommunication.shared.requestJoinGroup(pickup: $0)
        }.bind { _ in
            self.getLocationInfo()
        }.disposeOnDeactivate(interactor: self)
    }
    
    func requestLeavePickupStation() {
        guard let pickupStationId = self.pickUpStationId else { return }
        TOManageCommunication.shared.leavePickupStation(pickupStationId: pickupStationId)
    }
    
    private func listenStationQueue() {
        guard let path = self.firestore_listener_path else { return }
        let collectionRef = Firestore.firestore().document(path)
        collectionRef.find(action: .listen, json: nil).bind { [weak self] (d) in
            self?.getLocationInfo()
        }.disposeOnDeactivate(interactor: self)
    }
}

// MARK: TODetailLocationInteractable's members
extension TODetailLocationInteractor: TODetailLocationInteractable {
}

// MARK: TODetailLocationPresentableListener's members
extension TODetailLocationInteractor: TODetailLocationPresentableListener {
    var eLoadingObser: Observable<(Bool, Double)> {
        return indicator.asObservable()
    }
    
    var actionButtonType: Observable<TODetailLocationVC.ActionButtonType> {
        return $mActionButtonType.asObservable()
    }
    
    var listDriver: Observable<ListPickUpDriver> {
        return $mListDriver
    }
    
    var item: Observable<TODetailLocationProtocol?> {
        return $mItem.asObservable()
    }
    
    func TODetailLocationMoveBack() {
        listener?.TODetailLocationMoveBack()
    }
}

// MARK: Class's private methods
private extension TODetailLocationInteractor {
    private func setupRX() {
        TOManageCommunication.shared.$mListEvent.bind { [weak self] (l) in
            if l.contains(where: { $0.stationId == self?.pickUpStationId && $0.type == .approve  }) {
                self?.mActionButtonType = .leaveQueue
            } else if l.contains(where: { $0.stationId == self?.pickUpStationId && $0.type == .watingResponse  }) {
                self?.mActionButtonType = .pending
            } else {
                self?.mActionButtonType = .request
            }
        }.disposeOnDeactivate(interactor: self)
        getOnlineStatus()
    }
    
    func getOnlineStatus() {
        guard let firebaseID = UserManager.shared.getCurrentUser()?.user.firebaseId else {
            return
        }
        let group = firebaseID.javaHash() % 10
        let node = FireBaseTable.driverOnline >>> FireBaseTable.custom(identify: String(group)) >>> FireBaseTable.custom(identify: firebaseID)
        firebaseDatabase.find(by: node, type: .value, using: { ref in
            ref.keepSynced(true)
            
            return ref
        }).subscribe(onNext: { [weak self](snapshot) in
            guard let wSelf = self else { return }
            do {
                wSelf.driveOnline = try FirebaseModel.DriverOnlineStatus.create(from: snapshot)
            } catch let e {
                print(e.localizedDescription)
            }
        }).disposeOnDeactivate(interactor: self)
    }
    
}
