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
final class QuickSupportDetailObjcWrapper: BaseRibObjcWrapper, QuickSupportDetailDependency, QuickSupportDetailListener {
    weak var controller: UIViewController?
    private var disposeToken: Disposable?
    
    init(with controller: UIViewController?) {
        super.init()
        self.controller = controller
    }
    
    override func present() {}
    
    func present(qsItemId: String?) {
        let builder = QuickSupportDetailBuilder(dependency: self)
        var qsItem = QuickSupportModel()
        qsItem.id = qsItemId
        let route = builder.build(withListener: self, qsItem: qsItem)
        self.active(by: route)
        let referralVC = route.viewControllable.uiviewController
        let navi = FacecarNavigationViewController(rootViewController: referralVC)
        navi.modalPresentationStyle = .fullScreen
        self.controller?.present(navi, animated: true, completion: nil)
    }
    
    deinit {
        printDebug("\(#function)")
    }
    
    func quickSupportDetailMoveBack() {
        self.deactive()
        self.controller?.presentedViewController?.dismiss(animated: true, completion: nil)
    }
}

