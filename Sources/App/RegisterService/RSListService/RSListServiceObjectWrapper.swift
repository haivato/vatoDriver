//
//  ReceivePackageObjcWrapper.swift
//  FC
//
//  Created by on 1/14/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import RxSwift



@objc protocol RSListServiceWrapperProtocol: class {
    func didSelectAction()
}

@objcMembers
final class RSListServiceObjcWrapper: BaseRibObjcWrapper, RSListServiceDependency, RSListServiceListener {
    func moveToBackHome() {
        self.moveBackToManageCar()
        self.listener?.didSelectAction()
    }
    
    func moveBackToManageCar() {
        self.deactive()
        self.controller?.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func moveBackTOShortcut() {
        
    }
    
    weak var controller: UIViewController?
    weak var listener: RSListServiceWrapperProtocol?
    private var disposeToken: Disposable?
    
    init(with controller: UIViewController?) {
        super.init()
        self.controller = controller
    }
    
    override  func present() {}
    
    func moveToRSListService(car: FCUCar) {
        let builder = RSListServiceBuilder(dependency: self)
        let route = builder.build(withListener: self, listCar: nil, listService: nil, isFromManageCar: true, carManage: car )
        
        self.active(by: route)
        let vc = route.viewControllable.uiviewController
        let navi = FacecarNavigationViewController(rootViewController: vc)
        navi.modalPresentationStyle = .fullScreen
        self.controller?.present(navi, animated: true, completion: {
            //            route.setupRX()
        })
    }
    
    deinit {
        printDebug("\(#function)")
    }

}

