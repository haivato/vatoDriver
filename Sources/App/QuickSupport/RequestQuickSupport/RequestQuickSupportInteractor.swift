//  File name   : RequestQuickSupportInteractor.swift
//
//  Author      : vato.
//  Created date: 1/15/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Alamofire

struct RequestModel {
    var title: String?
    var content: String?
    var arrImageUrl: [String] = []
}

protocol RequestQuickSupportRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func openPhoto()
    func openCamera()
    func routeToListSupport()
}

protocol RequestQuickSupportPresentable: Presentable {
    var listener: RequestQuickSupportPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
    func showError(eror: Error)
    func showAlertSuccess()
    func showAlertFail(message: String)
}

protocol RequestQuickSupportListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func requestSupportMoveBack()
}

final class RequestQuickSupportInteractor: PresentableInteractor<RequestQuickSupportPresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: RequestQuickSupportRouting?
    weak var listener: RequestQuickSupportListener?

    /// Class's constructor.
    init(presenter: RequestQuickSupportPresentable,
         requestModel: QuickSupportRequest,
         defaultContent: String?) {
        self.defaultContent = defaultContent
        self.requestModel = requestModel
        super.init(presenter: presenter)
        presenter.listener = self
    }

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

    /// Class's private properties.
    @VariableReplay private var images: [UIImage] = []
    internal let requestModel: QuickSupportRequest
    internal var inputModel: RequestModel = RequestModel()
    internal let defaultContent: String?

}

// MARK: RequestQuickSupportInteractable's members
extension RequestQuickSupportInteractor: RequestQuickSupportInteractable {
    func quickSupportListMoveBack() {
        listener?.requestSupportMoveBack()
    }
    
    func addPhoto(image: UIImage?) {
        guard let image = image else { return }
        images.append(image)
    }
}

// MARK: RequestQuickSupportPresentableListener's members
extension RequestQuickSupportInteractor: RequestQuickSupportPresentableListener {
    
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return indicator.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    
    func routeToListSupport() {
        router?.routeToListSupport()
    }
    
    func submit() {
        guard self.images.isEmpty == false else {
            requestAPI()
            return
        }
        LoadingManager.instance.show()
        FirebaseUploadImage.upload(self.images, withPath: "supports") {[weak self] (urls, error) in
            DispatchQueue.main.async {
                if let _error = error as NSError? {
                    self?.presenter.showError(eror: _error)
                } else {
                    self?.inputModel.arrImageUrl = urls.compactMap { $0.absoluteString }
                    self?.requestAPI()
                }
                LoadingManager.instance.dismiss()
            }
        }
        
    }
    
    func requestAPI() {
        guard let user = UserManager.shared.getCurrentUser() else { return }
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let coor = UserManager.shared.getCurrentLocation()
        let avatar = user.user.avatarUrl.isEmpty ? defautAvatar : user.user.avatarUrl
        let fullName = user.user.fullName.isEmpty ? user.user.nickname : user.user.fullName
        
        let userParam = [
            "avatarUrl": avatar ?? defautAvatar ,
            "fullName": fullName ?? "User",
            "phone": user.user.phone,
            "id": user.user.id
            ] as [String : Any]
        
        let param = [
            "appVersion": "\(appVersion)I",
            "content": inputModel.content ?? "",
            "images": inputModel.arrImageUrl,
            "lat": coor.latitude,
            "lon": coor.longitude,
            "supportCategoryId": requestModel.id ?? "",
            "title": inputModel.title ?? "",
            "userType": UserType.driver.rawValue,
            "user": userParam,
            "zoneId": user.zoneId
            ] as [String : Any]
        
        FirebaseTokenHelper
            .instance
            .eToken
            .filterNil()
            .take(1)
            .flatMap { Requester.responseDTO(decodeTo: OptionalMessageDTO<Data>.self,
                                             using: VatoAPIRouter.createSupport(token: $0, params: param),
                                             method: .post,
                                             encoding: JSONEncoding.default) }
            .observeOn(MainScheduler.asyncInstance)
            .trackProgressActivity(self.indicator)
            .subscribe(onNext: { [weak self] (r) in
                if r.response.fail == true {
                    self?.presenter.showAlertFail(message: r.response.message ?? "")
                } else {
                    self?.presenter.showAlertSuccess()
                }
                }, onError: { [weak self] (e) in
                    self?.presenter.showError(eror: e)
            }).disposeOnDeactivate(interactor: self)
    }
    
    func requestSupportMoveBack() {
        listener?.requestSupportMoveBack()
    }
    
    
    func removePhoto(index: Int) {
        guard index >= 0,
            index < images.count else { return }
        images.remove(at: index)
    }
    
    var imagesObser: Observable<[UIImage]> {
        return $images.asObservable()
    }
    
    func openPhoto() {
        router?.openPhoto()
    }
    
    func openCamera() {
        router?.openCamera()
    }
}

// MARK: Class's private methods
private extension RequestQuickSupportInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
