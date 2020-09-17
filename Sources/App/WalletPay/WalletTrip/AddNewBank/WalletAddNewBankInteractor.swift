//  File name   : WalletAddNewBankInteractor.swift
//
//  Author      : MacbookPro
//  Created date: 5/20/20
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


protocol WalletAddNewBankRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func moveListBank(listBank: [BankInfoServer])
    func detactCurrentChild()
    func showAlertError(messageError: String)
}

protocol WalletAddNewBankPresentable: Presentable {
    var listener: WalletAddNewBankPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol WalletAddNewBankListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func moveBackWalletTrip()
    func moveWalletTripAddBankSuccess()
}

final class WalletAddNewBankInteractor: PresentableInteractor<WalletAddNewBankPresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: WalletAddNewBankRouting?
    weak var listener: WalletAddNewBankListener?
    private let user: UserBankInfo?

    /// Class's constructor.
    init(presenter: WalletAddNewBankPresentable, user: UserBankInfo?) {
        self.user = user
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        getListBank()
        getCusInfo()
        checkPin()
        guard let user = self.user, let bank = self.user?.bankInfo else {
            return
        }
        self.mUserBank = user
        self.mItemBank = bank
        self.bankID = bank.bankID
        self.isVerified = user.verified ?? false
        self.userID = user.userId
        // todo: Implement business logic here.
    }
    private lazy var network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
    private var mListBank: [BankInfoServer] = []
    private var listBankOb: PublishSubject<[BankInfoServer]> = PublishSubject.init()
    private var isVerified: Bool?
    private var userID: Int?
    @Replay(queue: MainScheduler.asyncInstance) private var mItemBank: BankInfoServer
    @Replay(queue: MainScheduler.asyncInstance) private var mDisplayName: String
    @Replay(queue: MainScheduler.asyncInstance) private var mIsCheckPin: Bool
    @Replay(queue: MainScheduler.asyncInstance) private var mUserBank: UserBankInfo
    private var isAddSuccessObs: PublishSubject<(Bool, String)> = PublishSubject.init()
    private var bankID: Int?
    internal var userAddBank: UserAddBank = UserAddBank(accountName: "", bankAccount: "", identityCard: "")
    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
}

// MARK: WalletAddNewBankInteractable's members
extension WalletAddNewBankInteractor: WalletAddNewBankInteractable {
    func selectBank(item: BankInfoServer) {
        self.router?.detactCurrentChild()
        self.mItemBank = item
        self.bankID = item.bankID
    }
    
    func moveBackAddBank() {
        self.router?.detactCurrentChild()
    }
    
}

// MARK: WalletAddNewBankPresentableListener's members
extension WalletAddNewBankInteractor: WalletAddNewBankPresentableListener {
    var userBank: Observable<UserBankInfo> {
        return self.$mUserBank
    }
    
    func moveWalletTrip() {
        self.listener?.moveBackWalletTrip()
    }
    
    var isAddSuccess: Observable<(Bool, String)> {
        return self.isAddSuccessObs.asObserver()
    }
    var eLoadingObser: Observable<(Bool,Double)> {
        return self.indicator.asObservable()
    }
    
    func userAddBank(pin: String) {
        if self.isVerified == false {
            self.updateBank(pin: pin)
        } else {
            self.addNewBank(pin: pin)
        }
        
    }
    func updateBank(pin: String) {
        guard let id = self.bankID, let user = self.user else {
            return
        }
        let p: [String:Any] = [
            "accountName": userAddBank.accountName,
            "bankAccount": userAddBank.bankAccount,
            "bankCode": "\(id)",
            "identityCard": userAddBank.identityCard,
            "pin": pin
        ]
        let url = TOManageCommunication.path("/api/user/\(user.userId)/bank-info/\(user.id)")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: p, useFullPath: true)
        network.request(using: router,
                        decodeTo: OptionalMessageDTO<UserBankInfo>.self,
                        method: .put,
                        encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                switch result {
                case .success(let d):
                    if d.fail == false {
                        self?.isAddSuccessObs.onNext((true, "Cập nhật tài khoản thành công"))
                    } else {
                        self?.isAddSuccessObs.onNext((false, d.message ?? ""))
                    }
                case .failure(let e):
                    print(e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
    func addNewBank(pin: String) {
        guard let id = self.bankID else {
            return
        }
        let p: [String:Any] = [
            "accountName": userAddBank.accountName,
            "bankAccount": userAddBank.bankAccount,
            "bankCode": id,
            "identityCard": userAddBank.identityCard,
            "pin": pin
        ]
        let url = TOManageCommunication.path("/api/user/add_bank_info")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: p, useFullPath: true)
        network.request(using: router,
                        decodeTo: OptionalMessageDTO<UserBankInfo>.self,
                        method: .post,
                        encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                switch result {
                case .success(let d):
                    if d.fail == false {
                        self?.isAddSuccessObs.onNext((true, "Tạo tài khoản thành công"))
                    } else {
                        self?.isAddSuccessObs.onNext((false, d.message ?? ""))
                    }
                case .failure(let e):
                    print(e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
    
    func showAlert(text: String) {
        self.router?.showAlertError(messageError: text)
    }
    
    var itemBankObser: Observable<BankInfoServer> {
        return self.$mItemBank.asObservable()
    }
    var displayNameObser: Observable<String> {
        return self.$mDisplayName.asObservable()
    }
    
    var listBankObser: Observable<[BankInfoServer]> {
        return self.listBankOb.asObserver()
    }
    var isPin: Observable<Bool> {
        return self.$mIsCheckPin.asObservable()
    }
    
    func moveBackWalletTrip() {
        self.listener?.moveBackWalletTrip()
    }

    func moveListBank() {
        print(self.mListBank)
        self.router?.moveListBank(listBank: self.mListBank)
    }
    func moveWalletTripAddBankSuccess() {
        self.listener?.moveWalletTripAddBankSuccess()
    }
    
}

// MARK: Class's private methods
private extension WalletAddNewBankInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
    private func getListBank() {
        if self.user == nil {
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
                        guard let itemFirst = d.first else {
                            return
                        }
                        self?.mItemBank = itemFirst
                        self?.bankID = itemFirst.bankID
                    case .failure(let e):
                        print(e.localizedDescription)
                    }
            }.disposeOnDeactivate(interactor: self)
        }
    }
    private func getCusInfo() {
        let d = UserManager.shared.getCurrentUser()?.user?.nickname
        let f = UserManager.shared.getCurrentUser()?.user?.fullName
        let displayName = d?.orEmpty(f ?? "")
        self.mDisplayName = displayName ?? ""
        
    }
    private func checkPin() {
        let url = TOManageCommunication.path("/api/user/check_pin")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true)
        network.request(using: router,
                                      decodeTo: OptionalMessageDTO<Bool>.self,
                                      method: .get,
                                      encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                switch result {
                case .success(let d):
                 guard let d = d.data else {
                     return
                 }
                 self?.mIsCheckPin = d
                case .failure(let e):
                    self?.router?.showAlertError(messageError: e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
}
