//  File name   : BUMainRouter.swift
//
//  Author      : vato.
//  Created date: 3/10/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol BUMainInteractable: Interactable, BUBookingDetailListener, BUSelectStationListener {
    var router: BUMainRouting? { get set }
    var listener: BUMainListener? { get set }
}

protocol BUMainViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class BUMainRouter: ViewableRouter<BUMainInteractable, BUMainViewControllable> {
    /// Class's constructor.
    init(interactor: BUMainInteractable,
         viewController: BUMainViewControllable,
         bookingDetailBuildable: BUBookingDetailBuildable,
         selectStationBuildable: BUSelectStationBuildable) {
        
        self.bookingDetailBuildable = bookingDetailBuildable
        self.selectStationBuildable = selectStationBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let bookingDetailBuildable: BUBookingDetailBuildable
    private let selectStationBuildable: BUSelectStationBuildable
}

// MARK: BUMainRouting's members
extension BUMainRouter: BUMainRouting {
    func routeBookingDetail() {
        let route = bookingDetailBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToListStation(_ categoryId: Int, coordinate: CLLocationCoordinate2D) {
        let route = selectStationBuildable.build(withListener: interactor, categoryId: categoryId, coordinate: coordinate)
        let segue = RibsRouting(use: route, transitionType: .modal(type: .crossDissolve, presentStyle: .overCurrentContext) , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension BUMainRouter {
}
