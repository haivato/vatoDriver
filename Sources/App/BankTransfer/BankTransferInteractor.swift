//  File name   : BankTransferInteractor.swift
//
//  Author      : Futa Corp
//  Created date: 2/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol BankTransferRouting: ViewableRouting {
    func routeToBankTransferDetail(bank: FirebaseModel.BankTransferConfig)
}

protocol BankTransferPresentable: Presentable {
    var listener: BankTransferPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol BankTransferListener: class {
    func requestToDismissBankTransferModule()
}

final class BankTransferInteractor: PresentableInteractor<BankTransferPresentable> {
    /// Class's public properties.
    weak var router: BankTransferRouting?
    weak var listener: BankTransferListener?

    /// Class's constructor.
    init(presenter: BankTransferPresentable,
         firebaseDatabase: DatabaseReference)
    {
        self.firebaseDatabase = firebaseDatabase
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
    private let firebaseDatabase: DatabaseReference

    private let banksSubject = ReplaySubject<[FirebaseModel.BankTransferConfig]>.create(bufferSize: 1)
}

// MARK: BankTransferInteractable's members
extension BankTransferInteractor: BankTransferInteractable {
    func requestToDismissBankTransferDetailModule() {
        router?.dismissCurrentRoute(completion: nil)
    }

}

// MARK: BankTransferPresentableListener's members
extension BankTransferInteractor: BankTransferPresentableListener {
    var banks: Observable<[FirebaseModel.BankTransferConfig]> {
        return banksSubject.asObservable()
    }

    func handleBackItemAction() {
        listener?.requestToDismissBankTransferModule()
    }

    func handleCellSelectionAction(bank: FirebaseModel.BankTransferConfig) {
        router?.routeToBankTransferDetail(bank: bank)
    }

}

// MARK: Class's private methods
private extension BankTransferInteractor {
    private func setupRX() {
        let node = FireBaseTable.master >>> FireBaseTable.appConfigure >>> FireBaseTable.custom(identify: "bank_transfer_config")
        firebaseDatabase.find(by: node, type: .value, using: { ref in
            ref.keepSynced(true)

            let query = ref.queryOrdered(byChild: "active").queryEqual(toValue: true)
            return query
        })
        .timeout(10.0, scheduler: SerialDispatchQueueScheduler(qos: .background))
        .take(1)
        .subscribe(onNext: { [weak self] (snapshot) in
            let children = snapshot.children.compactMap { $0 as? DataSnapshot }.compactMap { try? FirebaseModel.BankTransferConfig.create(from: $0) }

            guard children.count > 0 else {
                return
            }
            self?.banksSubject.onNext(children)
        })
        .disposeOnDeactivate(interactor: self)
    }
}
