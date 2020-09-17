//  File name   : TOManageCommunication.swift
//
//  Author      : Dung Vu
//  Created date: 2/21/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import VatoNetwork
import RxSwift
import Alamofire
import RxCocoa
import FirebaseFirestore

enum TaxiEnqueueType: String, Codable {
    case enqueueRequest = "TAXI_ENQUEUE_REQUEST"
    case dequeueRequest = "TAXI_DEQUEUE_REQUEST"
    case queuechanged = "TAXI_QUEUE_CHANGED"
    case enqueueInvitation = "TAXI_ENQUEUE_INVITATION"
}

enum TaxiRequestAction: String, Codable {
    case reject = "REJECT"
    case approve = "APPROVE"
    case new = "NEW"
    case INIT = "INIT"
    case timeout = "TIMEOUT"
    case confirm = "CONFIRM"
}

enum TaxiModelDisplayType {
    case reject
    case invited
    case watingResponse
    case approve
    case timeout
    case none
}

enum TaxiQUEUEType: String, Codable {
    case none = "NONE"
    case ready = "READY"
    case waiting = "WAITING"
}

extension TaxiModelDisplayType {
    
    var buttonDispayType: TODetailLocationVC.ActionButtonType {
        switch self {
        case .approve:
            return .leaveQueue
        case .none, .reject:
            return .request
        case .watingResponse, .invited:
            return .cancelRequest
        default:
            return .cancelRequest
        }
    }
}

protocol TaxiOperationDisplay {
    var id: Int? { get set }
    var operator_name: String? { get }
    var reason: String? { get }
    var stationName: String? { get }
    var queue: String? { get set }
    var stationId: Int? { get }
    var type: TaxiModelDisplayType? { get set }
    var address: TOPickupLocation.Address? { get }
    var distance: String? { get }
    var orderNumber: Int? { get set }
    var firestore_listener_path : String?  { get set }
    var expired_at: Double? { get }
    var created_at: Double? { get }
}

protocol PickupLocationProtocol {
    var address: TOPickupLocation.Address? { get }
    var pickupId: Int? { get }
}

extension PickupLocationProtocol {
    var params: [String: Any]? {
        guard let pickupId = pickupId else { return nil }
        guard let currentLocation = VatoLocationManager.shared.location else {
            return nil
        }
        let json = ["lat": currentLocation.coordinate.latitude, "lon": currentLocation.coordinate.longitude]
        var result: [String: Any] = ["location": json]
        result["pickup_station_id"] = pickupId
        result["timestamp"] = Int64(FireBaseTimeHelper.default.currentTime)
        result["driver_id"] = UserManager.shared.getUserId()
        return result

    }
}

// MARK: - Give event update UI
protocol TOManageCommunicationProtocol {
    var event: Observable<[TaxiOperationDisplay]> { get }
    var changeQueue: Observable<TaxiQUEUEType> { get }
    var registrations: Observable<[TaxiOperationDisplay]> { get }
    var notifications: Observable<[NotifyTaxi]> { get }
    var error: Observable<NSError> { get }
    var listClosePickupStation: Observable<[TOPickupLocation]> { get }
    var listJoinedPickupStation: Observable<[TOPickupLocation]> { get }
    var listInvitation: Observable<[TOPickupInvitation]> { get }
    var eLoadingObser: Observable<(Bool, Double)> { get }
}

// MARK: - Send Request
protocol TOManageCommunicationSendRequestProtocol {
    func requestJoinGroup(pickup: PickupLocationProtocol?)
    func removeEventLocal(m: TaxiOperationDisplay?)
}


// MARK: - Fill Info
protocol TOManageCommunicationRequireInfoProtocol {
    // Finding market in radius 500m
    func requestStationLocations() ///taxi/drivers/pickup-stations
    func requestGroupsCanJoin() ///taxi/drivers/joined-pickup-stations
    func requestListInvitation() ///taxi/drivers/invitations
    func requestRegistration()
    
}

protocol TOManageCommunicationUpdateUserProtocol {
    func update(user: VatoDriverProtocol?)
}

protocol TOManageCommunicationServiceProtocol {
    func start()
    func stop()
    func cleanUp()
}

typealias BlockExcute<T> = (T) -> ()
func excuting<T>(blocks: BlockExcute<T>...) -> BlockExcute<T> {
    return { v in blocks.forEach { $0(v) } }
}

struct TOCountDown {
    let time: Date
    let remain: Int
    let total: Int
}


@objcMembers
final class TOManageCommunication: NSObject, TOManageCommunicationRequireInfoProtocol, TOManageCommunicationSendRequestProtocol, TOManageCommunicationProtocol, ActivityTrackingProgressProtocol, ModifyHostProtocol {
    static var host: String {
        #if DEBUG
        return "https://api-dev.vato.vn"
         #else
        return "https://api.vato.vn"
         #endif
    }
    
    
    var changeQueue: Observable<TaxiQUEUEType> {
        return $currentQueueType.asObserver()
    }
    
    var registrations: Observable<[TaxiOperationDisplay]> {
        $mListRegistration.flatMap { (l) -> Observable<[TaxiOperationDisplay]> in
            let r = l.filter { $0.status == .INIT || $0.status == .new }.compactMap { TaxiModel(eventModel: $0, type: .watingResponse) }
            return Observable.just(r)
        }
        
    }
    
    var error: Observable<NSError> {
        return $mError.asObservable()
    }
    
    var listJoinedPickupStation: Observable<[TOPickupLocation]> {
        return $mListJoinedPickupStation.asObservable()
    }
    
    var listInvitation: Observable<[TOPickupInvitation]> {
        return $mListInvitation.asObservable()
    }
    
    var listClosePickupStation: Observable<[TOPickupLocation]> {
        return $mListClosePickupStation.asObservable()
    }
    
    var event: Observable<[TaxiOperationDisplay]> {
        return $mListEvent.asObservable()
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return indicator.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    
    var notifications: Observable<[NotifyTaxi]> {
        return $mNotifications.observeOn(MainScheduler.asyncInstance)
    }
    
    func refresh() {
        excuting(blocks: addTrackData, requestRegistration, requestStationLocations, requestGroupsCanJoin, requestListInvitation)(())
    }
    
    /// Class's public properties.
    struct Configs {
        static let genError: (String?) -> NSError = { messge in
            return NSError(domain: NSURLErrorDomain,
                           code: NSURLErrorUnknown,
                           userInfo: [NSLocalizedDescriptionKey: messge ?? "Chức năng tạm thời gián đoạn. Vui lòng thử lại sau."])
        }
    }
    
    static let shared = TOManageCommunication()
    let timeStarted: TimeInterval = FireBaseTimeHelper.default.currentTime
    internal private (set) lazy var lock: NSRecursiveLock = NSRecursiveLock()
    internal lazy var listenerManager: [Disposable] = []
    // Cache by id , to check time
    private var currentRequest: [Int: TOPickupRequest] = [:]
    
    private lazy var network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
    /// Class's constructors.
    
    @VariableReplay(wrappedValue: []) var mListPickupStation: [TOPickupLocation]
    @VariableReplay(wrappedValue: []) private var mListRegistration: [TOPickupInvitation]
    @VariableReplay(wrappedValue: []) private var mListInvitation: [TOPickupInvitation]
    @VariableReplay(wrappedValue: []) private var mListJoinedPickupStation: [TOPickupLocation]
    
    @VariableReplay(wrappedValue: []) private var mListClosePickupStation: [TOPickupLocation]
    @VariableReplay(wrappedValue: []) private (set) var mListEvent: [TaxiOperationDisplay]
    @VariableReplay(wrappedValue: nil) private (set) var user: VatoDriverProtocol?
    
    @VariableReplay(wrappedValue: []) var mNotifications: [NotifyTaxi]
    @Replay(queue: MainScheduler.asyncInstance) private var mCountContract: Int
    
    
    private (set) var manageTimer: [Int: BehaviorRelay<TOCountDown>] = [:]
    private var cacheFireStoreListnerPath: String = ""
    private var disposeBag = DisposeBag()
    @Published private var mError: NSError
    @Published private var currentQueueType: TaxiQUEUEType
    
}

// MARK: -- Manage Service
extension TOManageCommunication: TOManageCommunicationServiceProtocol {
    func start() {
        currentQueueType = .none
        stop()
        self.refresh()
    }
    
    func stop() {
        self.excute { [unowned self] in self.currentRequest.removeAll(); self.manageTimer = [:] }
        cleanUpListener()
    }
    
    func cleanUp() {
        user = nil
    }
    
    func leaveGroup() {
        guard let joinedModel = self.mListEvent.first(where: { $0.type == .approve }),
            let stationId = joinedModel.stationId else { return }
            let url = TOManageCommunication.path("/taxi/drivers/pickup-stations/\(stationId)")
            let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true)
            let dispose = network.request(using: router,
                                          decodeTo: OptionalMessageDTO<String>.self,
                                          method: .delete,
                                          encoding: JSONEncoding.default)
                .trackProgressActivity(self.indicator)
                .bind { [weak self](result) in
                    switch result {
                    case .success:
                        self?.start()
                    case .failure(let e):
                        print(e.localizedDescription)
                        
                    }
            }
            add(dispose)
        }
    func fireStoreNotify() {
        guard let id = UserManager.shared.getUserId() else {
            return
        }
        let collectionRef = Firestore.firestore().collection(collection: .notifications, .custom(id: "\(id)"), .custom(id: "driver"))
            .whereField("type", isEqualTo: "CAR_RENTAL_ORDER")
        collectionRef.listenChanges().map { $0[.added] }.filterNil().bind { (data) in
            self.getListContractActive()
        }.disposed(by: disposeBag)
    }
    private func getListContractActive() {
                   let p: [String: Any] = ["page": 0, "size": 10, "filter": "ACTIVE"]
                    let url = TOManageCommunication.path("/rental-car/driver/orders?\(p.queryString)")
                    let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true)
                    let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
                    network.request(using: router,
                                    decodeTo: OptionalMessageDTO<OrderContractData>.self,
                                    method: .get,
                                    encoding: JSONEncoding.default)
                        .bind { (result) in
                            switch result {
                            case .success(let r):
                                if r.fail == false {
                                    guard let data = r.data else {
                                        return
                                    }
                                    self.mCountContract = data.total ?? 0
                                } else {
                                    print(r.message ?? "")
                                }
                            case .failure(let e):
                                print(e.localizedDescription)
                            }
                    }.disposed(by: disposeBag)
    }
    func countContract(completion: ((Int) -> ())?) {
        self.$mCountContract.asObservable().bind { (value) in
            completion?(value)
        }.disposed(by: disposeBag)
    }
        
}


// MARK: -- Request
extension TOManageCommunication {
    func requestStationLocations() {
        let url = TOManageCommunication.path("/taxi/drivers/joined-pickup-stations")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true)
        let dispose = network.request(using: router, decodeTo: OptionalMessageDTO<[TOPickupLocation]>.self).bind { [weak self] (result) in
            guard let me = self else { return }
            switch result {
            case .success(let s):
                if let data = s.data {
                    me.mListJoinedPickupStation = data.sorted(by: { $0.currentDistance ?? 0 < $1.currentDistance ?? 0 })
                }
            case .failure(let e):
                print(e.localizedDescription)
            }
        }
        add(dispose)
    }
    
    func requestGroupsCanJoin() {
        let url = TOManageCommunication.path("/taxi/drivers/pickup-stations")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true)
        let dispose = network.request(using: router, decodeTo: OptionalMessageDTO<[TOPickupLocation]>.self).bind { [weak self](result) in
            guard let me = self else { return }
            switch result {
            case .success(let s):
                if var data = s.data {
                    data = data.sorted(by: { $0.currentDistance ?? 0 < $1.currentDistance ?? 0 })
                    me.mListPickupStation = data 
                    me.mListClosePickupStation = data.filter { $0.isClose() }
                }
            case .failure(let e):
                print(e.localizedDescription)
            }
        }
        add(dispose)
    }
    
    func requestListInvitation() {
        let url = TOManageCommunication.path("/taxi/drivers/invitations")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true)
        let dispose = network.request(using: router, decodeTo: OptionalMessageDTO<[TOPickupInvitation]>.self).bind {[weak self] (result) in
            guard let me = self else { return }
            switch result {
            case .success(let s):
                if let data = s.data {
                    let new = Set(data.sorted(by: { $0.currentDistance ?? 0 < $1.currentDistance ?? 0 }))
                    let arr = Array(new)
                    let currentTime = FireBaseTimeHelper.default.currentTime
                    me.mListInvitation = arr.filter { $0.expired_at ?? 0 > Double(currentTime) }
                }
            case .failure(let e):
                print(e.localizedDescription)
            }
        }
        add(dispose)
    }
    
    func requestRegistration() {
        let url = TOManageCommunication.path("/taxi/drivers/registrations?status=INIT&include_expire=false&page=0&size=50")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true)
        let dispose = network.request(using: router, decodeTo: OptionalMessageDTO<[TOPickupInvitation]>.self).bind {[weak self] (result) in
            guard let me = self else { return }
            switch result {
            case .success(let s):
                if var data = s.data {
                    data = data.sorted(by: { $0.currentDistance ?? 0 < $1.currentDistance ?? 0 })
                    
                    let currentTime = FireBaseTimeHelper.default.currentTime
                    me.mListRegistration = data.filter { $0.expired_at ?? 0 > Double(currentTime) }
                }
            case .failure(let e):
                print(e.localizedDescription)
            }
        }
        add(dispose)
    }
    
    func removeEventLocal(m: TaxiOperationDisplay?) {
        self.mListEvent.removeAll(where: { $0.id == m?.id })
    }
    
    func requestJoinGroup(pickup: PickupLocationProtocol?)  {
        guard var p = pickup?.params else {
            return
        }
        let vehicle = ["brand_id": user?.taxiBrandId ?? 0,
                       "id": user?.userId ?? 0,
                       "plate": user?.plate ?? "",
                       "market_name": user?.marketName ?? ""] as [String : Any]
        p["vehicle"] = vehicle
        let url = TOManageCommunication.path("/taxi/drivers/registrations")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: p, useFullPath: true)
        let dispose = network.request(using: router,
                                      decodeTo: OptionalMessageDTO<TOPickupRequest>.self,
                                      method: .post,
                                      encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                switch result {
                case .success(let d):
                    if d.fail == false {
                        guard var request = d.data else { return }
                        request.station_id = pickup?.pickupId ?? 0
                        self?.add(request: request)
                    } else {
                        self?.mError = Configs.genError(d.message)
                    }
                case .failure(let e):
                    self?.mError = e as NSError
                }
        }
        add(dispose)
    }
    
    func driverActionInvitation(invitationId: Int, action: TaxiRequestAction) {
        let url = TOManageCommunication.path("/taxi/drivers/invitations/\(invitationId)")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: ["status": action.rawValue], useFullPath: true)
        
        let dispose = network.request(using: router,
                                      decodeTo: OptionalIgnoreMessageDTO<RequestSuccesResponse>.self,
                                      method: .post,
                                      encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                switch result {
                case .success(let d):
                    if d.fail == false {
                        var listEvent = self?.mListEvent ?? []
                        if action == .reject {
                            listEvent.removeAll(where: { $0.id == invitationId })
                            self?.mListEvent = listEvent
                        } else {
                            guard let index = listEvent.firstIndex(where: { $0.id == invitationId} ) else { return }
                            var model = listEvent.remove(at: index)
                            model.type = .approve
                            model.firestore_listener_path = d.data?.path
                            listEvent.insert(model, at: 0)
                            self?.listenDeleteStationQueue(path: model.firestore_listener_path ?? "")
                            self?.listenStationQueue(path: model.firestore_listener_path ?? "")
                            self?.mListEvent = listEvent
                        }
                    } else {
                        self?.mError = Configs.genError(d.message)
                    }
                case .failure(let e):
                    self?.mError = e as NSError
                }
                
        }
        add(dispose)
    }
    
    func leavePickupStation(pickupStationId: Int, complete:(()->Void)? = nil) {
        let url = TOManageCommunication.path("/taxi/drivers/pickup-stations/\(pickupStationId)")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: ["pickupStationId": pickupStationId], useFullPath: true)
        
        let dispose = network.request(using: router,
                                      decodeTo: OptionalMessageDTO<Int>.self,
                                      method: .delete,
                                      encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                switch result {
                case .success(let d):
                    if d.fail == false {
                        self?.start()
                        // guard let request = d.data else { return }
                    } else {
                        self?.mError = Configs.genError(d.message)
                    }
                    complete?()
                case .failure(let e):
                    self?.mError = e as NSError
                    complete?()
                }
                
        }
        add(dispose)
    }
    
    func update(user: VatoDriverProtocol?) {
        self.user = user
    }
    
    func cancelQueueWhenReceiveOtherTrip() {
        guard let joinedModel = self.mListEvent.first(where: { $0.type == .approve }),
            let stationId = joinedModel.stationId else { return }
        self.leavePickupStation(pickupStationId: stationId, complete: { [weak self] in
            self?.mListEvent = []
            self?.stop()
        })
    }
    
    func startObserWhenFinishTrip() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let dispose = VatoPermission.shared.hasPermissionTaxi(uid: uid).take(1).bind { [weak self] (value) in
            if value == true {
                self?.start()
            }
        }
        add(dispose)
    }
    
}

// MARK: -- Handler Listen
extension TOManageCommunication: ManageListenerProtocol {
    private func addTracking(requestId: Int, user: UInt64) {
        let collectionRef = Firestore.firestore().collection(collection: .notifications, .custom(id: "\(user)"), .custom(id: "driver")).whereField("id", isEqualTo: requestId)
        let dispose = collectionRef.listenChanges().bind { (result) in
            print(result)
        }
        add(dispose)
    }
    
    func add(request: TOPickupRequest) {
        // Cache request
        self.excute(block: { [unowned self] in self.currentRequest[request.id] = request })
        
        let run = { [unowned self] in
            var listEvent = self.mListEvent
            if let index = listEvent.firstIndex(where: { $0.stationId == request.station_id && $0.type == TaxiModelDisplayType.none }) {
                var model = listEvent.remove(at: index)
                model.id = request.id
                model.type = .watingResponse
                listEvent.insert(model, at: 0)
                self.mListEvent = listEvent
            } else if let station = self.mListPickupStation.first(where: { $0.pickupStationId ==  request.station_id }) {
                var m = TaxiModel(station: station, type: .watingResponse)
                m.id = request.id
                listEvent.insert(m, at: 0)
                self.mListEvent = listEvent
            }
        }
        
        defer {
            run()
        }
        
        let expireDelta = request.expired_at - FireBaseTimeHelper.default.currentTime
        guard expireDelta > 0 else { return}
        // Timer
        let total = Int(expireDelta / 1000)
        let countDount = TOCountDown(time: Date(), remain: total, total: total)
        let cacheTimer = BehaviorRelay<TOCountDown>(value: countDount)
        self.manageTimer[request.station_id] = cacheTimer
        var disposeTimer: Disposable?
        disposeTimer = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.asyncInstance).bind (onNext: { [weak self](_) in
            guard let wSelf = self, let timer = wSelf.manageTimer[request.station_id] else { return  }
            
            let current = timer.value
            let time = abs(current.time.timeIntervalSinceNow)
            let remain = max(current.total - Int(time), 0)
            let new = TOCountDown(time: current.time, remain: remain, total: current.total)
            timer.accept(new)
            if (remain <= 0) {
                var listEvent = self?.mListEvent ?? []
                // remove event (pending)
                if let index = listEvent.firstIndex(where: { $0.id == request.id}) {
                    listEvent.remove(at: index)
                }
                
                // add against station to list
                if listEvent.contains(where: { $0.stationId == request.station_id && $0.type != .reject }) == false,
                    let station = self?.mListClosePickupStation.first(where: { $0.pickupStationId == request.station_id}) {
                    listEvent.append(TaxiModel(station: station, type: TaxiModelDisplayType.none))
                }
                self?.mListEvent = listEvent
                disposeTimer?.dispose()
            }
        })
        guard let d = disposeTimer else { return }
        add(d)
    }
    
    func addExpireEvent(request: TOPickupRequest) { // event reject/ invition
        let expireDelta = request.expired_at - FireBaseTimeHelper.default.currentTime
        guard expireDelta > 0 else { return}
        // Timer
        let dispose = Observable<Int>.interval(.milliseconds(Int(expireDelta)), scheduler: MainScheduler.asyncInstance)
            .take(1)
            .bind(onNext: { [weak self] _ in
                var listEvent = self?.mListEvent ?? []
                // remove event
                if let index = listEvent.firstIndex(where: { $0.id == request.id}) {
                    listEvent.remove(at: index)
                }
                
                // add against station to list
                if  listEvent.contains(where: { $0.stationId == request.station_id && $0.type != .reject }) == false,
                    let station = self?.mListClosePickupStation.first(where: { $0.pickupStationId == request.station_id}) {
                    listEvent.append(TaxiModel(station: station, type: TaxiModelDisplayType.none))
                }
                self?.mListEvent = listEvent
            })
        add(dispose)
    }
}

extension TOManageCommunication: TOManageCommunicationUpdateUserProtocol {}

private extension TOManageCommunication {
    private func addTrackData() {
        let d1 = Observable.combineLatest($mListRegistration.asObservable(), $mListInvitation.asObservable(), $mListJoinedPickupStation.asObservable(), $mListClosePickupStation.asObservable())
            .bind {[weak self] (listRegistration, listInvitation, listJoinedPickupStation, listClosePickupStation) in
                
                self?.processData(listRegistration: listRegistration, listInvitation: listInvitation, listJoinedPickupStation: listJoinedPickupStation, listClosePickupStation: listClosePickupStation)
                
        }
        add(d1)
        obserEvent()
    }
    
    func processData(listRegistration: [TOPickupInvitation],
                     listInvitation: [TOPickupInvitation],
                     listJoinedPickupStation: [TOPickupLocation],
                     listClosePickupStation: [TOPickupLocation]) {
        
        var listEvent: [TaxiOperationDisplay] = []
        
        // joined
        if !listJoinedPickupStation.isEmpty, let first = listJoinedPickupStation.first {
            listEvent.addOptional(TaxiModel(station: first, type: .approve))
        }
        
        // list request registration : waiting
        listRegistration
            .filter { $0.status == .INIT || $0.status == .new }
            .forEach { (registration) in
                listEvent.addOptional(TaxiModel(eventModel: registration, type: .watingResponse))
        }
        
        // list invitation
        listInvitation.forEach { (invitation) in
            listEvent.addOptional(TaxiModel(eventModel: invitation, type: .invited))
        }
        
        // sort list event follow created_at
        listEvent = listEvent.sorted(by: { $0.created_at ?? 0 > $1.created_at ?? 0 })
        
        // list station
        listClosePickupStation.forEach { (station) in
            if !listEvent.contains(where: { $0.stationId == station.id }) {
                listEvent.addOptional(TaxiModel(station: station, type: TaxiModelDisplayType.none))
            }
        }
        
        if let approveModel = listEvent.first(where: { $0.type == .approve }),
            let firestore_listener_path = approveModel.firestore_listener_path {
            
            self.listenDeleteStationQueue(path: firestore_listener_path)
            self.listenStationQueue(path: firestore_listener_path)
        }
        self.mListEvent = listEvent
    }
    
    
    
    func listenChangeDistance() {
        let eLocation = VatoLocationManager.shared.$locations.map { $0.last }.filterNil().distinctUntilChanged { (c1, c2) -> Bool in
            let b = abs(c1.distance(from: c2)) >= 500
            return !b
        }.map { _ in
            true
        }
        
        let eInterval = Observable<Int>.interval(.seconds(900), scheduler: MainScheduler.asyncInstance).skip(1).map { _ in true }
        
        let dispose = Observable.merge([eLocation, eInterval]).flatMap { [weak self] _ -> Observable<[TOPickupLocation]> in
            guard let wSelf = self else { return Observable.empty() }
            return wSelf.$mListPickupStation.take(1)
        }.bind { [weak self](data) in
            self?.mListClosePickupStation = data.filter({ $0.isClose() })
        }
        add(dispose)
    }
}
// MARK: -- Handler Listen event from fire store
private extension TOManageCommunication {
    
    func obserEvent() {
        let dispose = self.$user.filterNil().take(1).bind { [weak self](user) in
            self?.listen(userId: user.userId)
            self?.listenChangeDistance()
        }
        add(dispose)
    }
    
    private func listen(userId: UInt64) {
        let collectionRef = Firestore.firestore().collection(collection: .notifications, .custom(id: "\(userId)"), .custom(id: "driver"))
        let dispose = collectionRef.listenNotificationTaxi().skip(1).subscribe(onNext: { [weak self] (l) in
            let modify = l.documentsChange?.compactMap { try? $0.decode(to: NotifyTaxi.self) } ?? []
            let add = l.documentsAdd?.compactMap { try? $0.decode(to: NotifyTaxi.self) } ?? []
            let r = modify + add
            self?.mNotifications = r
            self?.processNotify(l: r)
            })
        add(dispose)
    }
    
    private func listenDeleteStationQueue(path: String) {
        let userID = UserManager.shared.getUserId()
        let collectionRef = Firestore.firestore().document(path)
        collectionRef.find(action: .listen, json: nil).skip(1).filter {
            $0?.data()?["\(userID ?? 0)"] == nil }.take(1).bind (onNext:{ [weak self] (d) in
                self?.start()
            }).disposed(by: disposeBag)
    }
    
    private func listenStationQueue(path: String) {
        let collectionRef = Firestore.firestore().document(path)
        let dispose = collectionRef.find(action: .listen, json: nil).debug("!!!listenNumberOder").bind { [weak self] (d) in
            let userID = UserManager.shared.getUserId()
            if let dic = d?.data()?["\(userID ?? 0)"] as? [String: AnyObject],
                var approveModel = self?.mListEvent.first(where: { $0.type == .approve }) {
                let order_number = dic["order_number"] as? Int ?? 1
                let status = dic["status"] as? String ?? "WAITING"
                let statusStr = (status == "WAITING") ? "Hàng đợi" : "Sẵn sàng"
                
                if let queueType = TaxiQUEUEType.init(rawValue: status) {
                    self?.currentQueueType = queueType
                }
                
                approveModel.orderNumber = Int(order_number)
                approveModel.queue = statusStr
                
                var listEvent = self?.mListEvent
                if let index = listEvent?.firstIndex(where: { $0.id == approveModel.id }) {
                    listEvent?.remove(at: index)
                }
                listEvent?.insert(approveModel, at: 0)
                self?.mListEvent = listEvent ?? []
            }
        }
        add(dispose)
    }
    private func changeQueueFromOperation() {
        let collectionRef = Firestore.firestore().document(self.cacheFireStoreListnerPath)
        collectionRef.find(action: .listen, json: nil).debug("!!!listenNumberOder").bind { [weak self] (d) in
            let userID = UserManager.shared.getUserId()
            if let dic = d?.data()?["\(userID ?? 0)"] as? [String: AnyObject],
                var approveModel = self?.mListEvent.first(where: { $0.type == .approve }) {
                let order_number = dic["order_number"] as? Int ?? 1
                let status = dic["status"] as? String ?? "WAITING"
                let statusStr = (status == "WAITING") ? "Hàng đợi" : "Sẵn sàng"
                
                if let queueType = TaxiQUEUEType.init(rawValue: status) {
                    self?.currentQueueType = queueType
                }
                
                approveModel.orderNumber = Int(order_number)
                approveModel.queue = statusStr
                
                var listEvent = self?.mListEvent
                if let index = listEvent?.firstIndex(where: { $0.id == approveModel.id }) {
                    listEvent?.remove(at: index)
                }
                listEvent?.insert(approveModel, at: 0)
                self?.mListEvent = listEvent ?? []
            }
        }.disposed(by: disposeBag)
    }
    
    private func processNotify(l: [NotifyTaxi]) {
        guard !l.isEmpty else { return }
        var listEvent = mListEvent
        l.forEach { (m) in
            if m.type == TaxiEnqueueType.enqueueRequest {
                /*notifcate operator approve/ reject  */
                if (m.payload?.status == .approve || m.payload?.status == .reject),
                    m.isExpire() == false {
                    
                    let type: TaxiModelDisplayType = (m.payload?.status == .approve) ? .approve  : .reject
                    listEvent.removeAll(where: { $0.id ==  m.payload?.id })
                    
                    listEvent.removeAll(where: { $0.stationId == m.payload?.pickupStationId && $0.type == .watingResponse })
                    listEvent.insert(TaxiModel(notify: m, type: type), at: 0)
                    
                    // add timer pending for event reject
                    if let id = m.payload?.id,
                        m.payload?.status == .reject,
                        let stationId = m.payload?.pickupStationId,
                        let expired_at = m.expired_at {
                        
                        let request = TOPickupRequest(id: id, expired_at: TimeInterval(expired_at), station_id: stationId)
                        self.addExpireEvent(request: request)
                    }
                }
            } else if m.type == .enqueueInvitation,
                (m.action == .new || m.action == .INIT),
                m.isExpire() == false {
                /* receive new invite */
                var model = TaxiModel(notify: m, type: .invited)
                if let  index = listEvent.firstIndex(where: { $0.type == .invited && $0.stationId == model.stationId}) {
                    let m = listEvent.remove(at: index)
                    model.expired_at = (m.expired_at ?? 0 > model.expired_at ?? 0) ? m.expired_at : model.expired_at
                }
                listEvent.removeAll(where: { $0.stationId == model.stationId && ($0.type == .invited || $0.type == TaxiModelDisplayType.none) })
                listEvent.insert(model, at: 0)
                
                // add timer pending for event invite
                if let id = m.payload?.id,
                    let stationId = m.payload?.pickupStationId,
                    let expired_at = m.expired_at {
                    
                    let request = TOPickupRequest(id: id, expired_at: TimeInterval(expired_at), station_id: stationId)
                    self.addExpireEvent(request: request)
                }
            }
        }
        if let approveModel = listEvent.first(where: { $0.type == .approve }) {
            // self.stop()
            if let firestore_listener_path = approveModel.firestore_listener_path {
                self.listenDeleteStationQueue(path: firestore_listener_path)
                self.cacheFireStoreListnerPath = firestore_listener_path
                self.listenStationQueue(path: firestore_listener_path)
            }
        }
        mListEvent = listEvent
        self.changeQueueFromOperation()
    }
}
