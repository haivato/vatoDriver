//
//  WalletTripObjcWrapper.swift
//  FC
//
//  Created by MacbookPro on 5/19/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
final class WalletTripObjcWrapper: BaseRibObjcWrapper, WalletTripDependency, WalletTripListener, AuthenticatedStream {
    @objc var updateBalance: (() -> Void)?
    weak var controller: UIViewController?
    private var disposeToken: Disposable?
    
    init(with controller: UIViewController?) {
        super.init()
        self.controller = controller
    }
    var authenticated: AuthenticatedStream {
        return self
    }
    var googleAPI: Observable<String> {
        return Observable.empty()
        
    }
    var firebaseAuthToken: Observable<String> {
         return Observable.empty()
    }
    
    override func present() { }
    
    func presentVC(balance: FCBalance) {
        let builder = WalletTripBuilder(dependency: self)
        let route = builder.build(withListener: self, balance: balance)
        self.active(by: route)
        let referralVC = route.viewControllable.uiviewController
        let navi = FacecarNavigationViewController(rootViewController: referralVC)
        navi.modalPresentationStyle = .fullScreen
        self.controller?.present(navi, animated: true, completion: {
//            route.setupRX()
        })
    }
    
    deinit {
        printDebug("\(#function)")
    }
    
    func walletTripMoveBack() {
        self.deactive()
        self.controller?.presentedViewController?.dismiss(animated: true, completion: nil)
        self.updateBalance?()
    }
    
    
}
