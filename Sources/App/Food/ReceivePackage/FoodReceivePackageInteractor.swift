//  File name   : FoodReceivePackageInteractor.swift
//
//  Author      : vato.
//  Created date: 2/17/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

@objc enum FoodReceivePackageAction: Int{
    case call
    case message
    case openCamera
    case openPhoto
    case finishStep
}

@objc enum FoodReceivePackageType: Int{
    case viewDetail
    case actionReceivePackage
}


protocol FoodReceivePackageRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func openPhoto()
    func openCamera()
    func setupRX()
}

protocol FoodReceivePackagePresentable: Presentable {
    var listener: FoodReceivePackagePresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
    func showError(eror: Error)
    func showAlert(message: String)
}

protocol FoodReceivePackageListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func foodReceivePackageMoveBack()
    func didSelectAction(action: FoodReceivePackageAction)
}

final class FoodReceivePackageInteractor: PresentableInteractor<FoodReceivePackagePresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: FoodReceivePackageRouting?
    weak var listener: FoodReceivePackageListener?

    /// Class's constructor.
    init(presenter: FoodReceivePackagePresentable,
         bookInfo: FCBookInfo,
         bookingService: FCBookingService,
         type: FoodReceivePackageType) {
        self.bookingService = bookingService
        self.type = type
        super.init(presenter: presenter)
        presenter.listener = self
        self.infoObser = bookInfo
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        self.findClient(firebaseId: infoObser?.clientFirebaseId)
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    func findClient(firebaseId: String?) {
        guard let firebaseId = firebaseId else { return }
        let node = FireBaseTable.user >>> .custom(identify: firebaseId)
        firebaseDatabase.find(by: node, type: .value) {
            $0.keepSynced(true)
            return $0
        }.map {
            try? FCUser(dictionary: $0.value as? [AnyHashable : Any])
        }.bind { [weak self](user) in
            self?.senderUser = user
        }.disposeOnDeactivate(interactor: self)
    }
    
    /// Class's private properties.
    @VariableReplay(wrappedValue: nil) private var infoObser: FCBookInfo?
    @VariableReplay(wrappedValue: nil) private var senderUser: FCUser?
    @VariableReplay private var images: [UIImage] = []
    private lazy var firebaseDatabase = Database.database().reference()
    var bookingService: FCBookingService?
    var type: FoodReceivePackageType
}

// MARK: FoodReceivePackageInteractable's members
extension FoodReceivePackageInteractor: FoodReceivePackageInteractable {
    func addPhoto(image: UIImage?) {
        guard let image = image else { return }
        images.append(image)
    }
}

// MARK: FoodReceivePackagePresentableListener's members
extension FoodReceivePackageInteractor: FoodReceivePackagePresentableListener {
    
    var imagesObser: Observable<[UIImage]> {
        return $images.asObservable()
    }
    
    func didSelectAction(action: FoodReceivePackageAction) {
        switch action {
        case .call, .message, .finishStep:
            listener?.didSelectAction(action: action)
        case .openCamera:
            router?.openCamera()
        case .openPhoto:
            router?.openPhoto()
        }
    }
    
    func removePhoto(index: Int) {
        guard index >= 0,
            index < images.count else { return }
        images.remove(at: index)
    }
    
    var user: Observable<FCUser?> {
        return $senderUser.asObservable()
    }
    
    var bookInfo: Observable<FCBookInfo?> {
        return $infoObser.asObservable()
    }
    
    func foodReceivePackageMoveBack() {
        listener?.foodReceivePackageMoveBack()
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return indicator.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    
    func uploadImage() {
        guard images.count > 0 else {
            self.presenter.showAlert(message: "Vui lòng chụp ảnh xác nhận đã lấy hàng!")
            return
        }
        UploadFoodImage
            .uploadMutiple(images: self.images, path: "received_package")
            .observeOn(MainScheduler.instance)
            .trackProgressActivity(self.indicator)
            .subscribe(onNext: { [weak self] (urls) in
                self?.updateBookingService(urls: urls)
                }, onError: { [weak self] (e) in
                    self?.presenter.showError(eror: e)
            }).disposeOnDeactivate(interactor: self)
    }
}

// MARK: Class's private methods
private extension FoodReceivePackageInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
    
    func updateBookingService(urls: [URL?]) {
        let resultURLs = urls.compactMap { url -> URL? in
            guard let url = url else { return nil }
            var component = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let queries = component?.queryItems?.filter { $0.name != "token"}
            component?.queryItems = queries
            return component?.url
        }
        LoadingManager.instance.show()
        self.bookingService?.updateBookStatus(Int(BookStatusDeliveryReceivePackageSuccess.rawValue), complete: { [weak self] (isSucess) in
            LoadingManager.instance.dismiss()
            self?.bookingService?.updateInfoReceiveImages(resultURLs.compactMap({ $0.absoluteString }))
            self?.bookingService?.updateLastestBookingInfo(self?.bookingService?.book, block: nil)
            self?.listener?.didSelectAction(action: .finishStep)
            self?.listener?.foodReceivePackageMoveBack()
        })
    }
}
