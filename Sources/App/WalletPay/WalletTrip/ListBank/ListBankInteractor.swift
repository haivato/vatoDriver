//  File name   : ListBankInteractor.swift
//
//  Author      : MacbookPro
//  Created date: 5/22/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol ListBankRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol ListBankPresentable: Presentable {
    var listener: ListBankPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol ListBankListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class ListBankInteractor: PresentableInteractor<ListBankPresentable> {
    /// Class's public properties.
    weak var router: ListBankRouting?
    weak var listener: ListBankListener?
    private let listBank: [BankInfoServer]
    /// Class's constructor.
    init(presenter: ListBankPresentable, listBank: [BankInfoServer]) {
        self.listBank = listBank
        super.init(presenter: presenter)
        presenter.listener = self
    }
    @Replay(queue: MainScheduler.asyncInstance) private var mListBank: [BankInfoServer]
    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        self.mListBank = listBank
        
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
}

// MARK: ListBankInteractable's members
extension ListBankInteractor: ListBankInteractable {
}

// MARK: ListBankPresentableListener's members
extension ListBankInteractor: ListBankPresentableListener {
    var listBankObser: Observable<[BankInfoServer]> {
        self.$mListBank.asObservable()
    }
}

// MARK: Class's private methods
private extension ListBankInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
