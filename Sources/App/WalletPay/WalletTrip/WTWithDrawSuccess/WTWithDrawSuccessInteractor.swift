//  File name   : WTWithDrawSuccessInteractor.swift
//
//  Author      : admin
//  Created date: 5/30/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol WTWithDrawSuccessRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol WTWithDrawSuccessPresentable: Presentable {
    var listener: WTWithDrawSuccessPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol WTWithDrawSuccessListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    
    func moveBackSourceWallet()
}

final class WTWithDrawSuccessInteractor: PresentableInteractor<WTWithDrawSuccessPresentable> {
    /// Class's public properties.
    weak var router: WTWithDrawSuccessRouting?
    weak var listener: WTWithDrawSuccessListener?

    /// Class's constructor.
    init(presenter: WTWithDrawSuccessPresentable, topUpInfo: PointTransactionInfo) {
        self.topUpInfo = topUpInfo
        self.bankInfo = (nil, nil)
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    init(presenter: WTWithDrawSuccessPresentable, bankInfo: BankTransactionInfo) {
        self.bankInfo = bankInfo
        self.topUpInfo = (nil, nil)
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        
        // todo: Implement business logic here.
        self.mTopUpInfo = self.topUpInfo
        self.mBankInfo = self.bankInfo
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
    private var topUpInfo: PointTransactionInfo
    @Replay(queue: MainScheduler.asyncInstance) private var mTopUpInfo: PointTransactionInfo

    private var bankInfo: BankTransactionInfo
    @Replay(queue: MainScheduler.asyncInstance) private var mBankInfo: BankTransactionInfo

}

// MARK: WTWithDrawSuccessInteractable's members
extension WTWithDrawSuccessInteractor: WTWithDrawSuccessInteractable {
    var topUpInfoObser: Observable<PointTransactionInfo> {
        return self.$mTopUpInfo
    }

    var bankInfoObser: Observable<BankTransactionInfo> {
        return self.$mBankInfo
    }
}

// MARK: WTWithDrawSuccessPresentableListener's members
extension WTWithDrawSuccessInteractor: WTWithDrawSuccessPresentableListener {
    func moveBackSourceWallet() {
        self.listener?.moveBackSourceWallet()
    }
}

// MARK: Class's private methods
private extension WTWithDrawSuccessInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
