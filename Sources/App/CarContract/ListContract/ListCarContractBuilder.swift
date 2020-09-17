//  File name   : ListCarContractBuilder.swift
//
//  Author      : Phan Hai
//  Created date: 09/09/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol ListCarContractDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class ListCarContractComponent: Component<ListCarContractDependency> {
    /// Class's public properties.
    let ListCarContractVC: ListCarContractVC
    
    /// Class's constructor.
    init(dependency: ListCarContractDependency, ListCarContractVC: ListCarContractVC) {
        self.ListCarContractVC = ListCarContractVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol ListCarContractBuildable: Buildable {
    func build(withListener listener: ListCarContractListener) -> ListCarContractRouting
}

final class ListCarContractBuilder: Builder<ListCarContractDependency>, ListCarContractBuildable {
    /// Class's constructor.
    override init(dependency: ListCarContractDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: ListCarContractBuildable's members
    func build(withListener listener: ListCarContractListener) -> ListCarContractRouting {
        guard let vc = UIStoryboard(name: "CarContractVC", bundle: nil).instantiateViewController(withIdentifier: ListCarContractVC.identifier) as? ListCarContractVC else {
            fatalError("Please Implement")
        }
        let component = ListCarContractComponent(dependency: dependency, ListCarContractVC: vc)

        let interactor = ListCarContractInteractor(presenter: component.ListCarContractVC)
        interactor.listener = listener
        
        let contractDetailBuilder = ContractDetailBuilder(dependency: component)

        // todo: Create builder modules builders and inject into router here.
        
        return ListCarContractRouter(interactor: interactor, viewController: component.ListCarContractVC, contractDetail: contractDetailBuilder)
    }
}
