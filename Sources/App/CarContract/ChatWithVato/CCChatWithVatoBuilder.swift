//  File name   : CCChatWithVatoBuilder.swift
//
//  Author      : Phan Hai
//  Created date: 31/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol CCChatWithVatoDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class CCChatWithVatoComponent: Component<CCChatWithVatoDependency> {
    /// Class's public properties.
    let CCChatWithVatoVC: CCChatWithVatoVC
    
    /// Class's constructor.
    init(dependency: CCChatWithVatoDependency, CCChatWithVatoVC: CCChatWithVatoVC) {
        self.CCChatWithVatoVC = CCChatWithVatoVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol CCChatWithVatoBuildable: Buildable {
    func build(withListener listener: CCChatWithVatoListener) -> CCChatWithVatoRouting
}

final class CCChatWithVatoBuilder: Builder<CCChatWithVatoDependency>, CCChatWithVatoBuildable {
    /// Class's constructor.
    override init(dependency: CCChatWithVatoDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: CCChatWithVatoBuildable's members
    func build(withListener listener: CCChatWithVatoListener) -> CCChatWithVatoRouting {
        let vc = CCChatWithVatoVC(nibName: CCChatWithVatoVC.identifier, bundle: nil)
        let component = CCChatWithVatoComponent(dependency: dependency, CCChatWithVatoVC: vc)

        let interactor = CCChatWithVatoInteractor(presenter: component.CCChatWithVatoVC)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return CCChatWithVatoRouter(interactor: interactor, viewController: component.CCChatWithVatoVC)
    }
}
