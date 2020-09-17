//  File name   : WTWithDrawInteractor.swift
//
//  Author      : admin
//  Created date: 6/3/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol WTWithDrawRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func moveToWithDrawCF(item: UserBankInfo, balance: DriverBalance)
}

protocol WTWithDrawPresentable: Presentable {
    var listener: WTWithDrawPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol WTWithDrawListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func moveBackFromWithDraw()
    func moveBackSourceWallet()
}

final class WTWithDrawInteractor: PresentableInteractor<WTWithDrawPresentable> {
    /// Class's public properties.
    weak var router: WTWithDrawRouting?
    weak var listener: WTWithDrawListener?

    /// Class's constructor.
//    override init(presenter: WTWithDrawPresentable) {
//        super.init(presenter: presenter)
//        presenter.listener = self
//    }

    init(presenter: WTWithDrawPresentable, listUserBank: [UserBankInfo]?, balance: DriverBalance?) {
        self.listUserBank = listUserBank
        self.balance = balance
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        
        // todo: Implement business logic here.
        if let listUserBank = self.listUserBank {
            self.mListUserBank = listUserBank
        }
        if let balance = self.balance {
            self.mBalance = balance
        }
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
    private var listUserBank: [UserBankInfo]?
    private var balance: DriverBalance?
    @Replay(queue: MainScheduler.asyncInstance) private var mListUserBank: [UserBankInfo]
    @Replay(queue: MainScheduler.asyncInstance) private var mBalance: DriverBalance

}

// MARK: WTWithDrawInteractable's members
extension WTWithDrawInteractor: WTWithDrawInteractable {
    func moveBackFromWithDrawConfirm() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
        
    func moveBackSourceWallet() {
        self.listener?.moveBackSourceWallet()
    }
}

// MARK: WTWithDrawPresentableListener's members
extension WTWithDrawInteractor: WTWithDrawPresentableListener {
    func moveToWithDrawCF(item: UserBankInfo) {
        guard let balance = self.balance else {
            return
        }
        self.router?.moveToWithDrawCF(item: item, balance: balance)
    }
    
    var listUserBankObs: Observable<[UserBankInfo]>  {
        return self.$mListUserBank
    }
    
    var balanceObs: Observable<DriverBalance> {
        return self.$mBalance
    }
    
    func moveBack() {
        listener?.moveBackFromWithDraw()
    }

}

// MARK: Class's private methods
private extension WTWithDrawInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
