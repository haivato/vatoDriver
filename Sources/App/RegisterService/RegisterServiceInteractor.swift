//  File name   : RegisterServiceInteractor.swift
//
//  Author      : MacbookPro
//  Created date: 4/27/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol RegisterServiceRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol RegisterServicePresentable: Presentable {
    var listener: RegisterServicePresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol RegisterServiceListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func dimiss()
    func selectCar(itemCar: CarInfo)
}

final class RegisterServiceInteractor: PresentableInteractor<RegisterServicePresentable> {
    /// Class's public properties.
    weak var router: RegisterServiceRouting?
    weak var listener: RegisterServiceListener?
    private let listCar: [CarInfo]

    /// Class's constructor.
    init(presenter: RegisterServicePresentable, listCar: [CarInfo]) {
        self.listCar = listCar
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        mlistCar = self.listCar
        // todo: Implement business logic here.
    }
    @Replay(queue: MainScheduler.asyncInstance) private var mlistCar: [CarInfo]

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
}

// MARK: RegisterServiceInteractable's members
extension RegisterServiceInteractor: RegisterServiceInteractable {
}

// MARK: RegisterServicePresentableListener's members
extension RegisterServiceInteractor: RegisterServicePresentableListener {
    
    var listCarObs: Observable<[CarInfo]> {
        return $mlistCar.asObservable()
    }
    
    func selectCar(itemCar: CarInfo) {
        self.listener?.selectCar(itemCar: itemCar)
    }
    
    func moveBack() {
        self.listener?.dimiss()
    }
    
}

// MARK: Class's private methods
private extension RegisterServiceInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
