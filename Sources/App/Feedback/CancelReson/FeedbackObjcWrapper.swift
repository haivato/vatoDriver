//
//  FeedbackObjcWrapper.swift
//  FC
//
//  Created by on 1/14/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import RxSwift

enum GroupServiceType: Int {
    case booking = 1
    case express = 2
    case food = 3
    case busline = 4
    
    static func genWithServiceId(serviceId: Int) -> GroupServiceType {
        if serviceId == VatoServiceCar.rawValue ||
            serviceId == VatoServiceCarPlus.rawValue ||
            serviceId == VatoServiceCar7.rawValue ||
            serviceId == VatoServiceMoto.rawValue ||
            serviceId == VatoServiceMotoPlus.rawValue ||
            serviceId == VatoServiceFast4.rawValue ||
            serviceId == VatoServiceFast7.rawValue {
            return GroupServiceType.booking
        } else if serviceId == VatoServiceExpress.rawValue || serviceId == VatoServiceSupply.rawValue  {
            return GroupServiceType.express
        }
        return GroupServiceType.food
    }
}

@objcMembers
final class FeedbackObjcWrapper: BaseRibObjcWrapper, FeedbackCancelResonDependency, FeedbackCancelResonListener {
    
    @objc var didSelectConfirm: ((_ reason: String?, _ reasonId: Int, _ url: [URL]) -> Void)?
    
    weak var controller: UIViewController?
    private var disposeToken: Disposable?
    
    init(with controller: UIViewController?) {
        super.init()
        self.controller = controller
    }
    
    override func present() { }
    
    func presentVC(tripId: String, serviceType: Int, selector: Int, type: FeedbackCancelResonType, bookingService: FCBookingService) {
        let builder = FeedbackCancelResonBuilder(dependency: self)
        let route = builder.build(withListener: self,
                                  groupServiceType: GroupServiceType.genWithServiceId(serviceId: serviceType),
                                  tripId: tripId,
                                  selector: selector,
                                  type: type,
                                  bookingService: bookingService)
        self.active(by: route)
        let referralVC = route.viewControllable.uiviewController
        let navi = FacecarNavigationViewController(rootViewController: referralVC)
        navi.modalPresentationStyle = .fullScreen
        self.controller?.present(navi, animated: true, completion: {
            route.setupRX()
        })
    }
    
    deinit {
        printDebug("\(#function)")
    }
    
    func cancelReasonMoveBack() {
        self.deactive()
        self.controller?.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func cancelReasonSuccess(reason: String?, reasonId: Int, url: [URL]) {
        self.cancelReasonMoveBack()
        didSelectConfirm?(reason, reasonId, url)
    }
    
}

