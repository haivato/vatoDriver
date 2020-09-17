//  File name   : LocationPickerRouter.swift
//
//  Author      : khoi tran
//  Created date: 11/13/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol LocationPickerInteractable: Interactable, PinAddressListener {
    var router: LocationPickerRouting? { get set }
    var listener: LocationPickerListener? { get set }
}

protocol LocationPickerViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class LocationPickerRouter: ViewableRouter<LocationPickerInteractable, LocationPickerViewControllable> {
    /// Class's constructor.
    init(interactor: LocationPickerInteractable, viewController: LocationPickerViewControllable, pinAddressBuildable: PinAddressBuildable) {
        self.pinAddressBuildable = pinAddressBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let pinAddressBuildable: PinAddressBuildable

}

// MARK: LocationPickerRouting's members
extension LocationPickerRouter: LocationPickerRouting {
    func moveToPin(defautPlace: AddressProtocol?, isOrigin: Bool) {
        let router = pinAddressBuildable.build(withListener: self.interactor, defautPlace: defautPlace, isOrigin: isOrigin)
        let segue = RibsRouting(use: router, transitionType: .push, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension LocationPickerRouter {
}
