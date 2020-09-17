//  File name   : QuickSupportListBuilder.swift
//
//  Author      : khoi tran
//  Created date: 1/15/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol QuickSupportListDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class QuickSupportListComponent: Component<QuickSupportListDependency> {
    /// Class's public properties.
    let QuickSupportListVC: QuickSupportListVC
    
    /// Class's constructor.
    init(dependency: QuickSupportListDependency, QuickSupportListVC: QuickSupportListVC) {
        self.QuickSupportListVC = QuickSupportListVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol QuickSupportListBuildable: Buildable {
    func build(withListener listener: QuickSupportListListener) -> QuickSupportListRouting
}

final class QuickSupportListBuilder: Builder<QuickSupportListDependency>, QuickSupportListBuildable {
    /// Class's constructor.
    override init(dependency: QuickSupportListDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: QuickSupportListBuildable's members
    func build(withListener listener: QuickSupportListListener) -> QuickSupportListRouting {
        let vc = QuickSupportListVC(nibName: QuickSupportListVC.identifier, bundle: nil)
        let component = QuickSupportListComponent(dependency: dependency, QuickSupportListVC: vc)

        let interactor = QuickSupportListInteractor(presenter: component.QuickSupportListVC)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let quickSupportDetailBuilder = QuickSupportDetailBuilder(dependency: component)
        return QuickSupportListRouter(interactor: interactor, viewController: component.QuickSupportListVC, quickSupportDetailBuildable: quickSupportDetailBuilder)
    }
}
