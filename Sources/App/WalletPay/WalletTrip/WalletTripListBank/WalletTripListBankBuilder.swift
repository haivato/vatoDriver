//  File name   : WalletTripListBankBuilder.swift
//
//  Author      : MacbookPro
//  Created date: 5/22/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol WalletTripListBankDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class WalletTripListBankComponent: Component<WalletTripListBankDependency> {
    /// Class's public properties.
    let WalletTripListBankVC: WalletTripListBankVC
    
    /// Class's constructor.
    init(dependency: WalletTripListBankDependency, WalletTripListBankVC: WalletTripListBankVC) {
        self.WalletTripListBankVC = WalletTripListBankVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol WalletTripListBankBuildable: Buildable {
    func build(withListener listener: WalletTripListBankListener, listBank: [BankInfoServer]) -> WalletTripListBankRouting
}

final class WalletTripListBankBuilder: Builder<WalletTripListBankDependency>, WalletTripListBankBuildable {
    /// Class's constructor.
    override init(dependency: WalletTripListBankDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: WalletTripListBankBuildable's members
    func build(withListener listener: WalletTripListBankListener, listBank: [BankInfoServer]) -> WalletTripListBankRouting {
//        let vc = WalletTripListBankVC()
                guard let vc = UIStoryboard(name: "WalletTripVC", bundle: nil).instantiateViewController(withIdentifier: WalletTripListBankVC.identifier) as? WalletTripListBankVC else { fatalError("Please Implement") }
        let component = WalletTripListBankComponent(dependency: dependency, WalletTripListBankVC: vc)

        let interactor = WalletTripListBankInteractor(presenter: component.WalletTripListBankVC, listBank: listBank)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return WalletTripListBankRouter(interactor: interactor, viewController: component.WalletTripListBankVC)
    }
}
