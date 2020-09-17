//  File name   : ReceiptCarContractBuilder.swift
//
//  Author      : Phan Hai
//  Created date: 31/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol ReceiptCarContractDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class ReceiptCarContractComponent: Component<ReceiptCarContractDependency> {
    /// Class's public properties.
    let ReceiptCarContractVC: ReceiptCarContractVC
    
    /// Class's constructor.
    init(dependency: ReceiptCarContractDependency, ReceiptCarContractVC: ReceiptCarContractVC) {
        self.ReceiptCarContractVC = ReceiptCarContractVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol ReceiptCarContractBuildable: Buildable {
    func build(withListener listener: ReceiptCarContractListener, item: OrderContract) -> ReceiptCarContractRouting
}

final class ReceiptCarContractBuilder: Builder<ReceiptCarContractDependency>, ReceiptCarContractBuildable {
    /// Class's constructor.
    override init(dependency: ReceiptCarContractDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: ReceiptCarContractBuildable's members
    func build(withListener listener: ReceiptCarContractListener, item: OrderContract) -> ReceiptCarContractRouting {
        let vc = ReceiptCarContractVC(nibName: ReceiptCarContractVC.identifier, bundle: nil)
        let component = ReceiptCarContractComponent(dependency: dependency, ReceiptCarContractVC: vc)

        let interactor = ReceiptCarContractInteractor(presenter: component.ReceiptCarContractVC, item: item)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return ReceiptCarContractRouter(interactor: interactor, viewController: component.ReceiptCarContractVC)
    }
}
