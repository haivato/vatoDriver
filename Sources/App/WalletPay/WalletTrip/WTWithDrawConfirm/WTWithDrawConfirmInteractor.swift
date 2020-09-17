//  File name   : WTWithDrawConfirmInteractor.swift
//
//  Author      : MacbookPro
//  Created date: 5/24/20
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

protocol WTWithDrawConfirmRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func showAlertError(messageError: String)
    
    func goToSuccess(_ info: (TopupCellModel?, Int?))
    func goToWDSuccess(_ info: BankTransactionInfo)
    func showTopupNapas(htmlString: String, redirectUrl: String?)
}

protocol WTWithDrawConfirmPresentable: Presentable {
    var listener: WTWithDrawConfirmPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol WTWithDrawConfirmListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func moveBackFromWithDrawConfirm()
    func moveBackSourceWallet()
}

struct TopUpAtmResponse: Codable {
    var apiOperation: String?
    var clientIp: String?
    var dataKey: String?
    var merchantId: String?
    var napasKey: String?
    var orderDetail: String?
    var orderId: String?
    var orderToken: String?
    var redirectUrl: String?
    var result: String?
    var transactionId: String?
    var html: String?
}

final class WTWithDrawConfirmInteractor: PresentableInteractor<WTWithDrawConfirmPresentable>, ActivityTrackingProgressProtocol {
    
    /// Class's public properties.
    weak var router: WTWithDrawConfirmRouting?
    weak var listener: WTWithDrawConfirmListener?

    /// Class's constructor.
    init(presenter: WTWithDrawConfirmPresentable, item: UserBankInfo, balance: DriverBalance) {
        self.item = item
        self.balance = balance
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    init(presenter: WTWithDrawConfirmPresentable, topUpItem: TopupCellModel, point: Int, balance: DriverBalance) {
        self.topUpItem = topUpItem
        self.point = point
        self.balance = balance
        self.currentItem = topUpItem
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        self.checkPin()
        
        mBalance = self.balance
        
        self.mTopUp = self.topUpItem
        self.mPoint = self.point
        
        if let item = self.item {
            mUserBank = item
        }
        
        if let currentItem = self.currentItem {
            self.mCurrentItem = currentItem
        }
        //
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
    private var currentItem: TopupCellModel?
    private lazy var network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
    @Replay(queue: MainScheduler.asyncInstance) private var mIsCheckPin: Bool
    private var isSubmitSuccessObs: PublishSubject<(Bool, String)> = PublishSubject.init()
    @Replay(queue: MainScheduler.asyncInstance) private var mTopUp: TopupCellModel?
    @Replay(queue: MainScheduler.asyncInstance) private var mPoint: Int?
    @Replay(queue: MainScheduler.asyncInstance) private var mUserBank: UserBankInfo?
    @Replay(queue: MainScheduler.asyncInstance) private var mBalance: DriverBalance
    @Replay(queue: MainScheduler.asyncInstance) private var mCurrentItem: TopupCellModel
    
    private var topUpItem: TopupCellModel?
    private var point: Int?

    private var item: UserBankInfo?
    private var balance: DriverBalance
}

// MARK: WTWithDrawConfirmInteractable's members
extension WTWithDrawConfirmInteractor: WTWithDrawConfirmInteractable {
    func moveBackSourceWallet() {
        self.listener?.moveBackSourceWallet()
    }
}

// MARK: WTWithDrawConfirmPresentableListener's members
extension WTWithDrawConfirmInteractor: WTWithDrawConfirmPresentableListener, Weakifiable {
    var itemTopUpCellModel: Observable<TopupCellModel> {
        return self.$mCurrentItem
    }
    var eLoadingObser: Observable<(Bool, Double)> {
        return self.indicator.asObservable()
    }
    
    var isPin: Observable<Bool> {
        return self.$mIsCheckPin
    }
    
    var balanceObs: Observable<DriverBalance> {
        return self.$mBalance
    }
    
    func moveBack() {
        self.listener?.moveBackFromWithDrawConfirm()
    }
    
    func showAlert(text: String) {
        self.router?.showAlertError(messageError: text)
    }
    
    var isSubmitSuccess: Observable<(Bool, String)> {
        return self.isSubmitSuccessObs.asObserver()
    }
    
    var userBank: Observable<UserBankInfo?> {
        return self.$mUserBank
    }
        
    func submitWithDraw(pin: String) {
        //bankID
        guard let amount = item?.amountNeedWithDraw else { return }
        let p: [String : Any] = [
            "bankInfoId": item?.id ?? -1,
            "amount": amount,
            "pin": pin]
        let url = TOManageCommunication.path("/api/balance/add_withdraw")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: p, useFullPath: true)
        network.request(using: router,
                        decodeTo: OptionalMessageDTO<WithDrawSuccess>.self,
                        method: .post,
                        encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                switch result {
                case .success(let d):
                    if d.fail == false {
                        self?.isSubmitSuccessObs.onNext((true, "Tạo tài khoản thành công"))
                    } else {
                        self?.router?.showAlertError(messageError: d.message ?? "")
                    }
                case .failure(let e):
                    self?.router?.showAlertError(messageError: e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
    
    func processNapasPaymentSuccess() {
        self.isSubmitSuccessObs.onNext((true, ""))
    }
    
    func processNapasPaymentFailure(status: Int, message: String) {
        self.router?.showAlertError(messageError: message)
    }
    
    private func payWithNapas(_ amount: Int) {
        let uuid = UIDevice.current.identifierForVendor?.uuidString ?? "ios_client_app"
        var params: JSON = ["deviceId": "phone",
                            "environment": "MobileApp",
                            "description": "Driver mua điểm"]
        
        params["orderAmount"] = amount
        params["cardScheme"] = self.currentItem?.card?.cardScheme
        params["userId"] = UserManager.shared.getUserId()
        params["tokenId"] = self.currentItem?.card?.id
        params["deviceId"] = uuid
        params["orderCurrency"] = "VND"
        
        let p: String
        if let card = self.currentItem?.card, card.type == .atm  {
            p = TOManageCommunication.path("/api/balance/napas/purchase_domestic_token")
        } else {
            p = TOManageCommunication.path("/api/balance/napas/purchase_international_token")
        }
        
        let router = VatoAPIRouter.customPath(authToken: "",
                                              path: p,
                                              header: nil,
                                              params: params,
                                              useFullPath: true)
        network.request(using: router,
                        decodeTo: OptionalIgnoreMessageDTO<TopUpAtmResponse>.self,
                        method: .post,
                        encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind(onNext: weakify({ (result, wSelf) in
                switch result {
                case .success(let res):
                    guard let i = res.data, let html = i.html else {
                        if res.fail == false {
                            wSelf.isSubmitSuccessObs.onNext((true, ""))
                        } else {
                            wSelf.router?.showAlertError(messageError: res.message ?? "")
                        }
                        return
                    }
                    wSelf.router?.showTopupNapas(htmlString: html, redirectUrl: nil)
                case .failure(let e):
                    wSelf.router?.showAlertError(messageError: e.localizedDescription)
                }
        })).disposeOnDeactivate(interactor: self)
    }

    func goToTransferPoint(pin: String, amount: Int) {
        if let card = self.currentItem?.card, card.type == .visa || card.type == .master || card.type == .atm  {
            return payWithNapas(amount)
        }
        
        let p: [String : Any] = [
            "amount": amount,
            "pin": pin]
        let url = TOManageCommunication.path("/api/user/transfer")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: p, useFullPath: true)
        network.request(using: router,
                        decodeTo: OptionalMessageDTO<[WalletTransactionItem]>.self,
                        method: .post,
                        encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                switch result {
                case .success(let d):
                    if d.fail == false {
                        self?.isSubmitSuccessObs.onNext((true, ""))
                    } else {
                        self?.router?.showAlertError(messageError: d.message ?? "")
                    }
                case .failure(let e):
                    self?.router?.showAlertError(messageError: e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
        
    var topUpObser: Observable<TopupCellModel?> {
        return self.$mTopUp
    }
    
    var pointObser: Observable<Int?> {
        return self.$mPoint
    }
    
    var napasLoadingObser: Observable<(Bool, Double)> {
        return NapasHandler.indicator.asObservable()
    }
        
    func goToSuccess() {
        router?.goToSuccess((self.topUpItem, self.point))
    }
    
    func goToWDSuccess() {
        router?.goToWDSuccess((user: self.item, balance: self.balance))
    }
}

// MARK: Class's private methods
private extension WTWithDrawConfirmInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
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
                    print(e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
}
