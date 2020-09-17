//  File name   : WTWithDrawSuccessBuilder.swift
//
//  Author      : admin
//  Created date: 5/30/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol WTWithDrawSuccessDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class WTWithDrawSuccessComponent: Component<WTWithDrawSuccessDependency> {
    /// Class's public properties.
    let WTWithDrawSuccessVC: WTWithDrawSuccessVC
    
    /// Class's constructor.
    init(dependency: WTWithDrawSuccessDependency, WTWithDrawSuccessVC: WTWithDrawSuccessVC) {
        self.WTWithDrawSuccessVC = WTWithDrawSuccessVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol WTWithDrawSuccessBuildable: Buildable {
    func build(withListener listener: WTWithDrawSuccessListener, info: PointTransactionInfo) -> WTWithDrawSuccessRouting    
    func build(withListener listener: WTWithDrawSuccessListener, bankInfo: BankTransactionInfo) -> WTWithDrawSuccessRouting
}

final class WTWithDrawSuccessBuilder: Builder<WTWithDrawSuccessDependency>, WTWithDrawSuccessBuildable {
    /// Class's constructor.
    override init(dependency: WTWithDrawSuccessDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: WTWithDrawSuccessBuildable's members
    func build(withListener listener: WTWithDrawSuccessListener, info: PointTransactionInfo) -> WTWithDrawSuccessRouting {
        let vc = WTWithDrawSuccessVC()
        let component = WTWithDrawSuccessComponent(dependency: dependency, WTWithDrawSuccessVC: vc)

        let interactor = WTWithDrawSuccessInteractor(presenter: component.WTWithDrawSuccessVC, topUpInfo: info)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        
        return WTWithDrawSuccessRouter(interactor: interactor, viewController: component.WTWithDrawSuccessVC)
    }
    
    func build(withListener listener: WTWithDrawSuccessListener, bankInfo: BankTransactionInfo) -> WTWithDrawSuccessRouting {
        let vc = WTWithDrawSuccessVC()
        let component = WTWithDrawSuccessComponent(dependency: dependency, WTWithDrawSuccessVC: vc)

        let interactor = WTWithDrawSuccessInteractor(presenter: component.WTWithDrawSuccessVC, bankInfo: bankInfo)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        
        return WTWithDrawSuccessRouter(interactor: interactor, viewController: component.WTWithDrawSuccessVC)
    }
}
