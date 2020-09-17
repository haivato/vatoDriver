//  File name   : BUBookingDetailInteractor.swift
//
//  Author      : vato.
//  Created date: 3/12/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Alamofire

protocol BUBookingDetailRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToSwitchPayment(card: PaymentCardDetail)
}

protocol BUBookingDetailPresentable: Presentable {
    var listener: BUBookingDetailPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
    func showError(error: NSError)
}

protocol BUBookingDetailListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func bookingDetailMoveBack()
    func buySuccess()
    func buyUniformsDetailMoveBackRoot()
}

final class BUBookingDetailInteractor: PresentableInteractor<BUBookingDetailPresentable>, ActivityTrackingProgressProtocol {
    struct Configs {
        static let genError: (String?) -> NSError = { messge in
            return NSError(domain: NSURLErrorDomain,
                           code: NSURLErrorUnknown,
                           userInfo: [NSLocalizedDescriptionKey: messge ?? "Chức năng tạm thời gián đoạn. Vui lòng thử lại sau."])
        }
    }
    
    /// Class's public properties.
    weak var router: BUBookingDetailRouting?
    weak var listener: BUBookingDetailListener?
    
    /// Class's constructor.
    init(presenter: BUBookingDetailPresentable,
         mutableStoreStream: MutableStoreStream) {
        self.mutableStoreStream = mutableStoreStream
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    /// Class's private properties.
    private let mutableStoreStream: MutableStoreStream
}

// MARK: BUBookingDetailInteractable's members
extension BUBookingDetailInteractor: BUBookingDetailInteractable, Weakifiable {
    func switchPaymentMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func switchPaymentChoose(by card: PaymentCardDetail) {
        router?.dismissCurrentRoute(completion: weakify({ (wSelf) in
            wSelf.mutableStoreStream.update(paymentCard: card)
        }))
    }
    
    func routeToSwitchPayment() {
        currentSelect.take(1).bind(onNext: weakify({ (p, wSelf) in
            wSelf.router?.routeToSwitchPayment(card: p)
        })).disposeOnDeactivate(interactor: self)
    }
}

// MARK: BUBookingDetailPresentableListener's members
extension BUBookingDetailInteractor: BUBookingDetailPresentableListener {
    
    func buyUniformsDetailMoveBackRoot() {
        listener?.buyUniformsDetailMoveBackRoot()
    }
    
    func didSelectCheckout() {
        self.mutableStoreStream.createParams().observeOn(MainScheduler.asyncInstance).bind {[weak self] (params) in
            guard let wSelf = self, let p = params else { return }
            wSelf.requestCreateQuoteCart(params: p.params, method: p.method)
        }.disposeOnDeactivate(interactor: self)
    }
    
    var currentSelect: Observable<PaymentCardDetail> {
        return mutableStoreStream.paymentMethod
    }
    
    var mBasket: Observable<BasketModel> {
        mutableStoreStream.basket
    }
    
    var store: Observable<FoodExploreItem?> {
        mutableStoreStream.store
    }
    
    func bookingDetailMoveBack() {
        self.listener?.bookingDetailMoveBack()
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return indicator.asObservable().observeOn(MainScheduler.asyncInstance)
    }
}

// MARK: Class's private methods
private extension BUBookingDetailInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
    
    func requestCreateQuoteCart(params: JSON, method: HTTPMethod) {
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: VatoFoodApi.createQuoteCartOffline(authToken: "", params: params), decodeTo: OptionalMessageDTO<QuoteCart>.self, method: method, encoding: JSONEncoding.default)
            .trackProgressActivity(indicator)
            .subscribe({ [weak self] (event) in
                guard let wSelf = self else  { return }
                switch event {
                case .next(let res):
                    switch res {
                    case .success(let r):
                        if let data = r.data {
                            wSelf.requestCreateOrder(quoteId: data.id ?? "")
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
    
    func requestCreateOrder(quoteId: String) {
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: VatoFoodApi.createSaleOrderOffline(authToken: "", quoteId: quoteId, params: ["quoteId": quoteId]), decodeTo: OptionalMessageDTO<SalesOrder>.self, method: .post, encoding: JSONEncoding.default)
            .trackProgressActivity(indicator)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe({ [weak self] (event) in
                guard let wSelf = self else  { return }
                switch event {
                case .next(let res):
                    switch res {
                    case .success(let r):
                        if r.data != nil {
                            wSelf.listener?.buySuccess()
                        } else {
                            let error = Configs.genError(r.message)
                            wSelf.presenter.showError(error: error)
                        }
                    case .failure(let err):
                        print(err.localizedDescription)
                        let e = Configs.genError(nil)
                        wSelf.presenter.showError(error: e)
                    }
                default:
                    break
                }
            }).disposeOnDeactivate(interactor: self)
    }
}
