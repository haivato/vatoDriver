//  File name   : WalletInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 5/18/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol WalletRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol WalletPresentable: Presentable {
    var listener: WalletPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol WalletListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class WalletInteractor: PresentableInteractor<WalletPresentable> {
    /// Class's public properties.
    weak var router: WalletRouting?
    weak var listener: WalletListener?

    /// Class's constructor.
    override init(presenter: WalletPresentable) {
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

// MARK: WalletInteractable's members
extension WalletInteractor: WalletInteractable {
}

// MARK: WalletPresentableListener's members
extension WalletInteractor: WalletPresentableListener {
}

// MARK: Class's private methods
private extension WalletInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}

final class TopupConfigResponse: NSObject, TopupLinkConfigureProtocol, Codable {
    func clone() -> TopupLinkConfigureProtocol {
        let clone = TopupConfigResponse()
        clone.type = self.type
        clone.name = self.name
        clone.url = self.url
        clone.auth = self.auth
        clone.active = self.active
        clone.iconURL = self.iconURL
        clone.min = self.min
        clone.max = self.max
        clone.options = self.options
        return clone
    }
    
    var type: Int = 0
    var name: String?
    var url: String?
    var auth: Bool = false
    var active: Bool = false
    var iconURL: String?
    var min: Int = 0
    var max: Int = 0
    var options: [Double]?
}

