//  File name   : LinkingCardInteractor.swift
//
//  Author      : admin
//  Created date: 5/22/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Alamofire

protocol LinkingCardRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    
    func showTopupNapas(type: TopUpNapasWebType)
}

protocol LinkingCardPresentable: Presentable {
    var listener: LinkingCardPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol LinkingCardListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    
    func moveBackFromLinkCard()
    func moveToBuyPointAddCardSuccess()
}

final class LinkingCardInteractor: PresentableInteractor<LinkingCardPresentable>, LinkingCardInteractable, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: LinkingCardRouting?
    weak var listener: LinkingCardListener?
    let authenticated: AuthenticatedStream?
    var listCardNapas: [PaymentCardType]
    /// Class's constructor.
    init(presenter: LinkingCardPresentable, authenticated: AuthenticatedStream, listCardNapas: [PaymentCardType]) {
        self.authenticated = authenticated
        self.listCardNapas = listCardNapas
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        self.mListNapas = listCardNapas
        setupRX()
        
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    @Replay(queue: MainScheduler.asyncInstance) private var mListNapas: [PaymentCardType]

    /// Class's private properties.
}

// MARK: LinkingCardInteractable's members
//extension LinkingCardInteractor: LinkingCardInteractable {
//}

struct DataKeyNapas: Codable {
    var apiOperation: String?
    var clientIp: String?
    var html: String?
}

extension LinkingCardInteractor: Weakifiable {
    func routeToAddCard(card: PaymentCardDetail) {
        guard var params = card.params, !params.isEmpty else {
            return
        }
        params["description"] = nil
        params["orderAmount"] = 5000
        params["orderCurrency"] = "VND"
        params["deviceId"] = "unknown"
        params["enable3DSecure"] = card.enable3d
        let router = VatoAPIRouter.customPath(authToken: "", path: "balance/napas/get_data_key", header: nil, params: params, useFullPath: false)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: router, decodeTo: OptionalMessageDTO<DataKeyNapas>.self, method: .post, encoding: JSONEncoding.default).trackProgressActivity(indicator).bind(onNext: weakify({ (result, wSelf) in
            switch result {
            case .success(let r):
                if let e = r.error {
                    wSelf.processNapasPaymentFailure(status: -1000, message: e.localizedDescription)
                } else {
                    guard let html = r.data?.html else {
                        return
                    }
                    wSelf.router?.showTopupNapas(type: .local(htmlString: html, redirectUrl: nil))
                }
            case .failure(let e):
                wSelf.processNapasPaymentFailure(status: -1000, message: e.localizedDescription)
            }
        })).disposeOnDeactivate(interactor: self)
    }
    
    private func fetchData() -> Observable<[PaymentCardDetail]> {
        let router = authenticated!.firebaseAuthToken.take(1).map { VatoAPIRouter.listCard(authToken: $0) }
        return router.flatMap {
            Requester.responseDTO(decodeTo: OptionalMessageDTO<[PaymentCardDetail]>.self, using: $0)
            }.map { r -> [PaymentCardDetail] in
                if let e = r.response.error {
                    throw e
                } else {
                    let list = r.response.data.orNil([])
                    return list
                }
            }.catchError { (e) -> Observable<[PaymentCardDetail]> in
            return Observable.error(e)
        }
        
    }
    
    func processNapasPaymentSuccess(showAlert: Bool) {
        fetchData().trackProgressActivity(indicator).subscribe(weakify({ (event, wSelf) in
            switch event {
            case .next(let list):
                self.listener?.moveToBuyPointAddCardSuccess()
            case .error(let e):
                guard showAlert else {
                    return
                }
                wSelf.processNapasPaymentFailure(status: -1000, message: e.localizedDescription)
            default:
                break
            }
        })).disposeOnDeactivate(interactor: self)
    }
    
    func processNapasPaymentFailure(status: Int, message: String) {
        //        presenter.showAlertError(message: message)
    }
}

// MARK: LinkingCardPresentableListener's members
extension LinkingCardInteractor: LinkingCardPresentableListener {
    func moveBack() {
        self.listener?.moveBackFromLinkCard()
    }
    var listCardObs: Observable<[PaymentCardType]> {
        return self.$mListNapas
    }
}

// MARK: Class's private methods
private extension LinkingCardInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
