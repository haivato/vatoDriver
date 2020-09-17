//  File name   : FeedbackCancelResonRouter.swift
//
//  Author      : vato.
//  Created date: 2/4/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol FeedbackCancelResonInteractable: Interactable {
    var router: FeedbackCancelResonRouting? { get set }
    var listener: FeedbackCancelResonListener? { get set }
    
    func addPhoto(image: UIImage?)
}

protocol FeedbackCancelResonViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class FeedbackCancelResonRouter: ViewableRouter<FeedbackCancelResonInteractable, FeedbackCancelResonViewControllable> {
    /// Class's constructor.
    override init(interactor: FeedbackCancelResonInteractable, viewController: FeedbackCancelResonViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
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
    
    /// Class's private properties.
    private lazy var pickerImageHandler = PickerImageHandler()
}

// MARK: FeedbackCancelResonRouting's members
extension FeedbackCancelResonRouter: FeedbackCancelResonRouting {
    func openPhoto() {
        let pickerVC = UIImagePickerController()
        pickerVC.delegate = pickerImageHandler
        pickerVC.sourceType = .photoLibrary
        pickerVC.modalTransitionStyle = .coverVertical
        pickerVC.modalPresentationStyle = .fullScreen
        
        self.viewController.uiviewController.present(pickerVC, animated: true, completion: nil)
    }
    
    func openCamera() {
        checkAuthorizeCamera {[weak self] (isAuthorize) in
            guard let self = self else { return }
            if isAuthorize {
                self.showImagePickerController()
            } else {
                AlertVC.showMessageAlert(for: self.viewController.uiviewController, title: "Lỗi", message: "Bạn cần cấp quyền mở camera để chụp hình.", actionButton1: "Đóng", actionButton2: nil)
            }
        }
    }
}

// MARK: Class's private methods
private extension FeedbackCancelResonRouter {
    
    func checkAuthorizeCamera(completion: ((Bool) -> Void)?) {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            mainAsync(block: completion)(true)
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: mainAsync(block: completion))
        }
    }
    
    func showImagePickerController() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = pickerImageHandler
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.viewController.uiviewController.present(imagePicker, animated: true, completion: nil)
        } else {
            AlertVC.showMessageAlert(for: self.viewController.uiviewController, title: "Lỗi", message: "Không thể mở camera", actionButton1: "Đóng", actionButton2: nil)
        }
    }
}
