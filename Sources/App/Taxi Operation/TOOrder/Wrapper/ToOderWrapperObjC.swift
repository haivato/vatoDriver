//  File name   : ShorcurtWrapperObjC.swift
//
//  Author      : Dung Vu
//  Created date: 2/19/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxSwift

@objcMembers
final class TOOrderWrapperObjC: BaseRibObjcWrapper, TOOrderDependency, AuthenticatedStream, TOOrderListener {
    
    var authenticated: AuthenticatedStream {
        return self
    }
    
    var googleAPI: Observable<String> {
        return Observable.empty()
    }
    
    var firebaseAuthToken: Observable<String> {
        return FirebaseTokenHelper.instance.eToken.filterNil()
    }
    
    weak var controller: UIViewController?
    
    init(with controller: UIViewController) {
        self.controller = controller
        super.init()
    }
    
    override func present() {
        let builder = TOOrderBuilder(dependency: self)
        let route = builder.build(withListener: self)
        self.active(by: route)
        let ToOderVC = route.viewControllable.uiviewController
        let navi = FacecarNavigationViewController(rootViewController: ToOderVC)
        navi.modalPresentationStyle = .fullScreen
        self.controller?.present(navi, animated: true, completion: nil)
    }
    
    deinit {
        printDebug("\(#function)")
    }
    
    func TOOrderMoveBack() {
        self.deactive()
        self.controller?.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
}

