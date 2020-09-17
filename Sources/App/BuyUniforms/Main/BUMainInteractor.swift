//  File name   : BUMainInteractor.swift
//
//  Author      : vato.
//  Created date: 3/10/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Alamofire

protocol BUMainRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeBookingDetail()
    func routeToListStation(_ categoryId: Int, coordinate: CLLocationCoordinate2D)
}

protocol BUMainPresentable: Presentable {
    var listener: BUMainPresentableListener? { get set }
    // todo: Declare methods the interactor can invoke the presenter to present data.
    func showAlerConfirmChangStation(item: FoodExploreItem)
    func showHistory()
    func showError(error: NSError)
    func refreshHistory()
}

protocol BUMainListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func buyUniformsMainMoveBack()
    func buyUniformsMoveBackRoot()
}

final class BUMainInteractor: PresentableInteractor<BUMainPresentable> {
    struct Configs {
           static let genError: (String?) -> NSError = { messge in
               return NSError(domain: NSURLErrorDomain,
                              code: NSURLErrorUnknown,
                              userInfo: [NSLocalizedDescriptionKey: messge ?? "Chức năng tạm thời gián đoạn. Vui lòng thử lại sau."])
           }
       }
       
    
    /// Class's public properties.
    weak var router: BUMainRouting?
    weak var listener: BUMainListener?

    /// Class's constructor.
    init(presenter: BUMainPresentable,
         mutableStoreStream: MutableStoreStream,
         mutableBookingStream: MutableBookingStream) {
        self.mutableBookingStream = mutableBookingStream
        self.mutableStoreStream = mutableStoreStream
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        requestlist()
        setupRX()
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    func requestlist() {
        let e1 = mutableBookingStream.booking.map { $0.originAddress.coordinate }.take(1)
        let e2 = $categoryId.take(1)
        
        let e3 = Observable.zip(e1, e2) { (coord, id) -> JSON in
            var params: [String: Any] = ["indexPage": 0,
            "sizePage": 1,
            "lat": coord.latitude,
            "lon": coord.longitude,
            "status": 4,
            "sortParam": "ASC"]
            params["rootCategoryId"] = id
            return params
        }
        
        e3.flatMap { (params) -> Observable<Swift.Result<OptionalMessageDTO<FoodStoreResponse>, Error>> in
            let provider = NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil())
            let network = NetworkRequester(provider: provider)
            let router = VatoFoodApi.nearly(authenToken: "", params: params)
            return network.request(using: router, decodeTo: OptionalMessageDTO<FoodStoreResponse>.self)
        }.bind { [weak self] (result) in
            switch result {
            case .success(let r):
                let listStore = r.data?.listStore ?? []
                self?.stores = listStore
                self?.mutableStoreStream.update(store: listStore.first)
            case .failure(let e):
                print(e.localizedDescription)
            }
        }.disposeOnDeactivate(interactor: self)
    }
    /// Class's private properties.
    /*
    @VariableReplay(wrappedValue: [:]) private var mBasket: BasketModel
    @Replay(queue: MainScheduler.asyncInstance) var storesSelected: FoodExploreItem?
 */
    @VariableReplay(wrappedValue: []) private (set) var stores: [FoodExploreItem]
    @Replay(queue: MainScheduler.instance) var categoryId: Int
    private let mutableBookingStream: MutableBookingStream
    private lazy var trackProgress = ActivityProgressIndicator()

    private let mutableStoreStream: MutableStoreStream
}

// MARK: BUMainInteractable's members
extension BUMainInteractor: BUMainInteractable {
    
    func selectStationMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func buyUniformsDetailMoveBackRoot() {
        listener?.buyUniformsMoveBackRoot()
    }
    
    func buySuccess() {
        self.mutableStoreStream.update(basket: [:])
        self.router?.dismissCurrentRoute(completion: { [weak self] in
            self?.presenter.showHistory()
        })
    }
    
    func bookingDetailMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
}

// MARK: BUMainPresentableListener's members
extension BUMainInteractor: BUMainPresentableListener, Weakifiable {
    func routeToListStation() {
        let e1 = mutableBookingStream.booking.map { $0.originAddress.coordinate }.take(1)
        let e2 = $categoryId.take(1)
        
        Observable.zip(e1, e2) { (coord, id) -> (CLLocationCoordinate2D, Int) in
            return (coord, id)
        }.bind(onNext: weakify({ (item, wSelf) in
            wSelf.router?.routeToListStation(item.1, coordinate: item.0)
        })).disposeOnDeactivate(interactor: self)
    }
    
    func buyUniformsMoveBackRoot() {
        listener?.buyUniformsMoveBackRoot()
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return trackProgress.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    
    func updateState(state: StoreOrderState, idOrderOffline: String) {
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: VatoFoodApi.updateStateOrderOffline(authenToken: "", params: ["idOrderOffline": idOrderOffline, "state": state.rawValue]), decodeTo: OptionalMessageDTO<SalesOrder>.self, method: .put, encoding: JSONEncoding.default)
                  .trackProgressActivity(trackProgress)
                  .observeOn(MainScheduler.asyncInstance)
                  .subscribe({ [weak self] (event) in
                      guard let wSelf = self else  { return }
                      switch event {
                      case .next(let res):
                          switch res {
                          case .success(let r):
                              if let data = r.data {
                                wSelf.presenter.refreshHistory()
                              } else {
                                  let error = Configs.genError(r.message)
                                  wSelf.presenter.showError(error: error)
                              }
                          case .failure(_):
                              let e = Configs.genError(nil)
                              wSelf.presenter.showError(error: e)
                          }
                      default:
                          break
                      }
                  }).disposeOnDeactivate(interactor: self)
    }
    
    func didConfirmSelect(item: FoodExploreItem) {
        self.mutableStoreStream.update(basket: [:])
        self.mutableStoreStream.update(store: item)
    }
    
    func didContinue() {
        router?.routeBookingDetail()
    }
    
    func didSelect(item: FoodExploreItem) {
        let basket = mutableStoreStream.basket.take(1)
        let storesSelected = mutableStoreStream.store.take(1)
        
        Observable
            .combineLatest(basket, storesSelected)
            .timeout(0.3, scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { (basket, store) in
                if !basket.keys.isEmpty && store?.id != item.id {
                    self.presenter.showAlerConfirmChangStation(item: item)
                } else {
                    self.mutableStoreStream.update(store: item)
                }
            }, onError: { (_) in
                self.mutableStoreStream.update(store: item)
            }).disposeOnDeactivate(interactor: self)
        router?.dismissCurrentRoute(completion: nil)
    }
    
    var selectedEvent: Observable<FoodExploreItem?> {
        return mutableStoreStream.store
    }
    var source: Observable<[FoodExploreItem]> {
        return $stores.asObservable()
    }
    
    var basket: Observable<BasketModel> {
        return mutableStoreStream.basket
    }
    
    func update(item: DisplayProduct, value: BasketStoreValueProtocol?) {
        mutableStoreStream.update(item: item, value: value)
    }
    
    func requestData<T>(id: Int?, router: APIRequestProtocol) -> Observable<T> where T : Codable {
        guard let id = id else { return Observable.error(NSError(domain: NSURLErrorDomain, code: NSURLErrorDataNotAllowed, userInfo: [NSLocalizedDescriptionKey: "No id"])) }
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        let param = router.params
        return network.request(using: VatoFoodApi.listDisplayProduct(authToken: "", storeId: id, statusList:"3", params: param), decodeTo: OptionalMessageDTO<[DisplayProductCategory]>.self)
            .trackProgressActivity(self.trackProgress)
            .map { (r) -> T in
            switch r {
            case .success(let response):
                var arr = [DisplayProduct]()
                response.data?.forEach { arr += ($0.products ?? []) }
                let m = BUProductMainResponse(values: arr, next: (arr.count == BUChooseUniformVC.Config.pageSize))
                if let m = m as? T {
                    return m
                } else {
                    fatalError("has not been implemented")
                }
            case .failure(let e):
                throw e
            }
        }
    }
    
    func requestHistory<T>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T> where T : Codable {
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        return network.request(using: router, decodeTo: OptionalMessageDTO<T>.self)
            .trackProgressActivity(self.trackProgress)
            .map { (r) -> T? in
            switch r {
            case .success(let response):
                return response.data
            case .failure(let e):
                throw e
            }
        }.filterNil()
    }
    
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T> where T : Codable {
        return mutableStoreStream.store.filterNil().take(1).timeout(.seconds(20), scheduler: MainScheduler.asyncInstance)
            .flatMap { self.requestData(id: $0.id, router: router) }
    }
    
    func buyUniformsMainMoveBack() {
        self.listener?.buyUniformsMainMoveBack()
    }
}

// MARK: Class's private methods
private extension BUMainInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
        FireStoreConfigDataManager.shared.getConfigBuyUniform().bind(onNext: weakify({ (id, wSelf) in
            wSelf.categoryId = id
        })).disposeOnDeactivate(interactor: self)
    }
}
