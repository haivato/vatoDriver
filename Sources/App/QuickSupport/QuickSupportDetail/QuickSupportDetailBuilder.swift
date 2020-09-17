//  File name   : QuickSupportDetailBuilder.swift
//
//  Author      : khoi tran
//  Created date: 1/16/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol QuickSupportDetailDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class QuickSupportDetailComponent: Component<QuickSupportDetailDependency> {
    /// Class's public properties.
    let QuickSupportDetailVC: QuickSupportDetailVC
    
    /// Class's constructor.
    init(dependency: QuickSupportDetailDependency, QuickSupportDetailVC: QuickSupportDetailVC) {
        self.QuickSupportDetailVC = QuickSupportDetailVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol QuickSupportDetailBuildable: Buildable {
    func build(withListener listener: QuickSupportDetailListener, qsItem: QuickSupportModel) -> QuickSupportDetailRouting
}

final class QuickSupportDetailBuilder: Builder<QuickSupportDetailDependency>, QuickSupportDetailBuildable {
    /// Class's constructor.
    override init(dependency: QuickSupportDetailDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: QuickSupportDetailBuildable's members
    func build(withListener listener: QuickSupportDetailListener, qsItem: QuickSupportModel) -> QuickSupportDetailRouting {
        let vc = QuickSupportDetailVC(nibName: QuickSupportDetailVC.identifier, bundle: nil)
        let component = QuickSupportDetailComponent(dependency: dependency, QuickSupportDetailVC: vc)

        let interactor = QuickSupportDetailInteractor(presenter: component.QuickSupportDetailVC, qsItem: qsItem)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return QuickSupportDetailRouter(interactor: interactor, viewController: component.QuickSupportDetailVC)
    }
}
