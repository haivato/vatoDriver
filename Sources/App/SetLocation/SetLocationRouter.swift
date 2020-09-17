//  File name   : SetLocationRouter.swift
//
//  Author      : khoi tran
//  Created date: 3/4/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol SetLocationInteractable: Interactable, LocationPickerListener {
    var router: SetLocationRouting? { get set }
    var listener: SetLocationListener? { get set }
}

protocol SetLocationViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class SetLocationRouter: ViewableRouter<SetLocationInteractable, SetLocationViewControllable> {
    /// Class's constructor.
    init(interactor: SetLocationInteractable, viewController: SetLocationViewControllable, locationPickerBuilable: LocationPickerBuildable) {
        self.locationPickerBuilable = locationPickerBuilable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let locationPickerBuilable: LocationPickerBuildable
}

// MARK: SetLocationRouting's members
extension SetLocationRouter: SetLocationRouting {
    func routeToChangeLocation() {
        let route = locationPickerBuilable.build(withListener: interactor, placeModel: nil, searchType: .express(origin: true), typeLocationPicker: .full)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension SetLocationRouter {
}
