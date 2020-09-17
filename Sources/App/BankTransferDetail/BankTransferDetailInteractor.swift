//  File name   : BankTransferDetailInteractor.swift
//
//  Author      : Futa Corp
//  Created date: 2/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import FirebaseAuth

protocol BankTransferDetailRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol BankTransferDetailPresentable: Presentable {
    var listener: BankTransferDetailPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol BankTransferDetailListener: class {
    func requestToDismissBankTransferDetailModule()
}

final class BankTransferDetailInteractor: PresentableInteractor<BankTransferDetailPresentable> {
    /// Class's public properties.
    weak var router: BankTransferDetailRouting?
    weak var listener: BankTransferDetailListener?

    /// Class's constructor.
    override init(presenter: BankTransferDetailPresentable) {
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
}

// MARK: BankTransferDetailInteractable's members
extension BankTransferDetailInteractor: BankTransferDetailInteractable {
}

// MARK: BankTransferDetailPresentableListener's members
extension BankTransferDetailInteractor: BankTransferDetailPresentableListener {
    var phoneNumber: Observable<String> {
        return retrieveCurrentUser().map { $0.phoneNumber }.filterNil()
    }

    func handleBackItemAction() {
        listener?.requestToDismissBankTransferDetailModule()
    }
}

// MARK: Class's private methods
private extension BankTransferDetailInteractor {
    private func setupRX() {
    }

    func retrieveCurrentUser() -> Observable<Firebase.User> {
        return Observable<Firebase.User>.create({ s -> Disposable in
            let handler = Auth.auth().addStateDidChangeListener { (auth, user) in
                guard let user = user else {
                    return
                }
                
                s.onNext(user)
                s.onCompleted()
            }

            return Disposables.create {
                Auth.auth().removeStateDidChangeListener(handler)
            }
        })
    }
}
