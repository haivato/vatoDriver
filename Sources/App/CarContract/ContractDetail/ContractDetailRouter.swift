//  File name   : ContractDetailRouter.swift
//
//  Author      : Phan Hai
//  Created date: 28/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol ContractDetailInteractable: Interactable, ChatListener, ReceiptCarContractListener {
    var router: ContractDetailRouting? { get set }
    var listener: ContractDetailListener? { get set }
}

protocol ContractDetailViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ContractDetailRouter: ViewableRouter<ContractDetailInteractable, ContractDetailViewControllable> {
    /// Class's constructor.
    init(interactor: ContractDetailInteractable,
         viewController: ContractDetailViewControllable,
         chatBuilable: ChatBuildable,
         receiptBuildable: ReceiptCarContractBuildable) {
        self.chatBuilable = chatBuilable
        self.receiptBuildable = receiptBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    private let chatBuilable: ChatBuildable
    private let receiptBuildable: ReceiptCarContractBuildable
    
    /// Class's private properties.
}

// MARK: ContractDetailRouting's members
extension ContractDetailRouter: ContractDetailRouting {
    func moveToChat(item: OrderContract) {
        let route = chatBuilable.build(withListener: interactor, item: item)
        let segue = RibsRouting(use: route, transitionType: .modal(type: .crossDissolve, presentStyle: .overCurrentContext) , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    func showAlertError(text: String) {
        AlertVC.showMessageAlert(for: self.viewController.uiviewController, title: "Thông báo", message: text, actionButton1: "Đóng", actionButton2: nil)
    }
    func routeToReceipt(item: OrderContract) {
        let route = receiptBuildable.build(withListener: interactor, item: item)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension ContractDetailRouter {
}
