//  File name   : LinkingCardBuilder.swift
//
//  Author      : admin
//  Created date: 5/22/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol LinkingCardDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    
    var authenticated: AuthenticatedStream { get }
}

final class LinkingCardComponent: Component<LinkingCardDependency> {
    /// Class's public properties.
    let LinkingCardVC: LinkingCardVC
    
    /// Class's constructor.
    init(dependency: LinkingCardDependency, LinkingCardVC: LinkingCardVC) {
        self.LinkingCardVC = LinkingCardVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol LinkingCardBuildable: Buildable {
    func build(withListener listener: LinkingCardListener, listCardNapas: [PaymentCardType]) -> LinkingCardRouting
}

final class LinkingCardBuilder: Builder<LinkingCardDependency>, LinkingCardBuildable {
    /// Class's constructor.
    override init(dependency: LinkingCardDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: LinkingCardBuildable's members
    func build(withListener listener: LinkingCardListener, listCardNapas: [PaymentCardType]) -> LinkingCardRouting {
        guard let vc = UIStoryboard(name: "WalletPointVC", bundle: nil).instantiateViewController(withIdentifier: "linkcard") as? LinkingCardVC else { fatalError("Please Implement") }


        let component = LinkingCardComponent(dependency: dependency, LinkingCardVC: vc)

        let interactor = LinkingCardInteractor(presenter: component.LinkingCardVC,
                                               authenticated: component.dependency.authenticated,
                                               listCardNapas: listCardNapas)
        
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return LinkingCardRouter(interactor: interactor, viewController: component.LinkingCardVC)
    }
}
