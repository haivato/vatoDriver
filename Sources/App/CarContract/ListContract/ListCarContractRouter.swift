//  File name   : ListCarContractRouter.swift
//
//  Author      : Phan Hai
//  Created date: 09/09/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol ListCarContractInteractable: Interactable, ContractDetailListener {
    var router: ListCarContractRouting? { get set }
    var listener: ListCarContractListener? { get set }
}

protocol ListCarContractViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ListCarContractRouter: ViewableRouter<ListCarContractInteractable, ListCarContractViewControllable> {
    /// Class's constructor.
    init(interactor: ListCarContractInteractable,
         viewController: ListCarContractViewControllable,
         contractDetail: ContractDetailBuildable) {
        self.contractDetail = contractDetail
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    private let contractDetail: ContractDetailBuildable
    
    /// Class's private properties.
}

// MARK: ListCarContractRouting's members
extension ListCarContractRouter: ListCarContractRouting {
    func moveContractDetail(item: ContractHistoryType) {
        let route = contractDetail.build(withListener: interactor, item: item)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
}

// MARK: Class's private methods
private extension ListCarContractRouter {
}
