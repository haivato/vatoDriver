//  File name   : TOOrderRouter.swift
//
//  Author      : Dung Vu
//  Created date: 2/19/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol TOOrderInteractable: Interactable, TODetailLocationListener {
    var router: TOOrderRouting? { get set }
    var listener: TOOrderListener? { get set }
}

protocol TOOrderViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class TOOrderRouter: ViewableRouter<TOOrderInteractable, TOOrderViewControllable> {
    /// Class's constructor.
    init(interactor: TOOrderInteractable, viewController: TOOrderViewControllable, tODetailLocationBuildable: TODetailLocationBuildable) {
        self.tODetailLocationBuildable = tODetailLocationBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let tODetailLocationBuildable: TODetailLocationBuildable
}

// MARK: TOOrderRouting's members
extension TOOrderRouter: TOOrderRouting {
    func routeToLocation(pickUpStationId: Int?, firestore_listener_path: String?) {
        let route = tODetailLocationBuildable.build(withListener: interactor, pickUpStationId: pickUpStationId, firestore_listener_path: firestore_listener_path)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension TOOrderRouter {
}
