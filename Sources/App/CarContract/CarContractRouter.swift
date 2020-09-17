//  File name   : CarContractRouter.swift
//
//  Author      : Phan Hai
//  Created date: 28/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol CarContractInteractable: Interactable, ContractDetailListener, CCChatWithVatoListener {
    var router: CarContractRouting? { get set }
    var listener: CarContractListener? { get set }
}

protocol CarContractViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class CarContractRouter: ViewableRouter<CarContractInteractable, CarContractViewControllable> {
    /// Class's constructor.
    init(interactor: CarContractInteractable,
         viewController: CarContractViewControllable,
         contractDetail: ContractDetailBuildable,
         chatWithVato: CCChatWithVatoBuildable) {
        self.contractDetail = contractDetail
        self.chatWithVato = chatWithVato
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    private let contractDetail: ContractDetailBuildable
    private let chatWithVato: CCChatWithVatoBuildable
    
    /// Class's private properties.
}

// MARK: CarContractRouting's members
extension CarContractRouter: CarContractRouting {
    func routeToContractDetail(item: OrderContract) {
        let route = contractDetail.build(withListener: interactor, item: item)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToChatWithVato() {
        let route = chatWithVato.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    func showAlertError(text: String) {
        AlertVC.showMessageAlert(for: self.viewController.uiviewController, title: "Thông báo", message: text, actionButton1: "Đóng", actionButton2: nil)
    }
    
}

// MARK: Class's private methods
private extension CarContractRouter {
}
