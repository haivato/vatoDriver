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

@objc
protocol ShortcutDelegateProtocol: NSObjectProtocol {
    func showTripDigital()
    func loadCreateCar()
    func loadFavPlace()
}

@objcMembers
final class ShorcurtWrapperObjC: BaseRibObjcWrapper, TOShortcutDependency, AuthenticatedStream, TOShortcutListener {
    typealias ShorcurtHandler = UIViewController & ShortcutDelegateProtocol
    var authenticated: AuthenticatedStream {
        return self
    }
    
    var googleAPI: Observable<String> {
        return Observable.empty()
    }
    
    var firebaseAuthToken: Observable<String> {
        return FirebaseTokenHelper.instance.eToken.filterNil()
    }
    
    weak var controller: ShorcurtHandler?
    
    init(with controller: ShorcurtHandler?) {
        self.controller = controller
        super.init()
    }
    
    override func present() {
        let builder = TOShortcutBuilder(dependency: self)
        let route = builder.build(withListener: self)
        self.active(by: route)
        let shortcutVC = route.viewControllable.uiviewController
        let navi = FacecarNavigationViewController(rootViewController: shortcutVC)
        navi.modalPresentationStyle = .fullScreen
        self.controller?.present(navi, animated: true, completion: nil)
    }
    
    deinit {
        printDebug("\(#function)")
    }
    
    func TOShortcutListenerMoveBack() {
        self.deactive()
        self.controller?.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func showTripDigital() {
        self.controller?.presentedViewController?.dismiss(animated: true, completion: { [weak self] in
            self?.controller?.showTripDigital()
        })
    }
    
    func loadCreateCar() {
        self.controller?.presentedViewController?.dismiss(animated: true, completion: { [weak self] in
            self?.controller?.loadCreateCar()
        })
    }
    func showFavouritePlace() {
        self.deactive()
        self.controller?.presentedViewController?.dismiss(animated: true, completion: {  [weak self] in
            self?.controller?.loadFavPlace()
        })
    }
}

