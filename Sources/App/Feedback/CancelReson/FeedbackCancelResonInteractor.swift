//  File name   : FeedbackCancelResonInteractor.swift
//
//  Author      : vato.
//  Created date: 2/4/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Alamofire
import FirebaseFirestore
@objc enum FeedbackCancelResonType: Int{
    case cancelTrip
    case cancelDeliveryFood
    case deliveryFoodFail
    case deliveryShopFail
    
    var showPhotos: Bool {
        return self == .deliveryFoodFail || self == .deliveryShopFail
    }
    
    func title() -> String {
        switch self {
        case .cancelTrip:
            return "Lý do huỷ chuyến đi này của bạn là gì?"
        case .cancelDeliveryFood:
            return "Lý do huỷ chuyến đi này của bạn là gì?"
        case .deliveryFoodFail, .deliveryShopFail:
            return "Lý do giao hàng thất bại"
        }
    }
    
    func backgroundColor() -> UIColor {
        switch self {
        case .cancelTrip:
            return #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
        case .deliveryFoodFail:
            return .white
        case .cancelDeliveryFood, .deliveryShopFail:
            return .white
        }
    }
    
    func titleCancel() -> String {
        switch self {
        case .cancelTrip, .cancelDeliveryFood:
            return "Huỷ chuyến đi"
        case .deliveryFoodFail, .deliveryShopFail:
            return "Giao hàng thất bại"
        }
    }
}

@objc enum FeedbackCancelAction: Int{
    case openCamera
    case openPhoto
    case removeImage
    case finishStep
}

struct CancelModel: Codable {
    var description: String?
    var extensionName: String?
    var id: Int?
    var serviceId: Int?
    var active: Bool?
    
    static func otherReason() -> CancelModel {
        return CancelModel(description: "Lý do khác", id: -1, serviceId: 0)
    }
}


protocol FeedbackCancelResonRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func openPhoto()
    func openCamera()
    func setupRX() 
}

protocol FeedbackCancelResonPresentable: Presentable {
    var listener: FeedbackCancelResonPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
    func showError(eror: Error)
    func showAlert(message: String)
}

protocol FeedbackCancelResonListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func cancelReasonMoveBack()
    func cancelReasonSuccess(reason: String?, reasonId: Int, url: [URL])
}

final class FeedbackCancelResonInteractor: PresentableInteractor<FeedbackCancelResonPresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: FeedbackCancelResonRouting?
    weak var listener: FeedbackCancelResonListener?

    /// Class's constructor.
    init(presenter: FeedbackCancelResonPresentable,
         groupServiceType: GroupServiceType,
         tripId: String,
         selector: Int,
         type: FeedbackCancelResonType,
         bookingService: FCBookingService) {
        self.type = type
        self.groupServiceType = groupServiceType
        self.tripId = tripId
        self.selector = selector
        self.bookingService = bookingService
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        
        switch self.type {
        case .cancelTrip, .deliveryShopFail:
            requestListReason()
        case .deliveryFoodFail:
            requestListDeliveryFoodFail()
        case .cancelDeliveryFood:
            requestListCancelDeliveryFood()
        }
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    func requestListReason() {
        FirebaseTokenHelper
            .instance
            .eToken
            .filterNil()
            .take(1)
            .flatMap { Requester.responseDTO(decodeTo: OptionalMessageDTO<[CancelModel]>.self,
                                             using: VatoAPIRouter.getMasterConfigs(authToken: $0, groupServiceId: self.groupServiceType.rawValue, type: "CancellationReasons", app: "Driver")) }
            .observeOn(MainScheduler.asyncInstance)
            .trackProgressActivity(self.indicator)
            .subscribe(onNext: { [weak self] (r) in
                guard let data = r.response.data else { return }
                self?.sortOtherReason(data: data)
            }, onError: { [weak self] (e) in
                self?.models = [CancelModel.otherReason()]
            }).disposeOnDeactivate(interactor: self)
        
    }
    
    func requestListDeliveryFoodFail() {
        let collectionRef = Firestore.firestore().collection(collection: .foodConfig, .delivery, .cancellationReasons)
        let query = collectionRef.whereField("type", isEqualTo: 2)
        query
            .getDocuments()
            .trackProgressActivity(self.indicator)
            .subscribe(onNext: { [weak self] (d) in
                let values = d?.compactMap { try? $0.decode(to: CancelModel.self) }
                self?.sortOtherReason(data: values ?? [])
            }, onError: { [weak self] (e) in
                self?.models = [CancelModel.otherReason()]
            }).disposeOnDeactivate(interactor: self)
    }
    func sortOtherReason(data: [CancelModel]) {
        var cancelItem: CancelModel?
        for item in data {
            if item.id != -1 {
                self.models.append(item)
            } else {
                cancelItem = item
            }
        }
        if let cancel = cancelItem {
            self.models.append(cancel)
        }
    }
    func getConfigOtherReson() {
        let collectionRef = Firestore.firestore().collection(collection: .configData, .driver, .cancellationReasons)
        let query = collectionRef.whereField("id", isEqualTo: -1)
        query
            .getDocuments()
            .trackProgressActivity(self.indicator)
            .subscribe(onNext: { [weak self] (d) in
                guard (d?.compactMap({ try? $0.decode(to: CancelModel.self) }).first) != nil else {
                    return
                }
                self?.models.append(CancelModel.otherReason())
            }, onError: { [weak self] (e) in
                self?.models = [CancelModel.otherReason()]
            }).disposeOnDeactivate(interactor: self)
    }
    func requestListCancelDeliveryFood() {
         FirebaseTokenHelper
             .instance
             .eToken
             .filterNil()
             .take(1)
             .flatMap { Requester.responseDTO(decodeTo: OptionalMessageDTO<[CancelModel]>.self,
                                              using: VatoAPIRouter.getMasterConfigs(authToken: $0, groupServiceId: self.groupServiceType.rawValue, type: "CancellationReasons", app: "Driver")) }
             .observeOn(MainScheduler.asyncInstance)
             .trackProgressActivity(self.indicator)
             .subscribe(onNext: { [weak self] (r) in
//                 self?.models = r.response.data ?? []
//                self?.getConfigOtherReson()
                self?.sortOtherReason(data: r.response.data ?? [])
             }, onError: { [weak self] (e) in
                 self?.models = [CancelModel.otherReason()]
             }).disposeOnDeactivate(interactor: self)
         
     }
    
    /// Class's private properties.
    @VariableReplay private var models: [CancelModel] = []
    let groupServiceType: GroupServiceType
    internal let tripId: String
    internal var otherReason: String?
    private let selector: Int
    internal let type: FeedbackCancelResonType
    @VariableReplay private var images: [UIImage] = []
    var bookingService: FCBookingService?
}

// MARK: FeedbackCancelResonInteractable's members
extension FeedbackCancelResonInteractor: FeedbackCancelResonInteractable {
    func addPhoto(image: UIImage?) {
        guard let image = image else { return }
        images.append(image)
    }
}

// MARK: FeedbackCancelResonPresentableListener's members
extension FeedbackCancelResonInteractor: FeedbackCancelResonPresentableListener {
   func removePhoto(index: Int) {
        guard index >= 0,
            index < images.count else { return }
        images.remove(at: index)
    }
    
    func didSelectAction(action: FeedbackCancelAction) {
        switch action {
        case .finishStep:
//            listener?.didSelectAction(action: action)
            break
        case .openCamera:
            router?.openCamera()
        case .openPhoto:
            router?.openPhoto()
        case .removeImage:
            break
        }
    }
    
    func cancelReasonMoveBack() {
        listener?.cancelReasonMoveBack()
    }
    
    var modelsObser: Observable<[CancelModel]> {
        return $models.asObservable()
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return indicator.asObservable().observeOn(MainScheduler.asyncInstance)
    }

    var imagesObser: Observable<[UIImage]> {
        return $images.asObservable()
    }
    
    func submit(index: Int) {
        switch self.type {
        case .cancelTrip:
            self.submitCancelTrip(index: index)
        case .deliveryFoodFail:
            self.uploadImage(index: index)
        case .cancelDeliveryFood, .deliveryShopFail:
            self.submitCancelTrip(index: index)
        }
    }
}

// MARK: Class's private methods
private extension FeedbackCancelResonInteractor {
    private func setupRX() {
        // todo: Bind data stream here
    }
    
    func uploadImage(index: Int) {
        guard images.count > 0 else {
            self.presenter.showAlert(message: "Vui lòng chụp ảnh xác nhận đã đến điểm giao hàng")
            return
        }
        
        UploadFoodImage
            .uploadMutiple(images: self.images, path: "delivery_fail")
            .observeOn(MainScheduler.instance)
            .trackProgressActivity(self.indicator)
            .subscribe(onNext: { [weak self] (urls) in
                self?.updateBookingService(urls: urls, index: index)
                }, onError: { [weak self] (e) in
                    self?.presenter.showError(eror: e)
            }).disposeOnDeactivate(interactor: self)
    }
    
    func submitCancelTrip(index: Int) {
        guard let userId = UserManager.shared.getUserId(),
            let model = models[safe: index],
            let specificId = model.id else { return }
        
        let description = (specificId == CancelModel.otherReason().id ) ? otherReason: model.description
        
        let param = [
            "userId": userId,
            "app": "Driver",
            "type": "CancellationReasons",
            "orderId": self.tripId,
            "serviceId": self.groupServiceType.rawValue,
            "specificId": specificId,
            "description": description ?? "",
            "comment": "",
            "selector": selector
            ] as [String : Any]
        
        FirebaseTokenHelper
            .instance
            .eToken
            .filterNil()
            .take(1)
            .flatMap { Requester.responseDTO(decodeTo: OptionalMessageDTO<CancelModel>.self,
                                             using: VatoAPIRouter.feedback(token: $0, params: param) ,
                                             method: .post,
                                             encoding: JSONEncoding.default) }
            .observeOn(MainScheduler.asyncInstance)
            .trackProgressActivity(self.indicator)
            .subscribe(onNext: { [weak self] (r) in
                if r.response.fail == true {
                    let e = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey: r.response.message ?? "Chức năng tạm thời gián đoạn. Vui lòng thử lại sau."])
                    self?.presenter.showError(eror: e)
                } else {
                    self?.listener?.cancelReasonSuccess(reason: description ?? "", reasonId: specificId, url: [])
                }
                }, onError: { [weak self] (e) in
                    self?.presenter.showError(eror: e)
            }).disposeOnDeactivate(interactor: self)
    }
    
    func updateBookingService(urls: [URL?], index: Int) {
        let resultURLs = urls.compactMap { url -> URL? in
            guard let url = url else { return nil }
            var component = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let queries = component?.queryItems?.filter { $0.name != "token"}
            component?.queryItems = queries
            return component?.url
        }
        guard let model = models[safe: index],
              let specificId = model.id else { return }
              let description = (specificId == CancelModel.otherReason().id) ? otherReason: model.description
        bookingService?.updateEndReason(["end_reason_id": specificId,
                                         "end_reason_value": description ?? ""])
        bookingService?.updateInfoDeliverFailImages(resultURLs.compactMap { $0.absoluteString })
        self.listener?.cancelReasonSuccess(reason: description ?? "", reasonId: specificId, url: resultURLs)
    }
}
