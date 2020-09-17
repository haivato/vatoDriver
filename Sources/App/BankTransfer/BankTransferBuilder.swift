//  File name   : BankTransferBuilder.swift
//
//  Author      : Futa Corp
//  Created date: 2/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore
import FirebaseDatabase

// MARK: Dependency tree
protocol BankTransferDependency: Dependency {
    var firebaseDatabase: DatabaseReference { get }
}

final class BankTransferComponent: Component<BankTransferDependency> {
    /// Class's public properties.
    let BankTransferVC: BankTransferVC
    
    /// Class's constructor.
    init(dependency: BankTransferDependency, BankTransferVC: BankTransferVC) {
        self.BankTransferVC = BankTransferVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    fileprivate var firebaseDatabase: DatabaseReference {
        return dependency.firebaseDatabase
    }
}

// MARK: Builder
protocol BankTransferBuildable: Buildable {
    func build(withListener listener: BankTransferListener) -> BankTransferRouting
}

final class BankTransferBuilder: Builder<BankTransferDependency>, BankTransferBuildable {
    /// Class's constructor.
    override init(dependency: BankTransferDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: BankTransferBuildable's members
    func build(withListener listener: BankTransferListener) -> BankTransferRouting {
        let vc = BankTransferVC(style: .grouped)
        let component = BankTransferComponent(dependency: dependency, BankTransferVC: vc)

        let interactor = BankTransferInteractor(presenter: component.BankTransferVC,
                                                firebaseDatabase: component.firebaseDatabase)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let bankTransferDetailBuilder = BankTransferDetailBuilder(dependency: component)

        return BankTransferRouter(interactor: interactor,
                                  viewController: component.BankTransferVC,
                                  bankTransferDetailBuilder: bankTransferDetailBuilder)
    }
}
