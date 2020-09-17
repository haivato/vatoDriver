//  File name   : ReceiptCarContractInteractor.swift
//
//  Author      : Phan Hai
//  Created date: 31/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol ReceiptCarContractRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol ReceiptCarContractPresentable: Presentable {
    var listener: ReceiptCarContractPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol ReceiptCarContractListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func moveBack()
    func routeToHome()
}

final class ReceiptCarContractInteractor: PresentableInteractor<ReceiptCarContractPresentable> {
    /// Class's public properties.
    weak var router: ReceiptCarContractRouting?
    weak var listener: ReceiptCarContractListener?
    private var item: OrderContract

    /// Class's constructor.
    init(presenter: ReceiptCarContractPresentable, item: OrderContract) {
        self.item = item
        super.init(presenter: presenter)
        presenter.listener = self
    }

    @Replay(queue: MainScheduler.asyncInstance) private var mItem: OrderContract
    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        mItem = self.item
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
}

// MARK: ReceiptCarContractInteractable's members
extension ReceiptCarContractInteractor: ReceiptCarContractInteractable {
}

// MARK: ReceiptCarContractPresentableListener's members
extension ReceiptCarContractInteractor: ReceiptCarContractPresentableListener {
     var itemObs: Observable<OrderContract> {
        return self.$mItem
    }
    func moveBack() {
        self.listener?.moveBack()
    }
    func routeToHome() {
        self.listener?.routeToHome()
    }
}

// MARK: Class's private methods
private extension ReceiptCarContractInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
