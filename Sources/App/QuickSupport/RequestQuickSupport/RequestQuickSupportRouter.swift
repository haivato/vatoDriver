//  File name   : RequestQuickSupportRouter.swift
//
//  Author      : vato.
//  Created date: 1/15/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol RequestQuickSupportInteractable: Interactable, QuickSupportListListener {
    var router: RequestQuickSupportRouting? { get set }
    var listener: RequestQuickSupportListener? { get set }
    
    func addPhoto(image: UIImage?)
}

protocol RequestQuickSupportViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

enum PickerImageAction {
    case image(i: UIImage?)
    case cancel
}

typealias PickerImageDelegate = (UIImagePickerControllerDelegate & UINavigationControllerDelegate)
public class PickerImageHandler: NSObject, PickerImageDelegate {
    
    lazy var events: PublishSubject<PickerImageAction> = PublishSubject()
    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        let i = info[.originalImage] as? UIImage
        self.events.onNext(.image(i: i))
    }

    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { [weak self] in
            self?.events.onNext(.cancel)
        }
    }
}

final class RequestQuickSupportRouter: ViewableRouter<RequestQuickSupportInteractable, RequestQuickSupportViewControllable> {
    private lazy var pickerImageHandler = PickerImageHandler()
    
    /// Class's constructor.
    init(interactor: RequestQuickSupportInteractable,
         viewController: RequestQuickSupportViewControllable,
         quickSupportListBuildable: QuickSupportListBuildable) {
        self.quickSupportListBuildable = quickSupportListBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
        setupRX()
    }
    
    private func setupRX() {
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
    
    private func checkAuthorizeCamera(completion: ((Bool) -> Void)?) {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            mainAsync(block: completion)(true)
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: mainAsync(block: completion))
        }
    }
    
    private func showImagePickerController() {
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
    
    /// Class's private properties.
    private let quickSupportListBuildable: QuickSupportListBuildable
}

// MARK: RequestQuickSupportRouting's members
extension RequestQuickSupportRouter: RequestQuickSupportRouting {
    
    func openPhoto() {
        let pickerVC = UIImagePickerController()
        pickerVC.delegate = pickerImageHandler
        pickerVC.sourceType = .photoLibrary
        pickerVC.modalTransitionStyle = .coverVertical
        pickerVC.modalPresentationStyle = .fullScreen
        
        self.viewController.uiviewController.present(pickerVC, animated: true, completion: nil)
    }
    
    func openCamera() {
        self.checkAuthorizeCamera {[weak self] (isAuthorize) in
            guard let self = self else { return }
            if isAuthorize {
                self.showImagePickerController()
            } else {
                AlertVC.showMessageAlert(for: self.viewController.uiviewController, title: "Lỗi", message: "Bạn cần cấp quyền mở camera để chụp hình.", actionButton1: "Đóng", actionButton2: nil)
            }
        }
    }
    
    func routeToListSupport() {
        let route = quickSupportListBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension RequestQuickSupportRouter {
}
