//  File name   : WalletAddNewBankRouter.swift
//
//  Author      : MacbookPro
//  Created date: 5/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol WalletAddNewBankInteractable: Interactable, WalletTripListBankListener {
    var router: WalletAddNewBankRouting? { get set }
    var listener: WalletAddNewBankListener? { get set }
}

protocol WalletAddNewBankViewControllable: ViewControllable, ControllableProtocol {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class WalletAddNewBankRouter: ViewableRouter<WalletAddNewBankInteractable, WalletAddNewBankViewControllable> {
    /// Class's constructor.
    init(interactor: WalletAddNewBankInteractable,
         viewController: WalletAddNewBankViewControllable,
         listBankBuildale: WalletTripListBankBuildable) {
        self.mViewController = viewController
        self.listBankBuildale = listBankBuildale
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    private let listBankBuildale: WalletTripListBankBuildable
    private weak var currentRouting: ViewableRouting?
    private let mViewController: WalletAddNewBankViewControllable
    
    /// Class's private properties.
}

// MARK: WalletAddNewBankRouting's members
extension WalletAddNewBankRouter: WalletAddNewBankRouting {
    func showAlertError(messageError: String) {
        AlertVC.showMessageAlert(for: self.viewController.uiviewController, title: "Thông báo ", message: messageError, actionButton1: "Đóng", actionButton2: nil)
    }
    
    func moveListBank(listBank: [BankInfoServer]) {
        detactCurrentChild()
        let route = listBankBuildale.build(withListener: self.interactor, listBank: listBank)
        self.attach(route: route, using: TransitonType.modal(type: .crossDissolve, presentStyle: .overCurrentContext))
    }
    func detactCurrentChild() {
        guard let currentRouting = currentRouting else {
            return
        }
        detachChild(currentRouting)
        mViewController.dismiss(viewController: currentRouting.viewControllable, completion: nil)
    }
    private func attach(route: ViewableRouting, using transition: TransitonType) {
        defer { self.currentRouting = route }
        self.attachChild(route)
        self.mViewController.present(viewController: route.viewControllable, transitionType: transition, completion: nil)
    }
    
}

// MARK: Class's private methods
private extension WalletAddNewBankRouter {
}
