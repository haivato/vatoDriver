//  File name   : LocationPickerInteractor.swift
//
//  Author      : khoi tran
//  Created date: 11/13/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import SVProgressHUD

struct MapInteractor {
    struct Config {
        static var defaultMarker : MarkerHistory = {
            let marker = MarkerHistory()
            marker.lat = 10.7664067
            marker.lng = 106.6935349
            marker.name = "Tập Đoàn Phương Trang"
            marker.thoroughfare = "80 Trần Hưng Đạo"
            marker.locality = "Phường Phạm Ngũ Lão"
            marker.subLocality = "Quận 1"
            marker.administrativeArea = ""
            marker.country = "Việt Nam"
            return marker
        }()
    }
}

protocol LocationPickerRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func moveToPin(defautPlace: AddressProtocol?, isOrigin: Bool)
}

protocol LocationPickerPresentable: Presentable {
    var listener: LocationPickerPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
    func showError(msg: String)
}

protocol LocationPickerListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func pickerDismiss()
    func didSelectModel(model: AddressProtocol)
}

final class LocationPickerInteractor: PresentableInteractor<LocationPickerPresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: LocationPickerRouting?
    weak var listener: LocationPickerListener?

    /// Class's constructor.
    init(presenter: LocationPickerPresentable,
         authStream: AuthenticatedStream,
         placeModel: AddressProtocol?,
         searchType: SearchType,
         typeLocationPicker: LocationPickerDisplayType) {
        
        self.searchType = searchType
        self.isOrigin = searchType.isOrigin()
        self.typeLocationPicker = typeLocationPicker

        super.init(presenter: presenter)
        self.presenter.listener = self
        self.authStream = authStream
        if let placeModel = placeModel {
            self.placeModel.onNext(placeModel)
        }
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
    private var searchDisposable: Disposable?
    private let listDataSubject = ReplaySubject<[AddressProtocol]>.create(bufferSize: 1)
    private let listDataFavoriteSubject = ReplaySubject<[PlaceModel]>.create(bufferSize: 1)
    private let placeModel = ReplaySubject<AddressProtocol>.create(bufferSize: 1)
    internal let typeLocationPicker: LocationPickerDisplayType
    internal let searchType: SearchType
    internal let isOrigin: Bool
}

// MARK: LocationPickerInteractable's members
extension LocationPickerInteractor: LocationPickerInteractable {
    func pinAddressDismiss() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func pinDidselect(model: MapModel.Place) {
        
        let location = CLLocationCoordinate2D(latitude: model.location?.lat ?? 0, longitude: model.location?.lon ?? 0)
        
        let address = Address(
            placeId: nil,
            coordinate: location,
            name: model.primaryName ?? "",
            thoroughfare: "",
            locality: "",
            subLocality: model.address ?? "",
            administrativeArea: "",
            postalCode: "",
            country: "",
            lines: [],
            favoritePlaceID: 0,
            zoneId: 0,
            isOrigin: self.isOrigin,
            counter: 0,
            distance: model.distance)
        
        self.listener?.didSelectModel(model: address)
    }
}

// MARK: LocationPickerPresentableListener's members
extension LocationPickerInteractor: LocationPickerPresentableListener {
    
    
    
    func moveToPin() {
        let isOrigin = searchType.isOrigin()
        self.placeModel.take(1).timeout(0.3, scheduler: MainScheduler.instance).subscribe(onNext: {[weak self] (model) in
            self?.router?.moveToPin(defautPlace: model, isOrigin: isOrigin)
            }, onError: { [weak self]e in
                let `default` = MapInteractor.Config.defaultMarker
                self?.router?.moveToPin(defautPlace: `default`.address, isOrigin: isOrigin)
        }).disposeOnDeactivate(interactor: self)
    }
    
    var placeModelObservable: Observable<AddressProtocol> {
        return self.placeModel.asObserver()
    }
    
    func didSelectModel(indexPath: IndexPath) {
        listDataSubject
            .take(1)
            .flatMap({[weak self] (l) -> Observable<AddressProtocol> in
                guard let wSelf = self else { return Observable.empty() }
                return wSelf.checkReturnLocation(model: l[indexPath.row])
            })
            .trackProgressActivity(self.indicator)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] (r) in
                self?.listener?.didSelectModel(model: r)
                }, onError: {[weak self] (e) in
                    let code = (e as NSError).code
                    if code == NSURLErrorNotConnectedToInternet || code == NSURLErrorBadServerResponse {
                        self?.presenter.showError(msg: Text.networkDownDescription.localizedText)
                    } else {
                        self?.presenter.showError(msg: Text.thereWasAnErrorFunction.localizedText)
                    }
            }).disposeOnDeactivate(interactor: self)
    }
    
    func didSelectFavoriteModel(model: PlaceModel) {
        
        let blockProcessSelectFavoriteModel:(PlaceModel) -> Void = {[weak self] model in
            guard let lat = model.lat, let lon = model.lon else { return }
           
            
            let coordinate = CLLocationCoordinate2D(latitude: Double(lat) ?? 0 , longitude: Double(lon) ?? 0)
            
            let address = Address(
                placeId: nil,
                coordinate: coordinate,
                name: model.address ?? "",
                thoroughfare: "",
                locality: "",
                subLocality: model.address ?? "",
                administrativeArea: "",
                postalCode: "",
                country: "",
                lines: [],
                favoritePlaceID: 0,
                zoneId: 0,
                isOrigin: self?.searchType.isOrigin() ?? false,
                counter: 0,
                distance: nil)
            
            
            self?.listener?.didSelectModel(model: address)
        }
        
        if model.typeId == .AddNew {
            let viewController = FavoritePlaceViewController()
            let navigation = FacecarNavigationViewController(rootViewController: viewController)
            navigation.modalTransitionStyle = .coverVertical
            navigation.modalPresentationStyle = .fullScreen

            self.router?.viewControllable.uiviewController.present(navigation, animated: true, completion: nil)
            viewController.didSelectModel = { model in
                guard let model = model else { return }
                let m = PlaceModel(from: model)
                blockProcessSelectFavoriteModel(m)
            }
            return
        }
        blockProcessSelectFavoriteModel(model)
    }
    
    func didSelectAddFavorite(item: AddressProtocol) {
        self.checkReturnLocation(model: item)
            .trackProgressActivity(self.indicator)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] (c) in
                let placeModel = PlaceModel(id: nil, name: nil, address: c.subLocality, typeId: .Orther, lat: "\(c.coordinate.latitude)", lon: "\(c.coordinate.longitude)")
                self?.moveToAddFavorite(with: placeModel)
            }, onError: { [weak self] (e) in
                let code = (e as NSError).code
                if code == NSURLErrorNotConnectedToInternet || code == NSURLErrorBadServerResponse {
                    self?.presenter.showError(msg: Text.networkDownDescription.localizedText)
                } else {
                    self?.presenter.showError(msg: Text.thereWasAnErrorFunction.localizedText)
                }
            }).disposeOnDeactivate(interactor: self)
    }
    
    func moveToAddFavorite(with model: PlaceModel) {
//        let viewController = UpdatePlaceViewController(mode: .quickCreate, viewModel: UpdatePlaceVM(model: model))
//        viewController.needReloadData = FavoritePlaceManager.shared.reload
//
//        let navigation = FacecarNavigationViewController(rootViewController: viewController)
//        navigation.modalTransitionStyle = .coverVertical
//        navigation.modalPresentationStyle = .fullScreen
//
//        self.router?.viewControllable.uiviewController.present(navigation, animated: true, completion: nil)
    }
    
    func checkReturnLocation(model: AddressProtocol) -> Observable<AddressProtocol> {
        guard model.isValidCoordinate() == false,
            let placeId = model.placeId else {
                return Observable.just(model)
        }
        
        return self.getLocation(model: model, placeId: placeId)
    }
    
    func getLocation(model: AddressProtocol, placeId: String) -> Observable<AddressProtocol> {
        guard let authStream = self.authStream else {
            let err = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey: Text.thereWasAnErrorFunction.localizedText])
            return Observable.error(err)
        }
        
        return Observable.create({ (s) -> Disposable in
            authStream.firebaseAuthToken
                .flatMap { MapAPI.placeDetails(with: placeId, authToken: $0) }
                .timeout(15.0, scheduler: SerialDispatchQueueScheduler(qos: .background))
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { (c) in
                    let coor = CLLocationCoordinate2D(latitude: c.location?.lat ?? 0, longitude: c.location?.lon ?? 0)
                    var t = model
                    t.update(coordinate: coor)
                    
                    s.onNext(t)
                    s.onCompleted()
                }, onError: { (e) in
                    s.onError(e)
                }).disposeOnDeactivate(interactor: self)
            return Disposables.create()
        })
    }
    
    var listFavoriteObservable: Observable<[PlaceModel]> {
        return listDataFavoriteSubject.asObserver()
    }
    
    var listDataObservable: Observable<[AddressProtocol]> {
        return listDataSubject.asObservable()
    }
    
    func moveBack() {
        listener?.pickerDismiss()
    }
    
    func searchLocation(keyword: String) {
        self.searchDisposable?.dispose()
        self.searchDisposable = nil
        
        let keywordTrim = keyword.trim()
        guard keywordTrim.count > 0 else {
            // load history
            self.getLatestLocations().subscribe(onNext: {[weak self] (listData) in
                self?.listDataSubject.onNext(listData)
            }).disposeOnDeactivate(interactor: self)
            return
        }
        // search google
    
        self.searchDisposable = self.placeModel.take(1).timeout(0.3, scheduler: MainScheduler.instance).catchErrorJustReturn(MapInteractor.Config.defaultMarker.address).subscribe(onNext: {[weak self] (model) in
            self?.searchAddressBy(model: model, keywordTrim: keywordTrim)
        })
    }
    
    func searchAddressBy(model: AddressProtocol, keywordTrim: String) {
        self.searchDisposable = self.authStream?.firebaseAuthToken
            .flatMap {
                MapAPI.findPlace(with: keywordTrim, currentLocation: model.coordinate, authToken: $0)
            }.timeout(30.0, scheduler: MainScheduler.asyncInstance).subscribe(onNext: {[weak self] (data) in
                let markers = data.map({ (m) -> AddressProtocol in
                    var model = MarkerHistory.init(with: m).address
                    model.update(placeId: m.placeId)
                    model.distance = m.distance
                    model.isOrigin = self?.searchType.isOrigin() ?? false
                    return model
                }).sorted(by: { (a1, a2) -> Bool in
                    return a1.distance ?? Double.greatestFiniteMagnitude < a2.distance ?? Double.greatestFiniteMagnitude
                })
            
                self?.listDataSubject.onNext(markers)
            })
    }
    
    func getListFavorite() {
//        FavoritePlaceManager.shared.result.map { list -> [PlaceModel] in
//            let modelAddNew = PlaceModel(id: nil, name: Text.favoritePlace.localizedText, address: nil, typeId: .AddNew, lat: nil, lon: nil)
//            return [modelAddNew] + list
//        }.bind(to: listDataFavoriteSubject).disposeOnDeactivate(interactor: self)
    }
    
    var eLoadingObser: Observable<(Bool,Double)> {
        return self.indicator.asObservable()
    }
}

// MARK: Class's private methods
private extension LocationPickerInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
    
    private func loadFiveLatestHistory() -> Observable<[AddressProtocol]> {
        let run = { () -> [AddressProtocol] in
            return []
        }
        
        let result = run()
        
        return Observable.just(result)
    }
    
    private func getLatestLocations() -> Observable<[AddressProtocol]> {
        return Observable.just([])
//        let latestLocation = PlacesHistoryManager.instance.searchLatest(isOrigin: searchType.isOrigin())
//        let listMostUsedLocation = PlacesHistoryManager.instance.searchCounter(isOrigin: searchType.isOrigin())
//
//        return Observable.zip(latestLocation, listMostUsedLocation).map { (latestLocation, listMostUsedLocation) -> [AddressProtocol] in
//            guard let latestLocation = latestLocation else {
//                return listMostUsedLocation
//            }
//
//            let tempArray = [latestLocation] +  listMostUsedLocation.filter({ $0.coordinate != latestLocation.coordinate })
//
//            return tempArray.filter({$0.counter > 0 })
//        }
    }
   
}
