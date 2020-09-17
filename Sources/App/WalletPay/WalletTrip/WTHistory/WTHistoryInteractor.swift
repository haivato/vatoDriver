//  File name   : WTHistoryInteractor.swift
//
//  Author      : MacbookPro
//  Created date: 5/24/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol WTHistoryRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol WTHistoryPresentable: Presentable {
    var listener: WTHistoryPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol WTHistoryListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func moveBackWalletTrip()
}

final class WTHistoryInteractor: PresentableInteractor<WTHistoryPresentable> {
    /// Class's public properties.
    weak var router: WTHistoryRouting?
    weak var listener: WTHistoryListener?

    /// Class's constructor.
    override init(presenter: WTHistoryPresentable) {
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

// MARK: WTHistoryInteractable's members
extension WTHistoryInteractor: WTHistoryInteractable {
}

// MARK: WTHistoryPresentableListener's members
extension WTHistoryInteractor: WTHistoryPresentableListener {
    func moveBackWalletTrip() {
        self.listener?.moveBackWalletTrip()
    }
}

// MARK: Class's private methods
private extension WTHistoryInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
