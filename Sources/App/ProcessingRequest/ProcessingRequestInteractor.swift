//  File name   : ProcessingRequestInteractor.swift
//
//  Author      : MacbookPro
//  Created date: 4/1/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import CoreLocation
import RxCocoa
import FwiCore
import FwiCoreRX
import VatoNetwork
import Alamofire

protocol ProcessingRequestRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
//    func moveToStatusRequest()
    func showLibrary(action: UIImagePickerController.SourceType)
    func moveToStatusRequest()
    func showAlertError(messageError: String)
}

protocol ProcessingRequestPresentable: Presentable {
    var listener: ProcessingRequestPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol ProcessingRequestListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func processingRequeestMoveBack()
}

final class ProcessingRequestInteractor: PresentableInteractor<ProcessingRequestPresentable>, ActivityTrackingProgressProtocol {
    
    /// Class's public properties.
    weak var router: ProcessingRequestRouting?
    weak var listener: ProcessingRequestListener?
    private var listQuickSupport: [UserRequestTypeFireStore]
    /// Class's constructor.
    init(presenter: ProcessingRequestPresentable, listQuickSupport: [UserRequestTypeFireStore]) {
        self.listQuickSupport = listQuickSupport
        super.init(presenter: presenter)
        presenter.listener = self
    }
    @Replay(queue: MainScheduler.asyncInstance) private var mDisplayName: String
    private lazy var network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
    @Replay(queue: MainScheduler.asyncInstance) private var mIsCheckPin: Bool
    private let disposeBag = DisposeBag()
    private var zoneID: String?
    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    @VariableReplay private var images: [UIImage] = []

    /// Class's private properties.
}

// MARK: ProcessingRequestInteractable's members
extension ProcessingRequestInteractor: ProcessingRequestInteractable {
    func addPhoto(image: UIImage?) {
        guard let image = image else { return }
        images.append(image)
    }
    
    func statusRequesttMoveBack() {
        self.listener?.processingRequeestMoveBack()
    }
}

// MARK: ProcessingRequestPresentableListener's members
extension ProcessingRequestInteractor: ProcessingRequestPresentableListener {
    
    var isCheckPin: Observable<Bool> {
        return $mIsCheckPin.asObservable()
        
    }
    
    func showAlert(text: String) {
        self.router?.showAlertError(messageError: text)
    }
    
    func didSelectAction(action: UIImagePickerController.SourceType) {
        self.router?.showLibrary(action: action)
    }

    
    func removePhoto(index: Int) {
        guard index >= 0,
            index < images.count else { return }
        images.remove(at: index)
    }
    
    var imagesObser: Observable<[UIImage]> {
        return $images.asObservable()
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return self.indicator.asObservable()
    }
    
    func createRequestProcess(item: UserRequestTypeFireStore, images: [String], pin: String) {
        guard let id = item.id, let content = item.content else { return }
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let zoneID = self.zoneID ?? ""
        let p: [String : Any] = ["request_type_id": id,
                 "content": content,
                 "zone_id": zoneID,
                 "app_version": appVersion,
                 "images": images,
                 "pin": pin
        ]
        let url = TOManageCommunication.path("/support/requests")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: p, useFullPath: true)
        network.request(using: router,
                                      decodeTo: OptionalMessageDTO<RequestResponseDetail>.self,
                                      method: .post,
                                      encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                switch result {
                case .success(let d):
                    if d.fail == false {
                        self?.router?.moveToStatusRequest()
                    } else {
                        self?.router?.showAlertError(messageError: d.message ?? "")
                    }
                case .failure(let e):
                    self?.router?.showAlertError(messageError: e.localizedDescription)
                }
                LoadingManager.instance.dismiss()
        }.disposeOnDeactivate(interactor: self)
    }
    func checkUploadImageRequest(item: UserRequestTypeFireStore, pin: String) {
        LoadingManager.instance.show()
        guard images.count > 0 else {
            self.createRequestProcess(item: item, images: [], pin: pin)
            return
        }
        FirebaseUploadImage.upload(images, withPath: "approvals") {[weak self] (urls, error) in
            DispatchQueue.main.async {
                if error != nil,
                    let _error = error as NSError? {
                    // show error
                    self?.router?.showAlertError(messageError: _error.localizedDescription)
                } else {
                    let resultURLs = urls.compactMap { url -> URL? in
                        var component = URLComponents(url: url, resolvingAgainstBaseURL: false)
                        let queries = component?.queryItems?.filter { $0.name != "token"}
                        component?.queryItems = queries
                        return component?.url
                    }
                    self?.createRequestProcess(item: item, images: resultURLs.compactMap { $0.absoluteString }, pin: pin)
                }
                LoadingManager.instance.dismiss()
            }
        }

    }
    
    private func checkPin() {
           let url = TOManageCommunication.path("/api/user/check_pin")
           let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true)
           network.request(using: router,
                                         decodeTo: OptionalMessageDTO<Bool>.self,
                                         method: .get,
                                         encoding: JSONEncoding.default)
               .trackProgressActivity(self.indicator)
               .bind { [weak self](result) in
                   switch result {
                   case .success(let d):
                    guard let d = d.data else {
                        return
                    }
                    self?.mIsCheckPin = d
                   case .failure(let e):
                       self?.router?.showAlertError(messageError: e.localizedDescription)
                   }
           }.disposeOnDeactivate(interactor: self)
       }
    
    var listRequest: [UserRequestTypeFireStore] {
        return self.listQuickSupport
    }
    
    var titleNameObs: Observable<String> {
        return $mDisplayName
    }
    
    func processingRequeestMoveBack() {
        self.listener?.processingRequeestMoveBack()
    }
    
}

// MARK: Class's private methods
private extension ProcessingRequestInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
        self.getLatestLocation()
        self.checkPin()
    }
    private func getLatestLocation() {
        let d = UserManager.shared.getCurrentUser()?.user?.nickname
        let f = UserManager.shared.getCurrentUser()?.user?.fullName
        if let zoneID = UserManager.shared.getCurrentUser()?.zoneId {
            self.zoneID = String(zoneID)
        }
        let displayName = d?.orEmpty(f ?? "")
        self.mDisplayName = displayName ?? ""
        
    }
}
