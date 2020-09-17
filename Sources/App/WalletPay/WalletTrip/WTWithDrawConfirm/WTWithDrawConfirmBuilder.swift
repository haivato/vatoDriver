//  File name   : WTWithDrawConfirmBuilder.swift
//
//  Author      : MacbookPro
//  Created date: 5/24/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol WTWithDrawConfirmDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class WTWithDrawConfirmComponent: Component<WTWithDrawConfirmDependency> {
    /// Class's public properties.
    let WTWithDrawConfirmVC: WTWithDrawConfirmVC
    
    /// Class's constructor.
    init(dependency: WTWithDrawConfirmDependency, WTWithDrawConfirmVC: WTWithDrawConfirmVC) {
        self.WTWithDrawConfirmVC = WTWithDrawConfirmVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol WTWithDrawConfirmBuildable: Buildable {
    func build(withListener listener: WTWithDrawConfirmListener, item: UserBankInfo, balance: DriverBalance) -> WTWithDrawConfirmRouting
    func build(withListener listener: WTWithDrawConfirmListener, item: TopupCellModel, point: Int, balance: DriverBalance) -> WTWithDrawConfirmRouting
}

final class WTWithDrawConfirmBuilder: Builder<WTWithDrawConfirmDependency>, WTWithDrawConfirmBuildable {
    func build(withListener listener: WTWithDrawConfirmListener, item: TopupCellModel, point: Int, balance: DriverBalance) -> WTWithDrawConfirmRouting {
       guard let vc = UIStoryboard(name: "WalletTripVC", bundle: nil).instantiateViewController(withIdentifier: WTWithDrawConfirmVC.identifier) as? WTWithDrawConfirmVC else { fatalError("Please Implement") }
        let component = WTWithDrawConfirmComponent(dependency: dependency, WTWithDrawConfirmVC: vc)

        let interactor = WTWithDrawConfirmInteractor(presenter: component.WTWithDrawConfirmVC, topUpItem: item, point: point, balance: balance)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let wtWithDrawSuccessBuildable = WTWithDrawSuccessBuilder(dependency: component)

        return WTWithDrawConfirmRouter(interactor: interactor, viewController: component.WTWithDrawConfirmVC, wtWithDrawSuccessBuildable: wtWithDrawSuccessBuildable)
    }

    func build(withListener listener: WTWithDrawConfirmListener, item: UserBankInfo, balance: DriverBalance) -> WTWithDrawConfirmRouting {
        guard let vc = UIStoryboard(name: "WalletTripVC", bundle: nil).instantiateViewController(withIdentifier: WTWithDrawConfirmVC.identifier) as? WTWithDrawConfirmVC else { fatalError("Please Implement") }
        let component = WTWithDrawConfirmComponent(dependency: dependency, WTWithDrawConfirmVC: vc)

        let interactor = WTWithDrawConfirmInteractor(presenter: component.WTWithDrawConfirmVC, item: item , balance: balance)
        interactor.listener = listener
            
        // todo: Create builder modules builders and inject into router here.
        let wtWithDrawSuccessBuildable = WTWithDrawSuccessBuilder(dependency: component)
        
        return WTWithDrawConfirmRouter(interactor: interactor, viewController: component.WTWithDrawConfirmVC, wtWithDrawSuccessBuildable: wtWithDrawSuccessBuildable)
    }
}
