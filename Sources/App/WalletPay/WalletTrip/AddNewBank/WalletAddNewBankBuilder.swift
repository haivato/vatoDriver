//  File name   : WalletAddNewBankBuilder.swift
//
//  Author      : MacbookPro
//  Created date: 5/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol WalletAddNewBankDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class WalletAddNewBankComponent: Component<WalletAddNewBankDependency> {
    /// Class's public properties.
    let WalletAddNewBankVC: WalletAddNewBankVC
    
    /// Class's constructor.
    init(dependency: WalletAddNewBankDependency, WalletAddNewBankVC: WalletAddNewBankVC) {
        self.WalletAddNewBankVC = WalletAddNewBankVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol WalletAddNewBankBuildable: Buildable {
    func build(withListener listener: WalletAddNewBankListener, user: UserBankInfo?) -> WalletAddNewBankRouting
}

final class WalletAddNewBankBuilder: Builder<WalletAddNewBankDependency>, WalletAddNewBankBuildable {
    
    /// Class's constructor.
    override init(dependency: WalletAddNewBankDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: WalletAddNewBankBuildable's members
    func build(withListener listener: WalletAddNewBankListener, user: UserBankInfo?) -> WalletAddNewBankRouting {
//        let vc = WalletAddNewBankVC()
        guard let vc = UIStoryboard(name: "WalletTripVC", bundle: nil).instantiateViewController(withIdentifier: WalletAddNewBankVC.identifier) as? WalletAddNewBankVC else { fatalError("Please Implement") }
        let component = WalletAddNewBankComponent(dependency: dependency, WalletAddNewBankVC: vc)

        let interactor = WalletAddNewBankInteractor(presenter: component.WalletAddNewBankVC, user: user)
        interactor.listener = listener

        let listBankBuilder = WalletTripListBankBuilder(dependency: component)
        // todo: Create builder modules builders and inject into router here.
        
        return WalletAddNewBankRouter(interactor: interactor,
                                      viewController: component.WalletAddNewBankVC,
                                      listBankBuildale: listBankBuilder)
    }
}
