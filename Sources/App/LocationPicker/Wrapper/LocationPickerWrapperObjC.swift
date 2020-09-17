//
//  LocationPickerWrapperObjC.swift
//  FC
//
//  Created by khoi tran on 3/24/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol LocationPickerDelegateProtocol: class {
    func didSelectAddress(model: AddressProtocol)
}

@objcMembers
final class LocationPickerWrapperObjC: BaseRibObjcWrapper, LocationPickerDependency, AuthenticatedStream, LocationPickerListener {

    typealias ShorcurtHandler = UIViewController
    
    var authenticatedStream: AuthenticatedStream {
        return self
    }
    
    var googleAPI: Observable<String> {
        return Observable.empty()
    }
    
    var firebaseAuthToken: Observable<String> {
        return FirebaseTokenHelper.instance.eToken.filterNil()
    }
    
    weak var controller: ShorcurtHandler?
    weak var delegate: LocationPickerDelegateProtocol?
    var placeModel: AddressProtocol?
    
    init(with controller: ShorcurtHandler?) {
        self.controller = controller
        super.init()
    }
    
    override func present() {
        let builder = LocationPickerBuilder(dependency: self)
        let route = builder.build(withListener: self, placeModel: self.placeModel, searchType: .none, typeLocationPicker: .full)
        self.active(by: route)
        let shortcutVC = route.viewControllable.uiviewController
        let navi = FacecarNavigationViewController(rootViewController: shortcutVC)
        navi.modalPresentationStyle = .fullScreen
        self.controller?.present(navi, animated: true, completion: nil)
    }
    
    deinit {
        printDebug("\(#function)")
    }
    
    func pickerDismiss() {
        self.deactive()
        self.controller?.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func didSelectModel(model: AddressProtocol) {
        self.deactive()
        self.controller?.presentedViewController?.dismiss(animated: true, completion: nil)
        
        if let delegate = self.delegate {
            delegate.didSelectAddress(model: model)
        }
        
    }
}
