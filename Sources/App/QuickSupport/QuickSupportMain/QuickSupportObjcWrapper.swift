//
//  QuickSupportObjcWrapper.swift
//  FC
//
//  Created by khoi tran on 1/14/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
final class QuickSupportObjcWrapper: BaseRibObjcWrapper, QuickSupportMainDependency, QuickSupportMainListener {
    weak var controller: UIViewController?
    private var disposeToken: Disposable?
    
    init(with controller: UIViewController?) {
        super.init()
        self.controller = controller
    }
    
    override func present() {
        
        let builder = QuickSupportMainBuilder(dependency: self)
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
    
    func quickSupportMoveBack() {
        self.deactive()
        self.controller?.presentedViewController?.dismiss(animated: true, completion: nil)
    }
}

