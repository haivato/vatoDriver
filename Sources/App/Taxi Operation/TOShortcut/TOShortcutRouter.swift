//  File name   : TOShortcutRouter.swift
//
//  Author      : khoi tran
//  Created date: 2/17/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol TOShortcutInteractable: Interactable, QuickSupportMainListener, TOOrderListener, BUMainListener, SetLocationListener, ProcessingRequestListener, StatusRequestListener, RSListServiceListener {
    var router: TOShortcutRouting? { get set }
    var listener: TOShortcutListener? { get set }
}

protocol TOShortcutViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class TOShortcutRouter: ViewableRouter<TOShortcutInteractable, TOShortcutViewControllable> {
    /// Class's constructor.
    init(interactor: TOShortcutInteractable,
         viewController: TOShortcutViewControllable,
         quickSupportMainBuildable: QuickSupportMainBuildable,
         tOOrderBuildable: TOOrderBuildable,
         buyUniformsMainBuildable: BUMainBuildable,
         setLocationBuildable: SetLocationBuildable,
         processingRequestBuildable: ProcessingRequestBuildable,
         statusRequestBuildable: StatusRequestBuildable,
         registerServiceBuildable: RegisterServiceBuildable,
         rsListService: RSListServiceBuildable) {
        self.buyUniformsMainBuildable = buyUniformsMainBuildable
        self.setLocationBuildable = setLocationBuildable
        self.tOOrderBuildable = tOOrderBuildable
        self.quickSupportMainBuildable = quickSupportMainBuildable
        self.processingRequestBuildable = processingRequestBuildable
        self.statusRequestBuildable = statusRequestBuildable
        self.rsListService = rsListService
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let quickSupportMainBuildable: QuickSupportMainBuildable
    private let buyUniformsMainBuildable: BUMainBuildable
    private let setLocationBuildable: SetLocationBuildable
    private let tOOrderBuildable: TOOrderBuildable
    private let processingRequestBuildable: ProcessingRequestBuildable
    private let statusRequestBuildable: StatusRequestBuildable
    private let rsListService: RSListServiceBuildable
}

// MARK: TOShortcutRouting's members
extension TOShortcutRouter: TOShortcutRouting {
    
    func registerService(listCar: [CarInfo], listService: [CarInfo]) {
        let route = rsListService.build(withListener: interactor, listCar: listCar, listService: listService, isFromManageCar: false, carManage: nil)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func registerFood(typeRequest: ProcessRequestType, item: UserRequestTypeFireStore, keyFood: String?) {
        let route = statusRequestBuildable.build(withListener: interactor, item: nil, itemFood: item, keyFood: keyFood)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func processingRequest(item: RequestResponseDetail?, listQuickSupport: [UserRequestTypeFireStore], keyFood: String?) {
        if let item = item {
            let route = statusRequestBuildable.build(withListener: interactor, item: item, itemFood: nil, keyFood: keyFood)
            let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
            perform(with: segue, completion: nil)
        } else {
            let route = processingRequestBuildable.build(withListener: interactor, listQuickSupport: listQuickSupport)
            let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
                    perform(with: segue, completion: nil)
        }
    }
    func showAlertErrorNoRequest(text: String) {
        AlertVC.showMessageAlert(for: self.viewController.uiviewController, title: "Thông báo ", message: text, actionButton1: "Đóng", actionButton2: nil)
    }
    
    func routeToFavouritePlace() {
    }
    func routeToNearbyDriver() {
        
    }
    
    func routeToSetLocation() {
        let route = setLocationBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .modal(type: .coverVertical, presentStyle: .fullScreen) , needRemoveCurrent: false )
        perform(with: segue, completion: nil)
    }
    
    func routeToQuickSupport() {
        let route = quickSupportMainBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
                perform(with: segue, completion: nil)
    }
    
    func routeToBU() {
        let route = buyUniformsMainBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
                perform(with: segue, completion: nil)
    }
    
    func routeToOrder() {
        let route = tOOrderBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
                perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension TOShortcutRouter {
}
