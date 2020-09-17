//  File name   : RequestQuickSupportBuilder.swift
//
//  Author      : vato.
//  Created date: 1/15/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol RequestQuickSupportDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class RequestQuickSupportComponent: Component<RequestQuickSupportDependency> {
    /// Class's public properties.
    let RequestQuickSupportVC: RequestQuickSupportVC
    
    /// Class's constructor.
    init(dependency: RequestQuickSupportDependency, RequestQuickSupportVC: RequestQuickSupportVC) {
        self.RequestQuickSupportVC = RequestQuickSupportVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol RequestQuickSupportBuildable: Buildable {
    func build(withListener listener: RequestQuickSupportListener, requestModel: QuickSupportRequest, defaultContent: String?) -> RequestQuickSupportRouting
}

final class RequestQuickSupportBuilder: Builder<RequestQuickSupportDependency>, RequestQuickSupportBuildable {
    /// Class's constructor.
    override init(dependency: RequestQuickSupportDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: RequestQuickSupportBuildable's members
    func build(withListener listener: RequestQuickSupportListener,
               requestModel: QuickSupportRequest, defaultContent: String?) -> RequestQuickSupportRouting {
        let vc = RequestQuickSupportVC()
        
        let component = RequestQuickSupportComponent(dependency: dependency, RequestQuickSupportVC: vc)

        let interactor = RequestQuickSupportInteractor(presenter: component.RequestQuickSupportVC, requestModel: requestModel, defaultContent: defaultContent)
        interactor.listener = listener
        
        let quickSupportListBuilder = QuickSupportListBuilder(dependency: component)

        // todo: Create builder modules builders and inject into router here.
        
        return RequestQuickSupportRouter(interactor: interactor,
                                         viewController: component.RequestQuickSupportVC,
                                         quickSupportListBuildable: quickSupportListBuilder)
    }
}
