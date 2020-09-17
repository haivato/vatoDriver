//  File name   : FeedbackCancelResonBuilder.swift
//
//  Author      : vato.
//  Created date: 2/4/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol FeedbackCancelResonDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class FeedbackCancelResonComponent: Component<FeedbackCancelResonDependency> {
    /// Class's public properties.
    let feedbackCancelResonVC: FeedbackCancelResonVC
    
    /// Class's constructor.
    init(dependency: FeedbackCancelResonDependency, feedbackCancelResonVC: FeedbackCancelResonVC) {
        self.feedbackCancelResonVC = feedbackCancelResonVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol FeedbackCancelResonBuildable: Buildable {
    func build(withListener listener: FeedbackCancelResonListener,
               groupServiceType: GroupServiceType,
               tripId: String,
               selector: Int,
               type: FeedbackCancelResonType,
               bookingService: FCBookingService) -> FeedbackCancelResonRouting
}

final class FeedbackCancelResonBuilder: Builder<FeedbackCancelResonDependency>, FeedbackCancelResonBuildable {
    /// Class's constructor.
    override init(dependency: FeedbackCancelResonDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: FeedbackCancelResonBuildable's members
    func build(withListener listener: FeedbackCancelResonListener,
               groupServiceType: GroupServiceType,
               tripId: String,
               selector: Int,
               type: FeedbackCancelResonType,
               bookingService: FCBookingService) -> FeedbackCancelResonRouting {
        let vc = FeedbackCancelResonVC()
        let component = FeedbackCancelResonComponent(dependency: dependency, feedbackCancelResonVC: vc)

        let interactor = FeedbackCancelResonInteractor(presenter: component.feedbackCancelResonVC,
                                                       groupServiceType: groupServiceType,
                                                       tripId: tripId,
                                                       selector: selector,
                                                       type: type,
                                                       bookingService: bookingService)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return FeedbackCancelResonRouter(interactor: interactor, viewController: component.feedbackCancelResonVC)
    }
}
