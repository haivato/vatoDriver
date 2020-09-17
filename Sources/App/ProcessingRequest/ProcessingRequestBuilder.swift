//  File name   : ProcessingRequestBuilder.swift
//
//  Author      : MacbookPro
//  Created date: 4/1/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol ProcessingRequestDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class ProcessingRequestComponent: Component<ProcessingRequestDependency> {
    /// Class's public properties.
    let ProcessingRequestVC: ProcessingRequestVC
    
    /// Class's constructor.
    init(dependency: ProcessingRequestDependency, ProcessingRequestVC: ProcessingRequestVC) {
        self.ProcessingRequestVC = ProcessingRequestVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol ProcessingRequestBuildable: Buildable {
    func build(withListener listener: ProcessingRequestListener, listQuickSupport: [UserRequestTypeFireStore]) -> ProcessingRequestRouting
}

final class ProcessingRequestBuilder: Builder<ProcessingRequestDependency>, ProcessingRequestBuildable {
    /// Class's constructor.
    override init(dependency: ProcessingRequestDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: ProcessingRequestBuildable's members
    func build(withListener listener: ProcessingRequestListener, listQuickSupport: [UserRequestTypeFireStore]) -> ProcessingRequestRouting {
        let vc = ProcessingRequestVC(nibName: ProcessingRequestVC.identifier, bundle: nil)
        let component = ProcessingRequestComponent(dependency: dependency, ProcessingRequestVC: vc)

        let interactor = ProcessingRequestInteractor(presenter: component.ProcessingRequestVC, listQuickSupport: listQuickSupport)
        interactor.listener = listener
        let statusRequestBuilder = StatusRequestBuilder(dependency: component)

        // todo: Create builder modules builders and inject into router here.
        
        return ProcessingRequestRouter(interactor: interactor,
                                       viewController: component.ProcessingRequestVC,
                                       statusRequestBuildable: statusRequestBuilder)
    }
}
