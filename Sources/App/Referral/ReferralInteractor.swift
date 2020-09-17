//  File name   : ReferralInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 12/26/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import SVProgressHUD
import FwiCore
import FwiCoreRX

struct ReferralResponse: Codable {
    var code: String?
    var shareLink: URL?
    var shareText: String?
    var description: String?
    var image: String?
}

protocol ReferralRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func showError(from error: Error)
}

protocol ReferralPresentable: Presentable {
    var listener: ReferralPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol ReferralListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func referralMoveback()
}

final class ReferralInteractor: PresentableInteractor<ReferralPresentable>, ReferralInteractable, ReferralPresentableListener, ActivityTrackingProtocol {
    var referral: Observable<ReferralResponse> {
        return response.filterNil().observeOn(MainScheduler.asyncInstance).asObservable()
    }
    
    weak var router: ReferralRouting?
    weak var listener: ReferralListener?
    private (set) var authenticatedStream: AuthenticatedStream
    private lazy var response: ReplaySubject<ReferralResponse?> = ReplaySubject.create(bufferSize: 1)

    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    init(presenter: ReferralPresentable, authenticatedStream: AuthenticatedStream) {
        self.authenticatedStream = authenticatedStream
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // todo: Implement business logic here.
        setupRX()
        requestReferralInfor()
    }
    
    private func setupRX() {
        self.indicator.asObservable().observeOn(MainScheduler.asyncInstance).bind {
            $0 ? LoadingManager.instance.show() : LoadingManager.instance.dismiss()
        }.disposeOnDeactivate(interactor: self)
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    func referralMoveback() {
        self.listener?.referralMoveback()
    }
    
    private func requestReferralInfor() {
        let userId = UserDataHelper.shareInstance().userId()
        self.authenticatedStream.firebaseAuthToken
            .timeout(0.3, scheduler: SerialDispatchQueueScheduler(qos: .background))
            .take(1).map{ VatoAPIRouter.referralInfo(authToken: $0, userId: userId) }.flatMap{
            Requester.responseDTO(decodeTo: OptionalMessageDTO<ReferralResponse>.self, using: $0)
        }.trackActivity(self.indicator)
        .observeOn(MainScheduler.asyncInstance)
        .subscribe { [weak self](event) in
            guard let wSelf = self else {
                return
            }
            
            switch event {
            case .next(let e):
                if let error = e.response.error {
                    wSelf.handler(error: error)
                } else {
                    wSelf.response.onNext(e.response.data)
                }
            case .error(let e):
                wSelf.handler(error: e)
            default:
                break
            }
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func handler(error: Error) {
        router?.showError(from: error)
    }
}
