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
final class WalletPointObjcWrapper: BaseRibObjcWrapper, WalletPointDependency, WalletPointListener, AuthenticatedStream {

    @objc var updateBalance: (() -> Void)?
    var googleAPI: Observable<String> {
        return Observable.empty()
    }
    
    var firebaseAuthToken: Observable<String> {
        return FirebaseTokenHelper.instance.eToken.filterNil()
    }
    
    var authenticated: AuthenticatedStream {
        return self
    }
    
    func gotoLinkCard() {
        
    }
    
    func gotoBuyPoint(_ list: [Any], balance: FCBalance?) {
    }

    func moveBack() {
        self.deactive()
        self.controller?.presentedViewController?.dismiss(animated: true, completion: nil)
        self.updateBalance?()
    }
    
    
    weak var controller: UIViewController?
    private var disposeToken: Disposable?
    
    init(with controller: UIViewController?) {
        super.init()
        self.controller = controller
    }
    
    override func present() {
        let builder = WalletPointBuilder(dependency: self)
        let route = builder.build(withListener: self)
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
    
    func walletReceiveBookingMoveBack() {
        self.deactive()
        self.controller?.presentedViewController?.dismiss(animated: true, completion: nil)
        self.updateBalance?()
    }
    
}
