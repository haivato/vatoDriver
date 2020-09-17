//  File name   : ReferralObjcWrapper.swift
//
//  Author      : Dung Vu
//  Created date: 1/7/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import RIBs
import FwiCoreRX

@objcMembers
final class ReferralObjcWrapper: BaseRibObjcWrapper, ReferralDependency, AuthenticatedStream, ReferralListener {
    var googleAPI: Observable<String> {
        return Observable.empty()
    }
    
    var firebaseAuthToken: Observable<String> {
        return FirebaseTokenHelper.instance.eToken.filterNil()
    }
    
    var authenticatedStream: AuthenticatedStream {
        return self
    }
    
    weak var controller: UIViewController?
    private var disposeToken: Disposable?
    
    init(with controller: UIViewController?) {
        super.init()
        self.controller = controller
    }
    
    override func present() {
        let builder = ReferralBuilder(dependency: self)
        let route = builder.build(withListener: self)
        self.active(by: route)
        let referralVC = route.viewControllable.uiviewController
        let navi = FacecarNavigationViewController(rootViewController: referralVC)
        navi.modalPresentationStyle = .fullScreen
        self.controller?.present(navi, animated: true, completion: nil)
    }
    
    func referralMoveback() {
        self.deactive()
        self.controller?.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        printDebug("\(#function)")
    }
}

// MARK: Class's public methods
extension ReferralObjcWrapper {
}

