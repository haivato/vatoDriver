//
//  ReceivePackageObjcWrapper.swift
//  FC
//
//  Created by on 1/14/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import RxSwift



@objc protocol FoodReceivePackageWrapperProtocol: class {
    func didSelectAction(action: FoodReceivePackageAction)
}

@objcMembers
final class FoodReceivePackageObjcWrapper: BaseRibObjcWrapper, FoodReceivePackageDependency, FoodReceivePackageListener {
    weak var controller: UIViewController?
    weak var listener: FoodReceivePackageWrapperProtocol?
    private var disposeToken: Disposable?
    
    init(with controller: UIViewController?) {
        super.init()
        self.controller = controller
    }
    
    override func present() {}
    
    func present(bookInfo: FCBookInfo, bookingService: FCBookingService, type: FoodReceivePackageType) {
        let builder = FoodReceivePackageBuilder(dependency: self)
        let route = builder.build(withListener: self, bookInfo: bookInfo,
                                  bookingService: bookingService,
                                  type: type)
        
        self.active(by: route)
        let vc = route.viewControllable.uiviewController
        let navi = FacecarNavigationViewController(rootViewController: vc)
        navi.modalPresentationStyle = .fullScreen
        self.controller?.present(navi, animated: true, completion: {
            route.setupRX()
        })
    }
    
    deinit {
        printDebug("\(#function)")
    }
    
    func foodReceivePackageMoveBack() {
        self.deactive()
        self.controller?.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func didSelectAction(action: FoodReceivePackageAction) {
        listener?.didSelectAction(action: action)
    }
}

