//  File name   : WalletTripInteractor.swift
//
//  Author      : MacbookPro
//  Created date: 5/19/20
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

protocol WalletTripRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func moveAddBank(user: UserBankInfo?)
//    func moveToBuyPoint(listUserBank: [UserBankInfo],balance: DriverBalance)
    func moveToHistoryWallet()
    func moveToWithDraw(listUserBank: [UserBankInfo],balance: DriverBalance)
}

protocol WalletTripPresentable: Presentable {
    var listener: WalletTripPresentableListener? { get set }
    
    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol WalletTripListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func walletTripMoveBack()
}

final class WalletTripInteractor: PresentableInteractor<WalletTripPresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: WalletTripRouting?
    weak var listener: WalletTripListener?
    private var balance: FCBalance
    
    /// Class's constructor.
    init(presenter: WalletTripPresentable, balance: FCBalance) {
        self.balance = balance
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        getListBank()
        getBalance()
        
        // todo: Implement business logic here.
    }
    private lazy var network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
    private var listBankUser: [UserBankInfo] = []
    private var listBankUserObs: PublishSubject<[UserBankInfo]> = PublishSubject.init()
    private var mListBank: [BankInfoServer] = []
    @Replay(queue: MainScheduler.asyncInstance) private var mDriverBalance: DriverBalance
    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    /// Class's private properties.
}

// MARK: WalletTripInteractable's members
extension WalletTripInteractor: WalletTripInteractable {
    func moveBackFromWithDraw() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func moveBackSourceWallet() {
        self.router?.dismissCurrentRoute(completion: {
            self.getBalance()
        })
    }
    
    func moveBackWhenWithDrawSuccess() {
        self.router?.dismissCurrentRoute(completion: nil)
        getBalance()
    }
    
    func listDetailMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func showDetail(by item: WalletItemDisplayProtocol) {
        
    }
        
    func moveWalletTripAddBankSuccess() {
        self.router?.dismissCurrentRoute(completion: nil)
        self.getListBank()
    }
    
    func moveBackFromWithDrawConfirm() {
        self.router?.dismissCurrentRoute(completion: nil)
        getBalance()
    }
    
    func moveBackWalletTrip() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func moveBackFromBuyPoint() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
}

// MARK: WalletTripPresentableListener's members
extension WalletTripInteractor: WalletTripPresentableListener {
    func moveToWithDraw(driverbalance: DriverBalance) {
        self.router?.moveToWithDraw(listUserBank: self.listBankUser, balance: driverbalance)
    }
    
    var balanceObser: Observable<DriverBalance> {
        return self.$mDriverBalance
    }
    
    func selectUserBank(user: UserBankInfo) {
        self.router?.moveAddBank(user: user)
    }
    
    var listBankUserObser: Observable<[UserBankInfo]> {
        return self.listBankUserObs.asObserver()
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return self.indicator.asObservable()
    }
    
    func walletTripMoveBack() {
        self.listener?.walletTripMoveBack()
    }
    
    func moveAddBank() {
        self.router?.moveAddBank(user: nil)
    }

    func moveToHistoryWallet() {
        self.router?.moveToHistoryWallet()
    }
    
}

// MARK: Class's private methods
private extension WalletTripInteractor {
    private func setupRX() {
        
    }
    private func fetchListBankUser() {
        let url = TOManageCommunication.path("/api/user/get_user_bank_info")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true)
        network.request(using: router,
                        decodeTo: OptionalMessageDTO<[UserBankInfo]>.self,
                        method: .get,
                        encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                guard let wSelf = self else { return }
                switch result {
                case .success(let d):
                    if d.fail == false {
                        wSelf.listBankUser = d.data ?? []
                        wSelf.listBankUser.enumerated().filter { (index, item) in
                            wSelf.mListBank.filter { (bank) in
                                if item.bankCode == bank.bankID {
                                    wSelf.listBankUser[index].bankInfo = bank
                                }
                                return true
                            }
                            return true
                        }
                        wSelf.listBankUserObs.onNext(wSelf.listBankUser )
                    } else {
                        print(d.message ?? "")
                    }
                case .failure(let e):
                    print(e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
    private func getListBank() {
        let url = TOManageCommunication.path("/m/bank_withdraw_support")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true)
        network.request(using: router,
                        decodeTo: [BankInfoServer].self,
                        method: .get,
                        encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                switch result {
                case .success(let d):
                    self?.mListBank = d
                    self?.fetchListBankUser()
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
    
    
}
