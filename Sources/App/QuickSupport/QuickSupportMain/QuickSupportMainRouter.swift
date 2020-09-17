//  File name   : QuickSupportMainRouter.swift
//
//  Author      : khoi tran
//  Created date: 1/14/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol QuickSupportMainInteractable: Interactable, RequestQuickSupportListener, QuickSupportListListener {
    var router: QuickSupportMainRouting? { get set }
    var listener: QuickSupportMainListener? { get set }
}

protocol QuickSupportMainViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class QuickSupportMainRouter: ViewableRouter<QuickSupportMainInteractable, QuickSupportMainViewControllable> {
    /// Class's constructor.
    init(interactor: QuickSupportMainInteractable,
         viewController: QuickSupportMainViewControllable,
         requestQuickSupportBuildable: RequestQuickSupportBuildable,
         quickSupportListBuildableBuildable: QuickSupportListBuildable) {

        self.quickSupportListBuildableBuildable = quickSupportListBuildableBuildable
        self.requestQuickSupportBuildable = requestQuickSupportBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let quickSupportListBuildableBuildable: QuickSupportListBuildable

    private let requestQuickSupportBuildable: RequestQuickSupportBuildable
}

// MARK: QuickSupportMainRouting's members
extension QuickSupportMainRouter: QuickSupportMainRouting {
    func routeToListQS() {
        let route = quickSupportListBuildableBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }

    func routeRequestQickSupport(requestModel: QuickSupportRequest) {
        let route = requestQuickSupportBuildable.build(withListener: interactor, requestModel: requestModel, defaultContent: nil)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
}

// MARK: Class's private methods
private extension QuickSupportMainRouter {
}
