//  File name   : QuickSupportMainBuilder.swift
//
//  Author      : khoi tran
//  Created date: 1/14/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol QuickSupportMainDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class QuickSupportMainComponent: Component<QuickSupportMainDependency> {
    /// Class's public properties.
    let QuickSupportMainVC: QuickSupportMainVC
    
    /// Class's constructor.
    init(dependency: QuickSupportMainDependency, QuickSupportMainVC: QuickSupportMainVC) {
        self.QuickSupportMainVC = QuickSupportMainVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol QuickSupportMainBuildable: Buildable {
    func build(withListener listener: QuickSupportMainListener) -> QuickSupportMainRouting
}

final class QuickSupportMainBuilder: Builder<QuickSupportMainDependency>, QuickSupportMainBuildable {
    /// Class's constructor.
    override init(dependency: QuickSupportMainDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: QuickSupportMainBuildable's members
    func build(withListener listener: QuickSupportMainListener) -> QuickSupportMainRouting {
        let vc = QuickSupportMainVC(nibName: QuickSupportMainVC.identifier, bundle: nil)
        
        let component = QuickSupportMainComponent(dependency: dependency, QuickSupportMainVC: vc)

        let interactor = QuickSupportMainInteractor(presenter: component.QuickSupportMainVC)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let quickSupportListBuilder = QuickSupportListBuilder(dependency: component)
        
        let requestQuickSupportBuilder = RequestQuickSupportBuilder(dependency: component)

        return QuickSupportMainRouter(interactor: interactor,
                                      viewController: component.QuickSupportMainVC,
                                      requestQuickSupportBuildable: requestQuickSupportBuilder,
                                      quickSupportListBuildableBuildable: quickSupportListBuilder)
    }
}
