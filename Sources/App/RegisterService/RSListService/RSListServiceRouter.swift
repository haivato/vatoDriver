//  File name   : RSListServiceRouter.swift
//
//  Author      : MacbookPro
//  Created date: 4/27/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import FwiCore
import GoogleMaps
import RIBs
import RxSwift
import SnapKit
import Firebase
import Kingfisher
import FwiCoreRX

protocol RSListServiceInteractable: Interactable, RegisterServiceListener, RSPolicyListener {
    var router: RSListServiceRouting? { get set }
    var listener: RSListServiceListener? { get set }
}

protocol RSListServiceViewControllable: ViewControllable, ControllableProtocol {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class RSListServiceRouter: ViewableRouter<RSListServiceInteractable, RSListServiceViewControllable>, RibsAccessControllableProtocol {
    /// Class's constructor.
    init(interactor: RSListServiceInteractable,
         viewController: RSListServiceViewControllable,
         registerServiceBuildable: RegisterServiceBuildable,
         rsPolicyBuildable: RSPolicyBuildable) {
        self.mViewController = viewController
        self.registerServiceBuildable = registerServiceBuildable
        self.rsPolicyBuildable = rsPolicyBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    private let registerServiceBuildable: RegisterServiceBuildable
    private weak var currentRouting: ViewableRouting?
    private let mViewController: RSListServiceViewControllable
    private let rsPolicyBuildable: RSPolicyBuildable
    /// Class's private properties.
}

// MARK: RSListServiceRouting's members
extension RSListServiceRouter: RSListServiceRouting {
    
    func showAlerError(text: String) {
        AlertVC.showMessageAlert(for: self.viewController.uiviewController, title: "Thông báo ", message: text, actionButton1: "Đóng", actionButton2: nil)
    }
    
    
    
    func moveToPolicy(array: [ListServiceVehicel], strHtml: String, itemCar: Int64, isFromManage: Bool) {
        let route = rsPolicyBuildable.build(withListener: interactor, array: array, strHtml: strHtml, itemCarId: itemCar, isFromManage: isFromManage)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func registerService(type: RegisterServiceType, listCar: [CarInfo]) {
        detactCurrentChild()
        let route = registerServiceBuildable.build(withListener: self.interactor, type: type, listCar: listCar)
        self.attach(route: route, using: TransitonType.modal(type: .crossDissolve, presentStyle: .overCurrentContext))
    }
    
    private func attach(route: ViewableRouting, using transition: TransitonType) {
        defer { self.currentRouting = route }
        self.attachChild(route)
        self.mViewController.present(viewController: route.viewControllable, transitionType: transition, completion: nil)
    }
    
    func detactCurrentChild() {
        guard let currentRouting = currentRouting else {
            return
        }
        detachChild(currentRouting)
        mViewController.dismiss(viewController: currentRouting.viewControllable, completion: nil)
    }
    
    
}

// MARK: Class's private methods
private extension RSListServiceRouter {
}
