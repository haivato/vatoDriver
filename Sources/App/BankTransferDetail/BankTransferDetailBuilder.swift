//  File name   : BankTransferDetailBuilder.swift
//
//  Author      : Futa Corp
//  Created date: 2/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol BankTransferDetailDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class BankTransferDetailComponent: Component<BankTransferDetailDependency> {
    /// Class's public properties.
    let BankTransferDetailVC: BankTransferDetailVC
    
    /// Class's constructor.
    init(dependency: BankTransferDetailDependency, BankTransferDetailVC: BankTransferDetailVC) {
        self.BankTransferDetailVC = BankTransferDetailVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol BankTransferDetailBuildable: Buildable {
    func build(withListener listener: BankTransferDetailListener, bank: FirebaseModel.BankTransferConfig) -> BankTransferDetailRouting
}

final class BankTransferDetailBuilder: Builder<BankTransferDetailDependency>, BankTransferDetailBuildable {
    /// Class's constructor.
    override init(dependency: BankTransferDetailDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: BankTransferDetailBuildable's members
    func build(withListener listener: BankTransferDetailListener, bank: FirebaseModel.BankTransferConfig) -> BankTransferDetailRouting {
        let vc = BankTransferDetailVC(with: bank)
        let component = BankTransferDetailComponent(dependency: dependency, BankTransferDetailVC: vc)

        let interactor = BankTransferDetailInteractor(presenter: component.BankTransferDetailVC)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return BankTransferDetailRouter(interactor: interactor, viewController: component.BankTransferDetailVC)
    }
}
