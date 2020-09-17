//
//  CarContractObjcWrapper.swift
//  FC
//
//  Created by Phan Hai on 28/08/2020.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
final class CarContractObjcWrapper: BaseRibObjcWrapper, CarContractDependency, CarContractListener, AuthenticatedStream, ListCarContractDependency, ListCarContractListener {
    func moveBackHome() {
        self.deactive()
        self.controller?.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
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
    
    func presentVC() {
        let builder = CarContractBuilder(dependency: self)
        let route = builder.build(withListener: self)
        self.active(by: route)
        let referralVC = route.viewControllable.uiviewController
        let navi = FacecarNavigationViewController(rootViewController: referralVC)
        navi.modalPresentationStyle = .fullScreen
        self.controller?.present(navi, animated: true, completion: nil)
    }
    
    func presentListCar() {
        let builder = ListCarContractBuilder(dependency: self)
        let route = builder.build(withListener: self)
        self.active(by: route)
        let referralVC = route.viewControllable.uiviewController
        let navi = FacecarNavigationViewController(rootViewController: referralVC)
        navi.modalPresentationStyle = .fullScreen
        self.controller?.present(navi, animated: true, completion: nil)
    }
    
    deinit {
        printDebug("\(#function)")
    }
    
}
