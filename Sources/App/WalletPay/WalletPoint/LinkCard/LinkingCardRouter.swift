//  File name   : LinkingCardRouter.swift
//
//  Author      : admin
//  Created date: 5/22/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol LinkingCardInteractable: Interactable {
    var router: LinkingCardRouting? { get set }
    var listener: LinkingCardListener? { get set }
    
    func processNapasPaymentSuccess(showAlert: Bool)
    func processNapasPaymentFailure(status: Int, message: String)
}

protocol LinkingCardViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class LinkingCardRouter: ViewableRouter<LinkingCardInteractable, LinkingCardViewControllable> {
    /// Class's constructor.
    override init(interactor: LinkingCardInteractable, viewController: LinkingCardViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private lazy var disposeBag = DisposeBag()
        
    func showTopupNapas(type: TopUpNapasWebType) {
        TopUpNapasWebVC.loadWeb(on: self.viewController.uiviewController, title: "Xác nhận thanh toán", type: type)
            .observeOn(MainScheduler.asyncInstance).subscribe {[weak self] e in
                guard let wSelf = self else { return }
                switch e {
                case .next(let value):
                    if value {
                        wSelf.interactor.processNapasPaymentSuccess(showAlert: true)
                    }
                case .error(let r):
                    wSelf.interactor.processNapasPaymentFailure(status: -10001, message: r.localizedDescription)
                case .completed:
                    printDebug("Completed")
                }
                
        }.disposed(by: disposeBag)
    }
}

// MARK: LinkingCardRouting's members
extension LinkingCardRouter: LinkingCardRouting {
    
}

// MARK: Class's private methods
private extension LinkingCardRouter {
}
