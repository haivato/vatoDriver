//  File name   : WalletTripListBankInteractor.swift
//
//  Author      : MacbookPro
//  Created date: 5/22/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol WalletTripListBankRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol WalletTripListBankPresentable: Presentable {
    var listener: WalletTripListBankPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol WalletTripListBankListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func moveBackAddBank()
    func selectBank(item: BankInfoServer)
}

final class WalletTripListBankInteractor: PresentableInteractor<WalletTripListBankPresentable> {
    /// Class's public properties.
    weak var router: WalletTripListBankRouting?
    weak var listener: WalletTripListBankListener?
    private let listBank: [BankInfoServer]
    /// Class's constructor.
    init(presenter: WalletTripListBankPresentable, listBank: [BankInfoServer]) {
        self.listBank = listBank
        super.init(presenter: presenter)
        presenter.listener = self
    }
    @Replay(queue: MainScheduler.asyncInstance) private var mListBank: [BankInfoServer]

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        self.mListBank = self.listBank
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
}

// MARK: WalletTripListBankInteractable's members
extension WalletTripListBankInteractor: WalletTripListBankInteractable {
}

// MARK: WalletTripListBankPresentableListener's members
extension WalletTripListBankInteractor: WalletTripListBankPresentableListener {
    func selectBank(itemBank: BankInfoServer) {
        self.listener?.selectBank(item: itemBank)
    }
    
    func moveBackAddBank() {
        self.listener?.moveBackAddBank()
    }
    
    var listBankObser: Observable<[BankInfoServer]> {
           self.$mListBank.asObservable()
       }
}

// MARK: Class's private methods
private extension WalletTripListBankInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
