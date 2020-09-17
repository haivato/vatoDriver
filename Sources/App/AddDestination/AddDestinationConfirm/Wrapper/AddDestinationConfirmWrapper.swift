//
//  AddDestinationWrapper.swift
//  FC
//
//  Created by khoi tran on 3/24/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol AddDestinationConfirmWrapperDelegate: class {
    func addDestinationSuccess(points: [DestinationPoint], newPrice: AddDestinationNewPrice)
}

final class AddDestinationConfirmWrapper: BaseRibObjcWrapper, AddDestinationConfirmDependency, AuthenticatedStream, AddDestinationConfirmListener {

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
    var placeModel: AddressProtocol?
    weak var delegate: AddDestinationConfirmWrapperDelegate?
    
    init(with controller: ShorcurtHandler?) {
        self.controller = controller
        super.init()
    }
    
    override func present() {
        
    }
    
    func present(type: AddDestinationType, tripId: String) {
        let builder = AddDestinationConfirmBuilder(dependency: self)
        let route = builder.build(withListener: self, type: type, tripId: tripId)
        self.active(by: route)
        let shortcutVC = route.viewControllable.uiviewController
        let navi = FacecarNavigationViewController(rootViewController: shortcutVC)
        navi.modalPresentationStyle = .fullScreen
        self.controller?.present(navi, animated: true, completion: nil)
    }
    
    deinit {
        printDebug("\(#function)")
    }
        
    func dismissAddDestination() {
        self.deactive()
        self.controller?.dismiss(animated: true, completion: nil)
    }
   
    
    func addDestinationSuccess(points: [DestinationPoint], newPrice: AddDestinationNewPrice) {
        self.deactive()
        self.controller?.dismiss(animated: true, completion: nil)
        
        if let delegate = self.delegate {
            delegate.addDestinationSuccess(points: points, newPrice: newPrice)
        }
    }
}
