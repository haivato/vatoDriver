//  File name   : ProcessingRequestRouter.swift
//
//  Author      : MacbookPro
//  Created date: 4/1/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol ProcessingRequestInteractable: Interactable, StatusRequestListener {
    var router: ProcessingRequestRouting? { get set }
    var listener: ProcessingRequestListener? { get set }
    func addPhoto(image: UIImage?)
}

protocol ProcessingRequestViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ProcessingRequestRouter: ViewableRouter<ProcessingRequestInteractable, ProcessingRequestViewControllable> {
    /// Class's constructor.
    init(interactor: ProcessingRequestInteractable,
                  viewController: ProcessingRequestViewControllable,
                  statusRequestBuildable: StatusRequestBuildable ) {
        self.statusRequestBuildable = statusRequestBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
        setupRX()
    }
    private var statusRequestBuildable: StatusRequestBuildable
    private lazy var pickerImageHandler = PickerImageHandler()
    /// Class's private properties.
    func setupRX() {
        guard let i = interactor as? Interactor else { return }
        pickerImageHandler.events.debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance).bind { [weak self](type) in
            guard let wSelf = self else { return}
            switch type {
            case .image(let i):
                wSelf.interactor.addPhoto(image: i?.resize())
            case .cancel:
                break
            }
        }.disposeOnDeactivate(interactor: i)
    }
}

// MARK: ProcessingRequestRouting's members
extension ProcessingRequestRouter: ProcessingRequestRouting {
    func showLibrary(action: UIImagePickerController.SourceType) {
        let pickerVC = UIImagePickerController()
        pickerVC.delegate = pickerImageHandler
        pickerVC.sourceType = action
        pickerVC.modalTransitionStyle = .coverVertical
        pickerVC.modalPresentationStyle = .fullScreen
        
        self.viewController.uiviewController.present(pickerVC, animated: true, completion: nil)
    }
    func moveToStatusRequest() {
        let route = statusRequestBuildable.build(withListener: interactor, item: nil, itemFood: nil, keyFood: nil)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    func showAlertError(messageError: String) {
        AlertVC.showMessageAlert(for: self.viewController.uiviewController, title: "Thông báo ", message: messageError, actionButton1: "Đóng", actionButton2: nil)
    }
    
    
}

// MARK: Class's private methods
private extension ProcessingRequestRouter {
    
}
