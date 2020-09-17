//  File name   : QuickSupportListRouter.swift
//
//  Author      : khoi tran
//  Created date: 1/15/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol QuickSupportListInteractable: Interactable, QuickSupportDetailListener {
    var router: QuickSupportListRouting? { get set }
    var listener: QuickSupportListListener? { get set }
}

protocol QuickSupportListViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class QuickSupportListRouter: ViewableRouter<QuickSupportListInteractable, QuickSupportListViewControllable> {
    /// Class's constructor.
    init(interactor: QuickSupportListInteractable, viewController: QuickSupportListViewControllable, quickSupportDetailBuildable: QuickSupportDetailBuildable) {
        self.quickSupportDetailBuildable = quickSupportDetailBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let quickSupportDetailBuildable: QuickSupportDetailBuildable

}

// MARK: QuickSupportListRouting's members
extension QuickSupportListRouter: QuickSupportListRouting {
    func routeToQuickSupportDetail(model: QuickSupportModel) {
        let route = quickSupportDetailBuildable.build(withListener: interactor, qsItem: model)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension QuickSupportListRouter {
}
