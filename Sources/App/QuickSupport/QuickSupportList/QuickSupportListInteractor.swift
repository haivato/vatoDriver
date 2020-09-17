//  File name   : QuickSupportListInteractor.swift
//
//  Author      : khoi tran
//  Created date: 1/15/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Alamofire
import FirebaseFirestore

protocol QuickSupportListRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToQuickSupportDetail(model: QuickSupportModel)
}

protocol QuickSupportListPresentable: Presentable {
    var listener: QuickSupportListPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol QuickSupportListListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func quickSupportListMoveBack()
}

final class QuickSupportListInteractor: PresentableInteractor<QuickSupportListPresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: QuickSupportListRouting?
    weak var listener: QuickSupportListListener?

    /// Class's constructor.
    override init(presenter: QuickSupportListPresentable) {
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

    var lastSnapshot: DocumentSnapshot?
    private lazy var collectionRef = Firestore.firestore().collection(collection: .quickSupport)
    /// Class's private properties.
}

// MARK: QuickSupportListInteractable's members
extension QuickSupportListInteractor: QuickSupportListInteractable {
    func quickSupportDetailMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
}

// MARK: QuickSupportListPresentableListener's members
extension QuickSupportListInteractor: QuickSupportListPresentableListener {
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T> where T : Decodable {
        guard let userId = UserManager.shared.getUserId() else {
            fatalError("has not been implemented")
        }
        
        let query: (DocumentSnapshot?) -> Query = { [collectionRef] snapshot in
            let new = collectionRef
            .whereField("createdBy", isEqualTo: userId)
            .whereField("userType", isEqualTo: UserType.driver.rawValue)
            .limit(to: QuickSupportListVC.Config.pageSize)
            .order(by: "createdAt", descending: true)
            
            if let snapshot = snapshot {
                new.start(afterDocument: snapshot)
            }
            return new
        }
        
        return query(lastSnapshot)
            .getDocuments()
            .trackProgressActivity(self.indicator)
            .map { [weak self] snapShot -> [QuickSupportModel]? in
                self?.lastSnapshot = snapShot?.last
                return snapShot?.compactMap { try? $0.decode(to: QuickSupportModel.self, block: block) }
                
        }.map { (data) -> T in
            let number = data?.count ?? 0
            let next = number == QuickSupportListVC.Config.pageSize
            let m = QuickSupportListResponse(values: data, next: next)
            if let m = m as? T {
                return m
            } else {
                fatalError("has not been implemented")
            }
        }
    }
    
    func detail(model: QuickSupportModel) {
        self.router?.routeToQuickSupportDetail(model: model)
    }
    
    func quickSupportListMoveBack() {
        self.listener?.quickSupportListMoveBack()
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return indicator.asObservable().observeOn(MainScheduler.asyncInstance)
    }
}

// MARK: Class's private methods
private extension QuickSupportListInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
