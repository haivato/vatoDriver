//  File name   : PinAddressInteractor.swift
//
//  Author      : vato.
//  Created date: 8/19/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork

protocol PinAddressRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol PinAddressPresentable: Presentable {
    var listener: PinAddressPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol PinAddressListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func pinAddressDismiss()
    func pinDidselect(model: MapModel.Place)
}

final class PinAddressInteractor: PresentableInteractor<PinAddressPresentable>, LocationRequestProtocol {
    /// Class's public properties.
    weak var router: PinAddressRouting?
    weak var listener: PinAddressListener?

    /// Class's constructor.
    init(presenter: PinAddressPresentable,
         authStream: AuthenticatedStream,
         defaultPlace: AddressProtocol?,
         isOrigin: Bool) {
        self.mIsOrigin = isOrigin
        super.init(presenter: presenter)
        presenter.listener = self
        self.placeDetailSubject.onNext(nil)
        self.defaultPlace.onNext(defaultPlace)
        self.authStream = authStream
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
    private var authStream: AuthenticatedStream?
    private let defaultPlace = ReplaySubject<AddressProtocol?>.create(bufferSize: 1)
    private let isLoading = BehaviorSubject<Bool>.init(value: false)
    private let placeDetailSubject = ReplaySubject<AddressProtocol?>.create(bufferSize: 1)
    private var searchDisposable: Disposable?
    private lazy var disposeBag = DisposeBag()
    
    private var mIsOrigin: Bool
    var token: Observable<String> {
        return self.authStream!.firebaseAuthToken.take(1)
    }
}

// MARK: PinAddressInteractable's members
extension PinAddressInteractor: PinAddressInteractable {
}

// MARK: PinAddressPresentableListener's members
extension PinAddressInteractor: PinAddressPresentableListener {
    
    func didSelectModel() {
        self.placeDetailSubject
            .subscribe(onNext: { [weak self] (model) in
            if let model = model {
                let place = MapModel.Place(name: model.name ?? "",
                                           address: model.subLocality,
                                           location: VatoNetwork.MapModel.Location(lat: model.coordinate.latitude, lon: model.coordinate.longitude),
                                           placeId: "\(model.placeId ?? "")",
                    isFavorite: false)
                self?.listener?.pinDidselect(model: place)
            }
        }).disposed(by: disposeBag)
    }
    
    var placeDetailObservable: Observable<AddressProtocol?> {
        return placeDetailSubject.asObserver()
    }
    
    func removeCurrentPlace() {
        self.placeDetailSubject.onNext(nil)
    }
    
    var defaultPlaceObservable: Observable<AddressProtocol?> {
        return self.defaultPlace.asObserver()
    }
    
    func moveBack() {
        self.listener?.pinAddressDismiss()
    }
    
    func lookupAddress(for coordinate: CLLocationCoordinate2D) {
        searchDisposable?.dispose()
        searchDisposable = nil
        searchDisposable = self.lookupAddress(for: coordinate, maxDistanceHistory: 100)
            .timeout(30.0, scheduler: SerialDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] (value) in
                self?.placeDetailSubject.onNext(value)
            })
    }
    
    var isOrigin: Bool {
        return mIsOrigin
    }
 
}

// MARK: Class's private methods
private extension PinAddressInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
