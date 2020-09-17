//  File name   : WTWithDrawBuilder.swift
//
//  Author      : admin
//  Created date: 6/3/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol WTWithDrawDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class WTWithDrawComponent: Component<WTWithDrawDependency> {
    /// Class's public properties.
    let WTWithDrawVC: WTWithDrawVC
    
    /// Class's constructor.
    init(dependency: WTWithDrawDependency, WTWithDrawVC: WTWithDrawVC) {
        self.WTWithDrawVC = WTWithDrawVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol WTWithDrawBuildable: Buildable {
//    func build(withListener listener: WTWithDrawListener) -> WTWithDrawRouting
    func build(withListener listener: WTWithDrawListener, listUserBank: [UserBankInfo]?, balance: DriverBalance?) -> WTWithDrawRouting
}

final class WTWithDrawBuilder: Builder<WTWithDrawDependency>, WTWithDrawBuildable {
    /// Class's constructor.
    override init(dependency: WTWithDrawDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: WTWithDrawBuildable's members
    func build(withListener listener: WTWithDrawListener, listUserBank: [UserBankInfo]?, balance: DriverBalance?) -> WTWithDrawRouting {
        guard let vc = UIStoryboard(name: "WalletTripVC", bundle: nil).instantiateViewController(withIdentifier: "withdraw") as? WTWithDrawVC else { fatalError("Please Implement") }
        let component = WTWithDrawComponent(dependency: dependency, WTWithDrawVC: vc)

        let interactor = WTWithDrawInteractor(presenter: component.WTWithDrawVC, listUserBank: listUserBank, balance: balance)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let wtWithDrawBuilder = WTWithDrawConfirmBuilder(dependency: component)

        return WTWithDrawRouter(interactor: interactor, viewController: component.WTWithDrawVC, wtWithDrawConfirm: wtWithDrawBuilder)
    }
    
//    func build(withListener listener: WTWithDrawListener, list: [TopUpMethod], listUserBank: [UserBankInfo]?, balance: DriverBalance?) -> WTWithDrawRouting {
//        guard let vc = UIStoryboard(name: "WTWithDrawVC", bundle: nil).instantiateViewController(withIdentifier: "withdraw") as? WTWithDrawVC else { fatalError("Please Implement") }
//
//        let component = WTWithDrawComponent(dependency: dependency, WTWithDrawVC: vc)
//
//        let interactor = WTWithDrawInteractor(presenter: component.WTWithDrawVC, list: list, listUserBank: listUserBank, balance: balance)
//
//        interactor.listener = listener
//
////        let wtWithDrawBulder = WTWithDrawConfirmBuilder(dependency: component)
//        // todo: Create builder modules builders and inject into router here.
//
//        return WTWithDrawRouter(interactor: interactor, viewController: component.WTWithDrawVC)
//    }
}
