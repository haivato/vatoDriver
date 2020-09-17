//  File name   : TOShortcutInteractor.swift
//
//  Author      : khoi tran
//  Created date: 2/17/20
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
import FirebaseFirestore


protocol TOShortcutRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToNearbyDriver()
    func routeToQuickSupport()
    func routeToOrder()
    func routeToBU()
    func routeToFavouritePlace()
    func routeToSetLocation()
    func processingRequest(item: RequestResponseDetail?, listQuickSupport: [UserRequestTypeFireStore], keyFood: String?)
    func registerFood(typeRequest: ProcessRequestType, item: UserRequestTypeFireStore, keyFood: String?)
    func registerService(listCar: [CarInfo], listService: [CarInfo])
    func showAlertErrorNoRequest(text: String)
}

protocol TOShortcutPresentable: Presentable {
    var listener: TOShortcutPresentableListener? { get set }
    
    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol TOShortcutListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func TOShortcutListenerMoveBack()
    func showTripDigital()
    func loadCreateCar()
    func showFavouritePlace()
}

final class TOShortcutInteractor: PresentableInteractor<TOShortcutPresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: TOShortcutRouting?
    weak var listener: TOShortcutListener?
    
    /// Class's constructor.
    init(presenter: TOShortcutPresentable, authenticated: AuthenticatedStream, mutableBookingStream: MutableBookingStream) {
        self.mutableBookingStream = mutableBookingStream
        self.authenticated = authenticated
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    
    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        // todo: Implement business logic here.
        //        self.initDummyData()
    }
    
    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    /// Class's private properties.
    private let authenticated: AuthenticatedStream
    private let mutableBookingStream: MutableBookingStream
    @VariableReplay(wrappedValue: []) private (set) var mDataSource: [TOShortutModel]
    @VariableReplay var currentLocation: AddressProtocol?
    private lazy var network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
    
    private var numberUnreadQuickSupport: Int = 0
    private var itemRequest: RequestResponseDetail?
    private var listQuickSupportRequest: [UserRequestTypeFireStore] = []
    private var listCar: [CarInfo] = []
    private var listService: [CarInfo] = []
    private var keyRegisterFood: String?
    @objc var bookingService: FCUCar?
    
    func initDummyData() {
        let uid = Auth.auth().currentUser?.uid
        VatoPermission.shared.hasPermissionTaxi(uid: uid).bind(onNext: weakify({ (grant, wSelf) in
            var source = [TOShortutModel]()
            
            var item5 = TOShortutModel(cellType: .normal, type: .favPlace)
            item5.name = "Điều hướng"
            item5.description = "Nhận cuốc xe về vị trí bạn muốn"
            item5.icon = #imageLiteral(resourceName: "ic_menu_direction")
            source.append(item5)
            
            
            var item4 = TOShortutModel(cellType: .normal, type: .autoReceiveTrip)
            item4.name = "Tự động nhận chuyến"
            item4.description = "Tự động nhận đơn"
            item4.icon = #imageLiteral(resourceName: "ic_autoreceive_trip.pdf")
            source.append(item4)
            
            var item2 = TOShortutModel(cellType: .normal, type: .quickSupport)
            item2.name = "Gửi hỗ trợ"
            item2.description = "Vấn đề về chuyến đi"
            item2.cellType = .badge
            item2.badgeNumber = wSelf.numberUnreadQuickSupport
            item2.icon = #imageLiteral(resourceName: "ic_quick_support.pdf")
            source.append(item2)
            
            var item6 = TOShortutModel(cellType: .normal, type: .processingRequest)
            item6.name = "Yêu cầu xử lý"
            item6.description = "Thay đổi thông tin, thanh lý tài khoản...."
            item6.icon = UIImage(named: "ic_process_request")
            source.append(item6)
            
            var item1 = TOShortutModel(cellType: .normal, type: .buyUniforms)
            item1.name = "Cửa hàng VATO "
            item1.description = "Mua áo, nón, túi giữ nhiệt"
            item1.icon = #imageLiteral(resourceName: "ic_uniform.pdf")
            source.append(item1)
            
            if grant {
                var item3 = TOShortutModel(cellType: .normal, type: .orderTaxi)
                item3.name = "Yêu cầu xếp tài"
                item3.description = "Điểm tiếp thị, yêu cầu hoặc huỷ xếp tài"
                item3.icon = #imageLiteral(resourceName: "ic_request_taxi.pdf")
                source.append(item3)
            }
            
            
            //            var item7 = TOShortutModel(cellType: .normal, type: .registerFood)
            //            item7.name = "Đăng kí dịch vụ Food"
            //            item7.description = "VATOBike, Giao hàng, VATOFood"
            //            item7.icon = UIImage(named: "ic_register_food")
            //            source.append(item7)
            var item8 = TOShortutModel(cellType: .normal, type: .registerService)
            item8.name = "Đăng kí dịch vụ"
            item8.description = "VATOBike, Giao hàng, VATOFood"
            item8.icon = UIImage(named: "ic_register_food")
            source.append(item8)
            
            
            wSelf.mDataSource = source
            
        })).disposeOnDeactivate(interactor: self)
    }
    
    func checkLocation() -> Observable<Void> {
        #if targetEnvironment(simulator)
        self.router?.routeToSetLocation()
        return self.$currentLocation.skip(1).take(1).map { _ in }
        #else
        // your real device code
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return Observable.just(())
        case .denied, .restricted:
            // Track
            self.router?.routeToSetLocation()
            return self.$currentLocation.skip(1).take(1).map { _ in }
        default:
            assert(false, "Check")
            return Observable.just(())
        }
        #endif
        
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
                    me.itemRequest = s.data
                case .failure(let e):
                    print(e.localizedDescription)
                    
                }
        }.disposeOnDeactivate(interactor: self)
        
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
    
    func getListService() {
        let p: [String: Any] = ["page": 0, "size": 10]
        let url = TOManageCommunication.path("/api/vehicle/list_driver_v2")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: p, useFullPath: true)
        
        network
            .request(using: router, decodeTo: OptionalMessageDTO<[CarInfo]>.self)
            .trackProgressActivity(self.indicator)
            .bind { [weak self] (result) in
                guard let me = self else { return }
                switch result {
                case .success(let s):
                    me.listService = s.data ?? []
                case .failure(let e):
                    print(e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
    
}

// MARK: TOShortcutInteractable's members
struct TOShorcutAddress: AddressProtocol {
    var coordinate: CLLocationCoordinate2D
    
    var name: String?
    
    var thoroughfare: String = ""
    
    var streetNumber: String = ""
    
    var streetName: String = ""
    
    var locality: String = ""
    
    var subLocality: String = ""
    
    var administrativeArea: String = ""
    
    var postalCode: String = ""
    
    var country: String = ""
    
    var lines: [String] = []
    
    var isDatabaseLocal: Bool = false
    
    var hashValue: Int = 1
    
    var zoneId: Int = 0
    
    var favoritePlaceID: Int64 = 0
    var isOrigin: Bool = false
    var counter: Int = 0
    var placeId: String?
    var distance: Double?
    
    func increaseCounter() {}
    func update(isOrigin: Bool) {}
    func update(zoneId: Int) {}
    func update(placeId: String?) {}
    func update(coordinate: CLLocationCoordinate2D?) {}
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
}

extension TOShortcutInteractor: TOShortcutInteractable, Weakifiable {
    func requestMoveBack() {
        
    }
    
    func moveToBackHome() {
        
    }
    
    func moveBackToManageCar() {
        
    }
    
    func moveBackTOShortcut() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func statusRequesttMoveBack() {
        getCurrentStatusRequest()
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func processingRequeestMoveBack() {
        getCurrentStatusRequest()
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func getAddress() {
        VatoLocationManager.shared.$locations.map { $0.last }.filterNil().take(1).bind(onNext: weakify({ (location, wSelf) in
            let new = TOShorcutAddress(coordinate: location.coordinate)
            wSelf.mutableBookingStream.updateBooking(originAddress: new)
        })).disposeOnDeactivate(interactor: self)
    }
    
    func setLocationMoveBack(_ address: AddressProtocol?) {
        router?.dismissCurrentRoute(completion: weakify({ (wSelf) in
            guard let address = address else { return }
            wSelf.mutableBookingStream.updateBooking(originAddress: address)
            MapInteractor.Config.defaultMarker = MarkerHistory.init(with: address)
            wSelf.currentLocation = address
        }))
    }
    func request() {
        let collectionRef = Firestore.firestore().collection(collection: .userRequestType)
        let query = collectionRef.whereField("active", isEqualTo: 1).whereField("appType", isEqualTo: UserRequestType.driver.rawValue).order(by: "position", descending: false)
        
        query
            .getDocuments()
            .trackProgressActivity(self.indicator)
            .map { $0?.compactMap { try? $0.decode(to: UserRequestTypeFireStore.self) } }
            .bind { (data) in
                guard let data = data else { return }
                self.listQuickSupportRequest = data
                
        }.disposeOnDeactivate(interactor: self)
    }
    
    func getIdRegisterFood() {
        let documentRef = Firestore.firestore().documentRef(collection: .configData, storePath: .custom(path: "Driver") , action: .read)
        
        documentRef
            .find(action: .get, json: nil, source: .server)
            .trackProgressActivity(self.indicator)
            .bind { (snapshot) in
            let d = snapshot?.data()
            let json: JSON? = d?.value(FirestoreTable.requestForApprovement.name, defaultValue: nil)
            let idFood: String? = json?.value("foodRegistrationId", defaultValue: nil)
            self.keyRegisterFood = idFood
        }.disposeOnDeactivate(interactor: self)
    }
        
    func buyUniformsMoveBackRoot() {
        listener?.TOShortcutListenerMoveBack()
    }
    
    
    func buyUniformsMainMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func TONearbyDriverBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func quickSupportMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func routeToQuickSupport() {
        router?.routeToQuickSupport()
    }
    
    func showTripDigital() {
        listener?.showTripDigital()
    }
    
    func routeToOrder() {
        router?.routeToOrder()
    }
    
    func TOOrderMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func getBadgeQuickSupport() {
        QuicksupportHelper.shared.requestUnread().bind { _ in }.disposeOnDeactivate(interactor: self)
    }
    func processingRequest() {
        let arRemoveFood = self.listQuickSupportRequest.filter { $0.id != self.keyRegisterFood }
        if arRemoveFood.count <= 0 {
            router?.showAlertErrorNoRequest(text: "Hiện tại chưa có danh sách nào.")
        } else {
            self.router?.processingRequest(item: self.itemRequest, listQuickSupport: arRemoveFood, keyFood: self.keyRegisterFood)
        }
        
    }
    func registerFood(typeRequest: ProcessRequestType) {
        guard let keyFood = self.keyRegisterFood else {
            router?.showAlertErrorNoRequest(text: "Hiện tại chưa mở dịch vụ Food .")
            return
        }
        
        let item = self.listQuickSupportRequest.filter { $0.id == keyFood }
        guard let itemFood = item.first else {
            router?.showAlertErrorNoRequest(text: "Hiện tại chưa mở dịch vụ Food .")
            return
        }
        router?.registerFood(typeRequest: typeRequest, item: itemFood, keyFood: self.keyRegisterFood)
    }
}

// MARK: TOShortcutPresentableListener's members
extension TOShortcutInteractor: TOShortcutPresentableListener {
    func registerService() {
        if self.listCar.count <= 0 {
            self.router?.showAlertErrorNoRequest(text: "Hiện tại bạn chưa có xe nào.")
            return
        }
        self.router?.registerService(listCar: self.listCar, listService: self.listService)
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return self.indicator.asObservable()
    }
    
    
    func routeToFavouritePlace() {
        self.listener?.showFavouritePlace()
    }
    
    func loadCreateCar() {
        listener?.loadCreateCar()
    }
    
    var dataSource: Observable<[TOShortutModel]> {
        return $mDataSource.asObservable()
    }
    
    func requestData() {
        self.initDummyData()
    }
    
    func routeToNearbyDriver() {
        self.router?.routeToNearbyDriver()
    }
    
    func TOShortcutListenerMoveBack() {
        self.listener?.TOShortcutListenerMoveBack()
    }
    
    func routeToBU() {
        checkLocation().bind(onNext: weakify({ (wSelf) in
            wSelf.router?.routeToBU()
        })).disposeOnDeactivate(interactor: self)
    }
}

// MARK: Class's private methods
private extension TOShortcutInteractor {
    private func setupRX() {
        QuicksupportHelper.shared.unreadNumber.bind { [weak self] number in
            var source = self?.mDataSource ?? []
            guard let index = source.firstIndex(where: { $0.cellType == .badge }) else { return }
            source[index].badgeNumber = number
            self?.mDataSource = source
        }.disposeOnDeactivate(interactor: self)
        
        mutableBookingStream.booking.bind(onNext: weakify({ (b, wSelf) in
            wSelf.currentLocation = b.originAddress
        })).disposeOnDeactivate(interactor: self)
        
        getAddress()
        getCurrentStatusRequest()
        request()
        getIdRegisterFood()
        getListCar()
//        getListService()
    }
}
