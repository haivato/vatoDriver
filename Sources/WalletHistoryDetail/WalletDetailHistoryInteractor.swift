//  File name   : WalletDetailHistoryInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 12/5/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol WalletDetailHistoryRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol WalletDetailHistoryPresentable: Presentable {
    var listener: WalletDetailHistoryPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol WalletDetailHistoryListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func detailHistoryMoveBack()
}

final class WalletDetailHistoryInteractor: PresentableInteractor<WalletDetailHistoryPresentable>, WalletDetailHistoryInteractable, WalletDetailHistoryPresentableListener {
    var source: Observable<WalletItemDisplayProtocol> {
        return _source.observeOn(MainScheduler.asyncInstance)
    }
    
    weak var router: WalletDetailHistoryRouting?
    weak var listener: WalletDetailHistoryListener?
    private let authenticated: AuthenticatedStream
    private let type: WalletDetailHistoryType
    private lazy var _source = ReplaySubject<WalletItemDisplayProtocol>.create(bufferSize: 1)

    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    init(presenter: WalletDetailHistoryPresentable, authenticated: AuthenticatedStream, type: WalletDetailHistoryType) {
        self.authenticated = authenticated
        self.type = type
        super.init(presenter: presenter)
        presenter.listener = self
        prepareData()
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    private func prepareData() {
        switch type {
        case .detail(let item):
            _source.onNext(item)
        case .refer:
            fatalError("Please Implement")
        }
    }
    
    func moveBack() {
        listener?.detailHistoryMoveBack()
    }
}
