//  File name   : ContractDetailBuilder.swift
//
//  Author      : Phan Hai
//  Created date: 28/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol ContractDetailDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class ContractDetailComponent: Component<ContractDetailDependency> {
    /// Class's public properties.
    let ContractDetailVC: ContractDetailVC
    
    /// Class's constructor.
    init(dependency: ContractDetailDependency, ContractDetailVC: ContractDetailVC) {
        self.ContractDetailVC = ContractDetailVC
        super.init(dependency: dependency)
    }
    var mutableChatStream: ChatStreamImpl {
        return shared { ChatStreamImpl(with: nil) }
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol ContractDetailBuildable: Buildable {
    func build(withListener listener: ContractDetailListener, item: OrderContract) -> ContractDetailRouting
}

final class ContractDetailBuilder: Builder<ContractDetailDependency>, ContractDetailBuildable {
    /// Class's constructor.
    override init(dependency: ContractDetailDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: ContractDetailBuildable's members
    func build(withListener listener: ContractDetailListener, item: OrderContract) -> ContractDetailRouting {
        let vc = ContractDetailVC(nibName: ContractDetailVC.identifier, bundle: nil)
        let component = ContractDetailComponent(dependency: dependency, ContractDetailVC: vc)

        let interactor = ContractDetailInteractor(presenter: component.ContractDetailVC, item: item, chatStream: component.mutableChatStream)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let chatBuilder = ChatBuilder(dependency: component)
        let receiptBuildable = ReceiptCarContractBuilder(dependency: component)
        
        return ContractDetailRouter(interactor: interactor,
                                    viewController: component.ContractDetailVC,
                                    chatBuilable: chatBuilder,
                                    receiptBuildable: receiptBuildable)
    }
}
