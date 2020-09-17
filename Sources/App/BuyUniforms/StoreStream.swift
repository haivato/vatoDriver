//  File name   : StoreStream.swift
//
//  Author      : Dung Vu
//  Created date: 12/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import RxCocoa
import Alamofire

enum StoreBookingState {
    case NEW
    case DEFAULT
}

typealias BasketModel = [DisplayProduct: BasketStoreValueProtocol]

protocol BasketStoreValueProtocol {
    var note: String? { get }
    var quantity: Int { get }
}

struct DateTime: Equatable {
    private struct Config {
        static let formatTime = "HH:mm"
        static let formatDate = "dd/MM/yyyy"
        static let timeAppendDelivery = 30 //minute
    }
    
    var date: Date
    var time: Date
    
    var timeDescription: String { return time.string(from: Config.formatTime) }
    var dateDescription: String { return date.string(from: Config.formatDate) }
    
    func string() -> String { return "\(timeDescription) - \(dateDescription)" }
    
    static func defautValue() -> DateTime {
        let result = Date().addingTimeInterval(TimeInterval(Config.timeAppendDelivery) * 60)
        return DateTime(date: result, time: result)
    }
    
    static func == (lhs: DateTime, rhs: DateTime) -> Bool {
        return lhs.date == rhs.date && lhs.time == rhs.time
    }
    
    func toString() -> String {
        let calendar = Calendar.current
        let hour = String(format: "%02d", calendar.component(.hour, from: time))
        let minute = String(format: "%02d", calendar.component(.minute, from: time))
        let second = String(format: "%02d", calendar.component(.second, from: time))
        return date.string(from: "yyyy-MM-dd") + "T" + "\(hour):\(minute):\(second).000"
    }
}

protocol StoreStream {
    var basket: Observable<BasketModel> { get }
    var address: Observable<AddressProtocol> { get }
    var note: Observable<NoteDeliveryModel> { get }
    var timeDelivery: Observable<DateTime?> { get }
    var quoteCart: Observable<QuoteCart?> { get }
    subscript (item: DisplayProduct) -> BasketStoreValueProtocol? { get }
    var storeBookingState: Observable<StoreBookingState> { get }
    var store: Observable<FoodExploreItem?> { get }
    var paymentMethod: Observable<PaymentCardDetail> { get }
}

typealias QuoteCartParams = (params: JSON, method: HTTPMethod)
protocol MutableStoreStream: StoreStream {
    func update(basket: BasketModel)
    func update(item: DisplayProduct, value: BasketStoreValueProtocol?)
    func update(time: DateTime?)
    func update(address: AddressProtocol)
    func update(quoteCard: QuoteCart?)
    func update(note: NoteDeliveryModel)
    func update(store: FoodExploreItem?)
    func update(paymentCard: PaymentCardDetail)
    
    func createParams() -> Observable<QuoteCartParams?>
    func reset()
    func update(bookingState: StoreBookingState)
}

final class StoreStreamImpl {
    private lazy var mBasket: BehaviorRelay<BasketModel> = BehaviorRelay(value: [:])
    private lazy var mTimeDelivery: BehaviorRelay<DateTime?> = BehaviorRelay(value: nil)
    private lazy var mAddress: ReplaySubject<AddressProtocol> = ReplaySubject.create(bufferSize: 1)
    
    private lazy var mQuoteCart: BehaviorRelay<QuoteCart?> = BehaviorRelay(value: nil)
    private let mNote: BehaviorRelay<NoteDeliveryModel> = BehaviorRelay(value: NoteDeliveryModel(note: "", option: ""))
    private let mBookingState = PublishSubject<StoreBookingState>()
    private let mStore: BehaviorRelay<FoodExploreItem?> = BehaviorRelay(value: nil)
    private let mPaymentMethod: BehaviorRelay<PaymentCardDetail> = BehaviorRelay(value: PaymentCardDetail.cash())
}

extension StoreStreamImpl: MutableStoreStream {
    
    var paymentMethod: Observable<PaymentCardDetail> {
        return mPaymentMethod.asObservable()
    }
    
    var store: Observable<FoodExploreItem?> {
        return mStore.asObservable()
    }
    
    var note: Observable<NoteDeliveryModel> {
        return mNote.asObservable()
    }
    
    func update(note: NoteDeliveryModel) {
        mNote.accept(note)
    }
    
    func update(address: AddressProtocol) {
        mAddress.onNext(address)
    }
    
    var timeDelivery: Observable<DateTime?> {
        return mTimeDelivery.asObservable()
    }
    
    func update(paymentCard: PaymentCardDetail) {
        mPaymentMethod.accept(paymentCard)
    }
    
    func update(time: DateTime?) {
        mTimeDelivery.accept(time)
    }
    
    subscript(item: DisplayProduct) -> BasketStoreValueProtocol? {
        let value = mBasket.value[item]
        return value
    }
    
    var basket: Observable<BasketModel> {
        return mBasket.observeOn(MainScheduler.asyncInstance)
    }
    
    var address: Observable<AddressProtocol> {
        return mAddress.asObservable()
    }
    
    func update(basket: BasketModel) {
        mBasket.accept(basket)
    }
    
    func update(item: DisplayProduct, value: BasketStoreValueProtocol?) {
        var current = mBasket.value
        if (value?.quantity ?? 0) <= 0 {
            current.removeValue(forKey: item)
        } else {
            current[item] = value
        }
        mBasket.accept(current)
    }
    
    func update(quoteCard: QuoteCart?) {
        mQuoteCart.accept(quoteCard)
    }
    
    var quoteCart: Observable<QuoteCart?> {
        return mQuoteCart.asObservable()
    }
    
    var storeBookingState: Observable<StoreBookingState> {
        return mBookingState.asObservable()
    }
    
    func update(store: FoodExploreItem?) {
        mStore.accept(store)
    }
    
    func update(bookingState: StoreBookingState) {
        self.mBookingState.onNext(bookingState)
    }
    
    
    func createParams() -> Observable<QuoteCartParams?> {
        let basketObserver = self.basket.take(1)
        let storeObserver = self.mStore.take(1)
        let paymentMethod = self.paymentMethod.take(1)
        
        return Observable.zip(basketObserver, storeObserver, paymentMethod).map { (basket, store, method) -> QuoteCartParams? in
            var params: JSON = [:]
            guard let storeId = store?.id else {
                return nil
            }
            params["paymentMethods"] = [method.type.rawValue]
            var quoteItems: [JSON] = []
            for (key, value) in basket {
                var quoteItem: JSON = [:]
                quoteItem["appliedRuleIds"] = []
                quoteItem["basePrice"] = 0.0
                quoteItem["description"] = value.note ?? ""
                quoteItem["discountAmount"] = 0.0
                quoteItem["discountPercent"] = 0.0
                quoteItem["name"] = key.name ?? ""
                quoteItem["priceInclTax"] = 0.0
                quoteItem["productId"] = key.productId
                quoteItem["qty"] = value.quantity
                quoteItem["quoteItemOptions"] = []
                quoteItem["storeId"] = storeId
                quoteItems.append(quoteItem)
            }
            params["quoteItems"] = quoteItems
            params["storeId"] = storeId
            params["appliedRuleIds"] = []
            params["coupons"] = []
            let method: HTTPMethod = .post
            return QuoteCartParams(params: params, method: method)
        }
        
    
    }
    
    func reset() {
        self.update(basket: [:])
        self.update(note: NoteDeliveryModel(note: "", option: ""))
        self.update(time: DateTime.defautValue())
        self.update(quoteCard: nil)
        self.update(store: nil)
    }
    
}
