//  File name   : CCChatWithVatoInteractor.swift
//
//  Author      : Phan Hai
//  Created date: 31/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol CCChatWithVatoRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol CCChatWithVatoPresentable: Presentable {
    var listener: CCChatWithVatoPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol CCChatWithVatoListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func moveBackOrderContract()
}

final class CCChatWithVatoInteractor: PresentableInteractor<CCChatWithVatoPresentable> {
    /// Class's public properties.
    weak var router: CCChatWithVatoRouting?
    weak var listener: CCChatWithVatoListener?

    /// Class's constructor.
    override init(presenter: CCChatWithVatoPresentable) {
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

// MARK: CCChatWithVatoInteractable's members
extension CCChatWithVatoInteractor: CCChatWithVatoInteractable {
}

// MARK: CCChatWithVatoPresentableListener's members
extension CCChatWithVatoInteractor: CCChatWithVatoPresentableListener {
    func moveBackOrderContract() {
        self.listener?.moveBackOrderContract()
    }
}

// MARK: Class's private methods
private extension CCChatWithVatoInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
