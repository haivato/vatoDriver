//
//  RequestQuickSupportObjcWrapper.swift
//  FC
//
//  Created by khoi tran on 3/6/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
final class RequestQuickSupportObjcWrapper: BaseRibObjcWrapper, RequestQuickSupportDependency, RequestQuickSupportListener {
    func requestSupportMoveBack() {
        
        self.deactive()
        self.controller?.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    weak var controller: UIViewController?
    private var disposeToken: Disposable?
    private var disposeBag = DisposeBag()
    private var serviceName: String
    private var tripCode: String
    
    init(with controller: UIViewController?, serviceName: String, tripCode: String) {
        self.serviceName = serviceName
        self.tripCode = tripCode
        
        super.init()
        self.controller = controller
    }
    
    override func present() {
        #if DEBUG
        let id = "nzUbZg3SAm5NVSMoLI9g"
        #else
        let id = "iHGYJ6ByLSEVc6UUaQMS"
        #endif
        
        QuickSupportManager.shared.listQuickSupport.take(1).bind {[weak self] (data) in
            guard let wSelf = self, let model = data.first(where: { $0.id == id }) else { return }
            
            let defaultContent = "Dịch vụ: \(wSelf.serviceName)\nMã chuyến đi: \(wSelf.tripCode)\nChi tiết: "
            
            
            let builder = RequestQuickSupportBuilder(dependency: wSelf)
            let route = builder.build(withListener: wSelf, requestModel: model, defaultContent: defaultContent)
            wSelf.active(by: route)
            let referralVC = route.viewControllable.uiviewController
            let navi = FacecarNavigationViewController(rootViewController: referralVC)
            navi.modalPresentationStyle = .fullScreen
            wSelf.controller?.present(navi, animated: true, completion: nil)
        }.disposed(by: disposeBag)

    }
    
    deinit {
        printDebug("\(#function)")
    }
    
   
}
