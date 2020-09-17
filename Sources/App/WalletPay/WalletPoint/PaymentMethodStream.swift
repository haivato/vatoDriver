//  File name   : PaymentMethodStream.swift
//
//  Author      : Dung Vu
//  Created date: 3/4/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

protocol PaymentMethodIdentifierProtocol: Equatable {
    var id: String { get }
}

extension PaymentMethodIdentifierProtocol {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

typealias Card = PaymentCardDetail
protocol PaymentStream {
    var source: Observable<[Card]> { get }
    var isCheckedLatePayment: Observable<Bool> { get }
    var currentSelect: Card? { get }
    func exist(method: Card) -> Bool
}

protocol MutablePaymentStream: PaymentStream, SafeAccessProtocol {
    func update(source: [Card])
    func update(select: Card)

    func updateCheckLatePayment(status: Bool)
}

extension MutablePaymentStream {
    func update(select: Card) {
            excute {
            do {
                let realm = try Realm()
                try realm.write {
                    let o = realm.create(PaymentSelect.self)
                    let data = try select.toData()
                    o.update(id: select.id, data: data)
                }
            } catch {
                printDebug(error)
            }
        }
    }
    
    func loadSelect() -> Card? {
        func load() -> Card? {
            do {
                let realm = try Realm()
                let uid = UserDataHelper.shareInstance().userId()
                guard let s = realm.objects(PaymentSelect.self).filter({ $0.uid == uid }).sorted(by: <).last,
                    let data = s.data
                else {
                    return nil
                }
                return try Card.toModel(from: data)
            } catch {
                printDebug(error)
                return nil
            }
        }
        
        guard let result = load(), self.exist(method: result) else {
            return nil
        }
        
        return result
    }
}

final class PaymentSelect: Object, Comparable {

    @objc dynamic var id: String = ""
    @objc dynamic var data: Data?
    @objc dynamic var time: TimeInterval = 0
    @objc dynamic var uid: Int = 0
    
   

    func update(id: String, data: Data) {
        self.id = id
        self.data = data
        self.time = Date().timeIntervalSince1970
        self.uid = UserDataHelper.shareInstance().userId()
    }
    
    static func <(lhs: PaymentSelect, rhs: PaymentSelect) -> Bool {
        return lhs.time < rhs.time
    }
}

final class PaymentStreamImpl: MutablePaymentStream {
    var isCheckedLatePayment: Observable<Bool> {
        return eCheckedLatePayment.asObservable()
    }

    private (set)lazy var lock: NSRecursiveLock = NSRecursiveLock()
    var source: Observable<[Card]> {
        return eSource.observeOn(MainScheduler.asyncInstance)
    }
    
    private var mSource: [Card] = []
    
    var currentSelect: Card? {
        return loadSelect()
    }

    private lazy var eSource: BehaviorRelay<[Card]> = BehaviorRelay(value: [])
    private lazy var eCheckedLatePayment: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    func update(source: [Card]) {
        excute { [unowned self] in
            self.mSource = source
            self.eSource.accept(source)
        }
    }

    func updateCheckLatePayment(status: Bool) {
        eCheckedLatePayment.accept(status)
    }

    func exist(method: Card) -> Bool {
        guard method.napas else {
            return true
        }
        let exist = mSource.contains(method)
        return exist
    }
    
    deinit {
        printDebug("\(#function)")
    }
}

