//  File name   : WalletReceiveBookingInteractor.swift
//
//  Author      : admin
//  Created date: 5/19/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Alamofire
import FirebaseFirestore
protocol WalletPointRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func gotoBuyPoint(_ list: [Any], balance: DriverBalance?, index: IndexPath)
    func gotoLinkCard(listCardNapas: [PaymentCardType])
    func moveToListHistoryCredit()
}

protocol WalletPointPresentable: Presentable {
    var listener: WalletPointPresentableListener? { get set }
    
    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol WalletPointListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    
    func moveBack()
}

final class WalletPointInteractor: PresentableInteractor<WalletPointPresentable> {
    /// Class's public properties.
    weak var router: WalletPointRouting?
    weak var listener: WalletPointListener?
    
    /// Class's constructor.
    override init(presenter: WalletPointPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        getListTopUp()
        // todo: Implement business logic here.
        getListTopUpExtra()
        getBalance()
        requestVisaATM()
    }
    
    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    /// Class's private properties.
    private lazy var network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
    private var listTopUpObs: PublishSubject<[TopUpMethod]> = PublishSubject.init()
    private var listCardObs: PublishSubject<[Card]> = PublishSubject.init()
    @Replay(queue: MainScheduler.asyncInstance) private var mDriverBalance: DriverBalance
    private var mListNapas: PublishSubject<[PaymentCardType]> = PublishSubject.init()
    private var listNapas: [PaymentCardType] = []
}

// MARK: WalletPointInteractable's members
extension WalletPointInteractor: WalletPointInteractable {
    func moveToBuyPointAddCardSuccess() {
        self.router?.dismissCurrentRoute(completion: nil)
        self.getListTopUpExtra()
    }
    
    func moveBackSourceWallet() {
        self.router?.dismissCurrentRoute(completion: {
            self.getBalance()
        })
    }
    
    func listDetailMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func showDetail(by item: WalletItemDisplayProtocol) {
        
    }
        
    func moveBackFromLinkCard() {
        self.router?.dismissCurrentRoute(completion: nil)
        self.getListTopUpExtra()
    }
    
    func moveBackFromBuyPoint() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
}

// MARK: WalletPointPresentableListener's members
extension WalletPointInteractor: WalletPointPresentableListener, ActivityTrackingProgressProtocol {
    var listNapasObs: Observable<[PaymentCardType]> {
        return self.mListNapas.asObserver()
    }
    
    func moveBack() {
        listener?.moveBack()
    }
    
    func moveToListHistoryCredit() {
        self.router?.moveToListHistoryCredit()
    }
    
    var listTopUpMethodObser: Observable<[TopUpMethod]> {
        return self.listTopUpObs.asObserver()
    }
    
    var listCardObser: Observable<[Card]> {
        return self.listCardObs.asObserver()
    }
    
    func gotoBuyPoint(_ list: [Any], balance: DriverBalance?, index: IndexPath) {
        router?.gotoBuyPoint(list, balance: balance, index: index)
    }
    
    func gotoLinkCard() {
        router?.gotoLinkCard(listCardNapas: listNapas)
    }
    
    var balanceObser: Observable<DriverBalance> {
        return self.$mDriverBalance
    }
    
    var eLoadingObser: Observable<(Bool,Double)> {
        return self.indicator.asObservable()
    }
}

// MARK: Class's private methods
private extension WalletPointInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
    
    private func getListTopUp() {
        let url = TOManageCommunication.path("/api/user/get_user_topup_info")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true)
        network.request(using: router,
                        decodeTo: OptionalMessageDTO<[TopUpMethod]>.self,
                        method: .get,
                        encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                guard let wSelf = self else { return }
                switch result {
                case .success(let d):
                    if let r = d.data {
                        wSelf.listTopUpObs.onNext(r)
                    }
                case .failure(let e):
                    print(e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func getListTopUpExtra() {
        let url = TOManageCommunication.path("/api/balance/napas/list_token")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true)
        network.request(using: router,
                        decodeTo: OptionalMessageDTO<[Card]>.self,
                        method: .get,
                        encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                guard let wSelf = self else { return }
                switch result {
                case .success(let d):
                    if let r = d.data {
                        wSelf.listCardObs.onNext(r)
                    }
                case .failure(let e):
                    print(e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
    private func getBalance() {
        let url = TOManageCommunication.path("/api/balance/get")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true)
        network.request(using: router,
                        decodeTo: OptionalMessageDTO<DriverBalance>.self,
                        method: .get,
                        encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                guard let wSelf = self else { return }
                switch result {
                case .success(let d):
                    guard let data = d.data else {
                        return
                    }
                    wSelf.mDriverBalance = data
                case .failure(let e):
                    print(e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
    func requestVisaATM() {
        let documentRef = Firestore.firestore().documentRef(collection: .configData, storePath: .custom(path: "Driver") , action: .read)
        
        documentRef
            .find(action: .get, json: nil, source: .server)
            .trackProgressActivity(self.indicator)
            .filterNil()
            .map { try? $0.decode(to: ConfigVisaATM.self) }
            .bind { (data) in
                guard let data = data else { return }
                var activeNapas = [PaymentCardType]()
                if (data.allowAddCardAtm) {
                    activeNapas.append(PaymentCardType.atm)
                }
                if (data.allowAddCardVisaMaster) {
                    activeNapas.append(PaymentCardType.visa)
                }
                self.mListNapas.onNext(activeNapas)
                self.listNapas = activeNapas
        }.disposeOnDeactivate(interactor: self)
        
    }
}

struct TopUpMethod: Codable, Equatable {
    static func == (lhs: TopUpMethod, rhs: TopUpMethod) -> Bool {
        return lhs.type == rhs.type
   }

    let type: Int
    let name: String?
    let url: String?
    let auth: Bool
    let active: Bool
    let iconURL: String?
    let min: Int
    let max: Int
    let options: [Double]?
    
    var topUpType: TopupType? {
        return TopupType(rawValue: self.type)
    }
}
