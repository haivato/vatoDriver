//  File name   : ListBankBuilder.swift
//
//  Author      : MacbookPro
//  Created date: 5/22/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol ListBankDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class ListBankComponent: Component<ListBankDependency> {
    /// Class's public properties.
    let ListBankVC: ListBankVC
    
    /// Class's constructor.
    init(dependency: ListBankDependency, ListBankVC: ListBankVC) {
        self.ListBankVC = ListBankVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol ListBankBuildable: Buildable {
    func build(withListener listener: ListBankListener, listBank: [BankInfoServer]) -> ListBankRouting
}

final class ListBankBuilder: Builder<ListBankDependency>, ListBankBuildable {
    /// Class's constructor.
    override init(dependency: ListBankDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: ListBankBuildable's members
    func build(withListener listener: ListBankListener, listBank: [BankInfoServer]) -> ListBankRouting {
        guard let vc = UIStoryboard(name: "WalletTripVC", bundle: nil).instantiateViewController(withIdentifier: ListBankVC.identifier) as? ListBankVC else { fatalError("Please Implement") }
        let component = ListBankComponent(dependency: dependency, ListBankVC: vc)

        let interactor = ListBankInteractor(presenter: component.ListBankVC,  listBank: listBank)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return ListBankRouter(interactor: interactor, viewController: component.ListBankVC)
    }
}
