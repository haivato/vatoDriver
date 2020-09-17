//  File name   : ProcessingRequestVC.swift
//
//  Author      : MacbookPro
//  Created date: 4/1/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol ProcessingRequestPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func processingRequeestMoveBack()
    func checkUploadImageRequest(item: UserRequestTypeFireStore, pin: String)
    func didSelectAction(action: UIImagePickerController.SourceType)
    func removePhoto(index: Int)
    func showAlert(text: String)
    var titleNameObs: Observable<String> {get}
    var listRequest: [UserRequestTypeFireStore] {get}
    var eLoadingObser: Observable<(Bool,Double)> { get }
    var imagesObser: Observable<[UIImage]> {get}
    var isCheckPin: Observable<Bool> {get}
}

final class ProcessingRequestVC: UIViewController, ProcessingRequestPresentable, ProcessingRequestViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: ProcessingRequestPresentableListener?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = self.listener?.listRequest {
            self.source = data
            vRequest.listRequest.onNext(data)
        }
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
//    private var headerView: PRHeaderView = PRHeaderView.loadXib()
    private var vRequest: PRCreateRequest = PRCreateRequest.loadXib()
    private let disposeBag = DisposeBag()
    private var source: [UserRequestTypeFireStore] = []
    private var isEdit: Bool = false
//    private var passcodeView: FCPassCodeView?
    private var isCheckPin: Bool = false
    private var passcodeView = VatoVerifyPasscodeObjC()

    var tapGesture: UITapGestureRecognizer!
    /// Class's private properties.
}

// MARK: View's event handlers
extension ProcessingRequestVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension ProcessingRequestVC {
}

// MARK: Class's private methods
private extension ProcessingRequestVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        let buttonLeft = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        buttonLeft.setImage(UIImage(named: "ic_arrow_navi_left"), for: .normal)
        buttonLeft.contentEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: buttonLeft)
        navigationItem.leftBarButtonItem = leftBarButton
        buttonLeft.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.processingRequeestMoveBack()
        }).disposed(by: disposeBag)
        title = "Yêu cầu xử lý"
        vRequest >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.bottom.top.left.right.equalToSuperview()
            }
        }
        
        tapGesture = UITapGestureRecognizer()
        
        self.tapGesture.rx.event.bind { _ in
            self.view.endEditing(true)
        }.disposed(by: disposeBag)
    }
    private func setupRX() {
        self.listener?.isCheckPin.asObservable().bind(onNext: weakify { (isCheckPin, wSelf) in
            wSelf.isCheckPin = isCheckPin
        }).disposed(by: disposeBag)
        
        listener?.eLoadingObser.bind(onNext: { (item) in
            item.0 ? LoadingManager.instance.show() : LoadingManager.instance.dismiss()
        }).disposed(by: disposeBag)
        
        self.listener?.titleNameObs.asObservable().bind(onNext: weakify { (name, wSelf) in
            wSelf.vRequest.headerView.lbHello.text = String(format: "Hello %@", name)
        }).disposed(by: disposeBag)
        
        self.vRequest.btConfirm.rx.tap.bind { _ in
            guard  let index = self.vRequest.tableView.indexPathForSelectedRow else { return }
            if self.isEdit == false {
                self.source[index.row].content = ""
            } else {
                self.source[index.row].content = self.vRequest.tvContent.text
            }
            if self.source[index.row].isPinRequired ?? false {
                self.isCheckPinValid()
            } else {
                self.listener?.checkUploadImageRequest(item: self.source[index.row], pin: "")
            }
        }.disposed(by: disposeBag)
        
        self.vRequest.tvContent.rx.didBeginEditing.bind(onNext: weakify { (wSelf) in
            wSelf.isEdit = true
            if wSelf.vRequest.tvContent.textColor == #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)  {
                return
            }
            wSelf.vRequest.tvContent.text = ""
            wSelf.vRequest.tvContent.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        }).disposed(by: disposeBag)
        
        self.vRequest.tvContent.rx.text.subscribe(onNext: weakify { (text, wSelf) in
            guard  let index = self.vRequest.tableView.indexPathForSelectedRow else { return }
            wSelf.source[index.row].content = text
        }).disposed(by: disposeBag)
        
        listener?.imagesObser.bind(onNext: weakify { (images, wSelf) in
            wSelf.vRequest.reloadData(_images: images)
        }).disposed(by: disposeBag)
        
        self.vRequest.update(title: Text.limitImage.localizedText)
        self.vRequest.reloadData(_images: [])
        self.vRequest.didSelectAdd = {
            self.showAlert()
        }
        
        self.vRequest.didSelectClear = { index in
            self.listener?.removePhoto(index: index.row)
        }
        
        self.vRequest.didSelectOpen = { photo in
            self.present(photo, animated: true, completion: nil)
        }
        
    }
    private func isCheckPinValid() {
        if self.isCheckPin {
            self.getPin()
        } else {
            self.listener?.showAlert(text: Text.needToCreatePw.localizedText)
        }
    }
    private func getPin() {
        passcodeView.passcode(on: self, type: .notVerify, forgot: { (value) in
            if let url = URL(string: "tel://\(1900667)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }) { (pin, isVerify) in
               guard let pin = pin, let index = self.vRequest.tableView.indexPathForSelectedRow else { return }
                     self.listener?.checkUploadImageRequest(item: self.source[index.row], pin: pin)
        }
    }
    
    func showAlert(){
        let alert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let btPhoto: UIAlertAction = UIAlertAction(title: Text.imageFromPhoto.localizedText, style: .default) { _ in
            self.listener?.didSelectAction(action: .photoLibrary)
        }
        let btCamera: UIAlertAction = UIAlertAction(title: Text.imageFromCamera.localizedText, style: .default) { _ in
            self.checkAuthorizeCamera {[weak self] (isAuthorize) in
                guard let self = self else { return }
                if isAuthorize {
                    self.listener?.didSelectAction(action: .camera)
                } else {
                    self.listener?.showAlert(text: Text.needToAllowCamera.localizedText)
                }
            }
            
        }
        let btCancel: UIAlertAction = UIAlertAction(title: Text.cancel.localizedText, style: .cancel, handler: nil)
        alert.addAction(btPhoto)
        alert.addAction(btCamera)
        alert.addAction(btCancel)
        self.present(alert, animated: true, completion: nil)
    }
    func checkAuthorizeCamera(completion: ((Bool) -> Void)?) {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            mainAsync(block: completion)(true)
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: mainAsync(block: completion))
        }
    }
    
}
