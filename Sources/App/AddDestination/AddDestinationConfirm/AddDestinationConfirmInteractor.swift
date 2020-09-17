//  File name   : AddDestinationConfirmInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 3/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Alamofire
import CoreLocation

protocol AddDestinationConfirmRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol AddDestinationConfirmPresentable: Presentable {
    var listener: AddDestinationConfirmPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol AddDestinationConfirmListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func dismissAddDestination()
    func addDestinationSuccess(points: [DestinationPoint], newPrice: AddDestinationNewPrice)
}

struct DestinationPoint: Equatable {
    let type: DestinationType
    let address: AddressProtocol
    let showDots: Bool
    
    static func ==(lhs: DestinationPoint, rhs: DestinationPoint) -> Bool {
        return lhs.address.coordinate == rhs.address.coordinate
    }
}

final class AddDestinationConfirmInteractor: PresentableInteractor<AddDestinationConfirmPresentable> {
    /// Class's public properties.
    weak var router: AddDestinationConfirmRouting?
    weak var listener: AddDestinationConfirmListener?
    let type: AddDestinationType
    let tripId: String
    /// Class's constructor.
    init(presenter: AddDestinationConfirmPresentable, type: AddDestinationType, tripId: String) {
        self.type = type
        self.tripId = tripId
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
//        createDummy()
        requestTripDetail()
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    func createDummy() {
        let p1 = DestinationPoint(type: .original, address: AddDestinationInfo(), showDots: true)
        let p2 = DestinationPoint(type: .destination, address: AddDestinationInfo(), showDots: true)
        let p3 = DestinationPoint(type: .index(idx: 1), address: AddDestinationInfo(), showDots: false)
        mPoints = [p1, p2, p3]
        
        let d1 = DestinationPriceInfo(attributeTitle: "Lộ trình đã di chuyển".attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey), attributePrice: 50000.currency.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)), showLine: false, edge: .zero)
        let d2 = DestinationPriceInfo(attributeTitle: "Lộ trình đã di chuyển".attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey), attributePrice: 50000.currency.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)), showLine: false, edge: .zero)
        let d3 = DestinationPriceInfo(attributeTitle: "Lộ trình đã di chuyển".attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey), attributePrice: 50000.currency.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)), showLine: false, edge: UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0))
        let d4 = DestinationPriceInfo(attributeTitle: "Lộ trình đã di chuyển".attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey), attributePrice: 50000.currency.attribute >>> .font(f: .systemFont(ofSize: 20, weight: .medium)) >>> .color(c: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)), showLine: true, edge: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0))
        mDetails = [d1, d2, d3 , d4]
    }

    /// Class's private properties.
    @Replay(queue: MainScheduler.asyncInstance) private var mPoints: [DestinationPoint]
    @Replay(queue: MainScheduler.asyncInstance) private var mDetails: [DestinationPriceInfo]
    @Replay(queue: MainScheduler.asyncInstance) var info: AddDestinationTripInfo?
    @Replay(queue: MainScheduler.asyncInstance) private var newPrice: AddDestinationNewPrice?
    @Replay(queue: MainScheduler.asyncInstance) private var addDestinationSuccess: Bool?

    private lazy var networkRequester = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
}

// MARK: AddDestinationConfirmInteractable's members
extension AddDestinationConfirmInteractor: AddDestinationConfirmInteractable {
    var points: Observable<[DestinationPoint]> {
        return $mPoints
    }
    
    var details: Observable<[DestinationPriceInfo]> {
        return $mDetails
    }
}

// MARK: AddDestinationConfirmPresentableListener's members
extension AddDestinationConfirmInteractor: AddDestinationConfirmPresentableListener {
    func updateRoute() {
        
    }
    
    func addDestinationMoveBack() {
        
    }
}

// MARK: Request Trip Info
extension AddDestinationConfirmInteractor: Weakifiable {
    func requestTripDetail() {
        let router = VatoAPIRouter.customPath(authToken: "", path: "trip/trip_detail", header: nil, params: ["id": tripId], useFullPath: false)
        networkRequester.request(using: router, decodeTo: OptionalMessageDTO<AddDestinationTripInfo>.self).bind(onNext: weakify({ (result, wSelf) in
            switch result {
            case .success(let r):
                wSelf.info = r.data
            case .failure(let e):
                print(e.localizedDescription)
            }
        })).disposeOnDeactivate(interactor: self)
    }
    
    
    func generateParams(info: AddDestinationTripInfo, price: UInt64? = nil) -> JSON {
//        let c = info.trip?.startLocation
        var params = JSON()
        params["service_id"] = info.trip?.serviceId
        params["addition_price"] = info.trip?.additionPrice
        var departure = JSON()
        departure["address"] = info.trip?.startAddress
        departure["lat"] = info.trip?.startLat //c?.lat
        departure["lon"] = info.trip?.startLon //c?.lng
        departure["name"] = info.trip?.startName
        params["departure"] = departure
        var destination = JSON()
        destination["address"] = type.address.subLocality.orEmpty(type.address.name ?? "")
        destination["lat"] = type.address.coordinate.latitude
        destination["lon"] = type.address.coordinate.longitude
        destination["name"] = type.address.name?.orEmpty(type.address.subLocality) ?? type.address.subLocality
        params["destination"] = destination
        params["fare"] = price ?? info.trip?.fPrice
        params["trip_type"] = info.trip?.type
        var points: [TripWayPoint] = []
        switch type {
        case .edit:
            points = info.trip?.wayPoints?.suffix(1) ?? []
        case .new:
            points = info.trip?.wayPoints ?? []
        }
        if info.trip?.endLocation?.valid == true {
            let end = info.trip
            let new = TripWayPoint(lat: end?.endLat ?? 0, lon: end?.endLon ?? 0, address: info.trip?.endAddress ?? "")
            points.append(new)
        }
        
        do {
            let p = try points.map { try $0.toJSON() }
            params["way_points"] = p
        } catch {
            printDebug(error.localizedDescription)
        }

        return params
    }
    
    func requestPrice() {
        let e = $info.filterNil().take(1).map { [unowned self] in self.generateParams(info: $0) }.flatMap { [weak self](p) -> Observable<Swift.Result<OptionalMessageDTO<AddDestinationNewPrice>, Error>> in
            guard let wSelf = self else { return Observable.empty() }
            let router = VatoAPIRouter.customPath(authToken: "", path: "products/routes/prices", header: nil, params: p, useFullPath: false)
            return wSelf.networkRequester.request(using: router, decodeTo: OptionalMessageDTO<AddDestinationNewPrice>.self, method: .post, encoding: JSONEncoding.default)
        }
        
        e.bind(onNext: weakify({ (result, wSelf) in
            switch result {
            case .success(let s):
                if let data = s.data {
                    wSelf.newPrice = data
                    wSelf.updatePrice(price: data)
                }
            case .failure(let e):
                print(e.localizedDescription)
            }
        })).disposeOnDeactivate(interactor: self)
    }
    
    func generateUI() {
        $info.filterNil().take(1).bind(onNext: weakify({ (info, wSelf) in
            switch wSelf.type {
            case .new(let destination):
                var items = [DestinationPoint]()
                var startAddress = AddDestinationInfo()
                startAddress.name = info.trip?.startName
                startAddress.subLocality = info.trip?.startAddress ?? ""
//                var count = (info.trip?.wayPoints?.count ?? 0)
                var current: Int = 1
                let s = DestinationPoint(type: .index(idx: current), address: startAddress, showDots: true)
                items.append(s)
                
                info.trip?.wayPoints?.enumerated().forEach({ (p) in
                    current += 1
                    var address = AddDestinationInfo()
                    address.name = p.element.address
                    address.subLocality = p.element.address
                    let t = DestinationPoint(type: .index(idx: current), address: address, showDots: true)
                    items.append(t)
                })
                
                if info.trip?.endLocation?.valid == true {
                    current += 1
                    var endAddress = AddDestinationInfo()
                    endAddress.name = info.trip?.endName ?? info.trip?.endAddress
                    endAddress.subLocality = info.trip?.endAddress ?? ""
                    let s1 = DestinationPoint(type: .index(idx: current), address: endAddress, showDots: true)
                    items.append(s1)
                }
                
                current += 1
                let d = DestinationPoint(type: .index(idx: current), address: destination, showDots: false)
                items.append(d)
                wSelf.mPoints = items
            default:
                fatalError("Please Implement")
            }
        })).disposeOnDeactivate(interactor: self)
    }
    
    func updatePrice(price: AddDestinationNewPrice) {
        $info.filterNil().take(1).bind(onNext: weakify({ (info, wSelf) in
//            guard let originPrice = info.trip?.getPrice() else { return }
//            var points: [AddDestinationTripInfo.Trip.WayPoint] = []
            var points: [TripWayPoint] = []
            switch wSelf.type {
            case .edit:
                points = info.trip?.wayPoints?.suffix(1) ?? []
            case .new:
                points = info.trip?.wayPoints ?? []
            }
            if info.trip?.endLocation?.valid == true {
                let end = info.trip?.endLocation
//                let new = AddDestinationTripInfo.Trip.WayPoint(lat: end?.lat ?? 0, lon: end?.lng ?? 0, address: info.trip?.endAddress ?? "")
                let new = TripWayPoint(lat: end?.lat ?? 0, lon: end?.lng ?? 0, address: info.trip?.endAddress ?? "")
                points.append(new)
            }

            var originPrice: UInt64?
            if points.count > 0 {
                originPrice = ((info.trip?.farePrice ?? 0 > 0 && info.trip?.price != 0) ? info.trip?.farePrice : info.trip?.price) ?? 0;
            } else {
                originPrice = info.trip?.getPrice()
            }
            let d1 = DestinationPriceInfo(attributeTitle: "Lộ trình đã di chuyển".attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey), attributePrice: (originPrice ?? 0).currency.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)), showLine: false, edge: .zero)
            
            let d3 = DestinationPriceInfo(attributeTitle: "Phụ phí".attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey), attributePrice: price.fee.currency.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)), showLine: false, edge: UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0))
            
            let d4 = DestinationPriceInfo(attributeTitle: "Cước phí cập nhật".attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey), attributePrice: price.final_fare.currency.attribute >>> .font(f: .systemFont(ofSize: 20, weight: .medium)) >>> .color(c: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)), showLine: true, edge: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0))
            wSelf.mDetails = [d1, d3 , d4]
        })).disposeOnDeactivate(interactor: self)
    }
    
    
    func changeTrips() {
        let e = $info.filterNil().take(1).map { [unowned self] in self.generateParams(info: $0) }.flatMap { [weak self](p) -> Observable<Swift.Result<OptionalIgnoreMessageDTO<Data>, Error>> in
            guard let wSelf = self else { return Observable.empty() }
            let router = VatoAPIRouter.customPath(authToken: "", path: "driver/trips/\(wSelf.tripId)", header: nil, params: p, useFullPath: false)
            return wSelf.networkRequester.request(using: router, decodeTo: OptionalIgnoreMessageDTO<Data>.self, method: .post, encoding: JSONEncoding.default)
        }
        
        e.bind(onNext: weakify({ (result, wSelf) in
            switch result {
            case .success(let s):
                wSelf.addDestinationSuccess = true
            case .failure(let e):
                print(e.localizedDescription)
            }
        })).disposeOnDeactivate(interactor: self)
    }
    
    
    func dismissAddDestination() {
        self.listener?.dismissAddDestination()
    }
    
    func submitAddDestination() {
        self.changeTrips()
    }
    
}

// MARK: Class's private methods
private extension AddDestinationConfirmInteractor {
    func handler(item: AddDestinationTripInfo) {
        generateUI()
        requestPrice()
    }
    
    
    private func setupRX() {
        // todo: Bind data stream here.
        $info.filterNil().bind(onNext: weakify({ (item, wSelf) in
            wSelf.handler(item: item)
        })).disposeOnDeactivate(interactor: self)
        
        
        let e1 = $mPoints
        let e2 = $newPrice.filterNil()
        let e3 = $addDestinationSuccess.filterNil().map{ $0 }
        
        Observable.combineLatest(e1, e2, e3)
            .observeOn(MainScheduler.asyncInstance)
            .bind {[weak self] (points, newPrice, isSuccess) in
            guard let wSelf = self else { return }            
            wSelf.listener?.addDestinationSuccess(points: points, newPrice: newPrice)
        }.disposeOnDeactivate(interactor: self)
        
    }
}
