//  File name   : QuickSupportDetailInteractor.swift
//
//  Author      : khoi tran
//  Created date: 1/16/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Alamofire
import FirebaseFirestore
protocol QuickSupportDetailRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func showImages(images: [URL], currentIndex: Int, stackView: UIStackView)
}

protocol QuickSupportDetailPresentable: Presentable {
    var listener: QuickSupportDetailPresentableListener? { get set }
    // todo: Declare methods the interactor can invoke the presenter to present data.
    func insert(items: [QuickSupportItemResponse])
    func resetTextFieldChat()
    func showError(eror: Error)
}

protocol QuickSupportDetailListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func quickSupportDetailMoveBack()
}

final class QuickSupportDetailInteractor: PresentableInteractor<QuickSupportDetailPresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: QuickSupportDetailRouting?
    weak var listener: QuickSupportDetailListener?

    /// Class's constructor.
    init(presenter: QuickSupportDetailPresentable, qsItem: QuickSupportModel) {
        self.qsItem = qsItem
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        obserChat()
        // todo: Implement business logic here.
        self.mQsItemRequest = qsItem
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    func obserChat() {
        guard let qsItemId = qsItem.id else { return }
        
        let collectionRef = Firestore.firestore().collection(collection: .quickSupport, .custom(id: qsItemId), .quickSupportComment)
        collectionRef.listenFeedback().subscribe(onNext: { [weak self] (l) in
            let r = l.compactMap { try? $0.decode(to: QuickSupportItemResponse.self, block: {
                $0.dateDecodingStrategy = .customDateFireBase
            }) }
            if self?.first == false {
            self?.presenter.insert(items: r)
            } else {
               self?.first = false
            }
        }).disposeOnDeactivate(interactor: self)
    }

    func getQuickSupportModel() {
        guard let qsItemId = qsItem.id else { fatalError("has not been implemented")  }
        
        let documentRef = Firestore.firestore().documentRef(collection: .quickSupport, storePath: .custom(path: qsItemId), action: .read)
        
        documentRef
            .find(action: .get, json: [:])
            .map { try $0?.decode(to: QuickSupportModel.self, block: {
                $0.dateDecodingStrategy = .customDateFireBase
            }) }
            .bind(onNext: {  [weak self] (data) in
                if let d = data {
                     self?.mQsItemRequest = d
                }
        }).disposeOnDeactivate(interactor: self)
    }
    
    func markMessageWasRead(items: [QuickSupportItemResponse]) {
        let values = items.filter { $0.fromSupporter() && !$0.wasRead() }
        guard values.isEmpty == false,
            let qsItemId = qsItem.id else { return }
        
        let paramArr = values.compactMap{ ["id": $0.id ?? "", "status": 1] }
        let param = ["data": paramArr] as [String : Any]
        
        FirebaseTokenHelper
            .instance
            .eToken
            .filterNil()
            .take(1)
            .flatMap { Requester.responseDTO(decodeTo: OptionalMessageDTO<String>.self,
                                             using: VatoAPIRouter.feedbackUpdateStatus(token: $0, supportId: qsItemId, params: param),
                                             method: .put,
                                             encoding: JSONEncoding.default) }
            .observeOn(MainScheduler.asyncInstance)
            .trackProgressActivity(self.indicator)
            .subscribe(onNext: { (r) in
            }).disposeOnDeactivate(interactor: self)
    }
    
    /// Class's private properties.
    private var qsItem: QuickSupportModel
    private var first = true
    @Replay(queue: MainScheduler.asyncInstance) private var mQsItemRequest: QuickSupportModel
}

// MARK: QuickSupportDetailInteractable's members
extension QuickSupportDetailInteractor: QuickSupportDetailInteractable {
}

// MARK: QuickSupportDetailPresentableListener's members
extension QuickSupportDetailInteractor: QuickSupportDetailPresentableListener {
    
    func sendMessage(message: String) {
        guard let user = UserManager.shared.getCurrentUser(),
            let qsItemId = qsItem.id else { return }
        
        let avatar = user.user.avatarUrl.isEmpty ? defautAvatar : user.user.avatarUrl
        let fullName = user.user.fullName.isEmpty ? user.user.nickname : user.user.fullName
        
        let userParam = [
            "avatarUrl": avatar ?? defautAvatar ,
            "fullName": fullName ?? "User",
            "phone": user.user.phone,
            "id": user.user.id
            ] as [String : Any]
        
        let param = [
            "content": message,
            "user": userParam
            ] as [String : Any]
        
        FirebaseTokenHelper
            .instance
            .eToken
            .filterNil()
            .take(1)
            .flatMap { Requester.responseDTO(decodeTo: OptionalMessageDTO<String>.self,
                                             using: VatoAPIRouter.answerFeedback(token: $0, supportId: qsItemId, params: param),
                                             method: .post,
                                             encoding: JSONEncoding.default) }
            .observeOn(MainScheduler.asyncInstance)
            .trackProgressActivity(self.indicator)
            .subscribe(onNext: { [weak self] (r) in
                if r.response.fail == true {
                    let e = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey: r.response.message ?? "Chức năng tạm thời gián đoạn. Vui lòng thử lại sau."])
                    self?.presenter.showError(eror: e)
                } else {
                    self?.presenter.resetTextFieldChat()
                }
                }, onError: { [weak self] (e) in
                    self?.presenter.showError(eror: e)
            }).disposeOnDeactivate(interactor: self)
    }
    
    func showImages(currentIndex: Int, stackView: UIStackView) {
        $mQsItemRequest.take(1).subscribe(onNext: {[weak self] (m) in
            guard let me = self else { return }
            let imagesUrl = m.images?.compactMap{ URL(string: $0) }
            guard let images = imagesUrl,
                images.isEmpty == false else { return }
            me.router?.showImages(images: images, currentIndex: currentIndex, stackView: stackView)
        }).disposeOnDeactivate(interactor: self)
    }
    
    var quickSupportRequest: Observable<QuickSupportModel> {
        return $mQsItemRequest
    }
    
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T> where T : Decodable {
        guard let qsItemId = qsItem.id else { fatalError("has not been implemented")  }
        self.getQuickSupportModel()
        let collectionRef = Firestore.firestore().collection(collection: .quickSupport, .custom(id: qsItemId), .quickSupportComment)
        return collectionRef
            .order(by: "createdAt", descending: false)
            .limit(to: 100)
            .getDocuments()
            .trackProgressActivity(self.indicator)
            .map { $0?.compactMap { try? $0.decode(to: QuickSupportItemResponse.self, block: block) } }
            .map { [weak self] (data) -> T in
                var m = QuickSupportDetailResponse()
                self?.markMessageWasRead(items: data ?? [])
                m.values = data
                if let m = m as? T {
                    return m
                } else {
                    fatalError("has not been implemented")
                }
        }
    }
    
    func quickSupportDetailMoveBack() {
        self.listener?.quickSupportDetailMoveBack()
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return indicator.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    
}

// MARK: Class's private methods
private extension QuickSupportDetailInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
