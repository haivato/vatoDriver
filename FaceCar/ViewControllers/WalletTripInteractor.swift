//  File name   : WalletTripInteractor.swift
//
//  Author      : MacbookPro
//  Created date: 5/19/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol WalletTripRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol WalletTripPresentable: Presentable {
    var listener: WalletTripPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol WalletTripListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class WalletTripInteractor: PresentableInteractor<WalletTripPresentable> {
    /// Class's public properties.
    weak var router: WalletTripRouting?
    weak var listener: WalletTripListener?

    /// Class's constructor.
    override init(presenter: WalletTripPresentable) {
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

// MARK: WalletTripInteractable's members
extension WalletTripInteractor: WalletTripInteractable {
}

// MARK: WalletTripPresentableListener's members
extension WalletTripInteractor: WalletTripPresentableListener {
}

// MARK: Class's private methods
private extension WalletTripInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
