//  File name   : WTWithDrawConfirmRouter.swift
//
//  Author      : MacbookPro
//  Created date: 5/24/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import RxCocoa

protocol WTWithDrawConfirmInteractable: Interactable, WTWithDrawSuccessListener {
    var router: WTWithDrawConfirmRouting? { get set }
    var listener: WTWithDrawConfirmListener? { get set }
    func processNapasPaymentSuccess()
    func processNapasPaymentFailure(status: Int, message: String)
}

protocol WTWithDrawConfirmViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class WTWithDrawConfirmRouter: ViewableRouter<WTWithDrawConfirmInteractable, WTWithDrawConfirmViewControllable> {
    /// Class's constructor.

    init(interactor: WTWithDrawConfirmInteractable, viewController: WTWithDrawConfirmViewControllable, wtWithDrawSuccessBuildable: WTWithDrawSuccessBuildable) {
        self.wtWithDrawSuccessBuildable = wtWithDrawSuccessBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let wtWithDrawSuccessBuildable: WTWithDrawSuccessBuildable
    private lazy var disposeBag = DisposeBag()
}
// MARK: WTWithDrawConfirmRouting's members
extension WTWithDrawConfirmRouter: WTWithDrawConfirmRouting {
    func showAlertError(messageError: String) {
        AlertVC.showMessageAlert(for: self.viewController.uiviewController, title: "Thông báo ", message: messageError, actionButton1: "Đóng", actionButton2: nil)
    }
    
    func goToSuccess(_ info: (TopupCellModel?, Int?)) {
        let route = wtWithDrawSuccessBuildable.build(withListener: interactor, info: info)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: false )
        perform(with: segue, completion: nil)
    }
    
    func goToWDSuccess(_ info: BankTransactionInfo) {
        let route = wtWithDrawSuccessBuildable.build(withListener: interactor, bankInfo: info)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: false )
        perform(with: segue, completion: nil)
    }
    
    func showTopupNapas(htmlString: String, redirectUrl: String?) {
        TopUpNapasWebVC.loadWeb(on: self.viewController.uiviewController, title: "Thanh toán", type: .local(htmlString: htmlString, redirectUrl: redirectUrl))
            .observeOn(MainScheduler.asyncInstance).subscribe {[weak self] e in
                guard let wSelf = self else { return }
                switch e {
                case .next(let result):
                    guard result != nil else {
                        return
                    }
                    wSelf.interactor.processNapasPaymentSuccess()
                case .error(let r):
                    wSelf.interactor.processNapasPaymentFailure(status: -10001, message: r.localizedDescription)
                default:
                    break
                }
                
        }.disposed(by: disposeBag)
    }

}

// MARK: Class's private methods
private extension WTWithDrawConfirmRouter {
}
