//  File name   : SetLocationInteractor.swift
//
//  Author      : khoi tran
//  Created date: 3/4/20
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

protocol SetLocationRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToChangeLocation()
}

protocol SetLocationPresentable: Presentable {
    var listener: SetLocationPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol SetLocationListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func setLocationMoveBack(_ address: AddressProtocol?)
}

final class SetLocationInteractor: PresentableInteractor<SetLocationPresentable> {
    /// Class's public properties.
    weak var router: SetLocationRouting?
    weak var listener: SetLocationListener?

    /// Class's constructor.
    init(presenter: SetLocationPresentable, mutableBookingStream: MutableBookingStream) {
        self.mutableBookingStream = mutableBookingStream
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
    private let mutableBookingStream: MutableBookingStream
    
    @Replay(queue: MainScheduler.asyncInstance) private var mLastestLocation: AddressProtocol
    
    @Replay(queue: MainScheduler.asyncInstance) private var mDisplayName: String
}

// MARK: SetLocationInteractable's members
extension SetLocationInteractor: SetLocationInteractable {
    func pickerDismiss() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func didSelectModel(model: AddressProtocol) {
        self.router?.dismissCurrentRoute(completion: { [weak self] in
            guard let wSelf = self else { return }
            
            wSelf.mLastestLocation = model
        })
    }
    
}

// MARK: SetLocationPresentableListener's members
extension SetLocationInteractor: SetLocationPresentableListener {
    
    var latestLocation: Observable<AddressProtocol> {
        return $mLastestLocation
    }
    
    
    var displayName: Observable<String> {
        return $mDisplayName
    }
    
    
    func routeToChangeLocation() {
        self.router?.routeToChangeLocation()
    }
    
    func setDefaultLocation() {
        $mLastestLocation.take(1).observeOn(MainScheduler.asyncInstance).bind {[weak self] (address) in
            guard let wSelf = self else { return }
            wSelf.listener?.setLocationMoveBack(address)
        }.disposeOnDeactivate(interactor: self)
    }
    
    func openSetting() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        self.listener?.setLocationMoveBack(nil)
    }
}

// MARK: Class's private methods
private extension SetLocationInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
        self.getLatestLocation()
    }
    
    private func getLatestLocation() {
        let d = UserManager.shared.getCurrentUser()?.user?.nickname
        let f = UserManager.shared.getCurrentUser()?.user?.fullName
        let displayName = d?.orEmpty(f ?? "")
        self.mDisplayName = displayName ?? ""
        
    }
}
