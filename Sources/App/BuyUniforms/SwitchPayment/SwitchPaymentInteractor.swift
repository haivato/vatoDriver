//  File name   : SwitchPaymentInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 3/12/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import Firebase
import RxCocoa
import VatoNetwork
import FwiCore
import FwiCoreRX

enum PaymentCardType: Int, CaseIterable {
    case none = -1
    case cash = 0
    case vatoPay = 1
    case visa = 3
    case master = 4
    case atm = 5
    
    var icon: UIImage? {
        switch self {
        case .visa:
            return UIImage(named: "ic_method_0")
        case .master:
            return UIImage(named: "ic_method_1")
        case .atm:
            return UIImage(named: "ic_method_3")
        default:
            return nil
        }
    }
    
    var imgLocal: String {
        switch self {
        case .atm:
            return "ic_napas_atm"
        case .visa:
            return "ic_napas_visa"
        case .master:
            return "ic_mastercard"
        default:
            return ""
        }
    }

    var method: PaymentMethod? {
        return PaymentMethod(rawValue: self.rawValue)
    }
    
    var color: UIColor {
        switch self {
        case .vatoPay:
            return #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
        default:
            return #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
        }
    }
    
    var generalName: String {
        switch self {
        case .none:
            return ""
        case .cash:
            return Text.cash.localizedText
        case .vatoPay:
            return Text.wallet.localizedText
        case .visa:
            return "Visa/MasterCard"
        case .master:
            return "Visa/MasterCard"
        case .atm:
            return "ATM"
        }
    }
}

protocol PaymentCardDisplay {
    var name: String { get }
    var iconUrl: String? { get }
    var placeHolder: String { get }
    var type: PaymentCardType { get }
}

//protocol PaymentMethodIdentifierProtocol: Equatable {
//    var id: String { get }
//}

//extension PaymentMethodIdentifierProtocol {
//    static func ==(lhs: Self, rhs: Self) -> Bool {
//        return lhs.id == rhs.id
//    }
//}

struct PaymentCardDetail: Codable, PaymentCardDisplay, PaymentMethodIdentifierProtocol {
    var placeHolder: String {
        switch type {
        case .cash:
            return "ic_payment_0"
        case .vatoPay:
            return "ic_payment_1"
        case .atm:
            return "ic_method_3"
        default:
            return ""
        }
    }
    
    var name: String {
        return self.number ?? ""
    }
    
    var type: PaymentCardType {
        if id == "0x" {
            return .cash
        }
        
        if id == "1x" {
            return .vatoPay
        }
        
        let p = number?.prefix(1) ?? ""
        
        switch p {
        case "4":
            return .visa
        case "5":
            return .master
        case "":
            return .none
        default:
            return .atm
        }
    }
    
    var napas: Bool {
        return !(id == "0x" || id == "1x")
    }
    
    var topUpName: String {
        return (brand ?? "") + " " + (number ?? "")
    }
    
    var id: String
    var brand: String?
    var issueDate: String?
    var iconUrl: String?
    var number: String?
    var scheme: String?
    var nameOnCard: String?
    var params: JSON?
    var enable3d: Bool = false
    
    var cardScheme: String? {
        switch type {
        case .visa, .master:
            return "CreditCard"
        case .atm:
            return "AtmCard"
        default:
            return nil
        }
    }
        
//    init(presenter: BuyPointPresentable, list: [TopUpMethod]) {
//        self.listTopUpMethod = list
//
//        super.init(presenter: presenter)
//        presenter.listener = self
//    }

    enum CodingKeys: String, CodingKey {
       case id = "id"
       case brand = "brand"
       case issueDate = "issueDate"
       case iconUrl = "iconUrl"
       case number = "number"
       case scheme = "scheme"
       case nameOnCard = "nameOnCard"
    }
    
    static func cash() -> PaymentCardDetail {
        let m = PaymentCardDetail(id: "0x", brand: Text.cash.localizedText, issueDate: nil, iconUrl: nil, number: nil, scheme: nil)
        return m
    }
    
    static func vatoPay() -> PaymentCardDetail {
        let m = PaymentCardDetail(id: "1x", brand: "VATOPay", issueDate: nil, iconUrl: nil, number: nil, scheme: nil)
        return m
    }
    
    static func zaloPay() -> PaymentCardDetail {
        let m = PaymentCardDetail(id: "3x", brand: "ZALO", issueDate: nil, iconUrl: nil, number: nil, scheme: nil)
        return m
    }
    static func momo() -> PaymentCardDetail {
        let m = PaymentCardDetail(id: "4x", brand: "MOMO", issueDate: nil, iconUrl: nil, number: nil, scheme: nil)
        return m
    }
    
    static func credit() -> PaymentCardDetail {
        var m = PaymentCardDetail(id: "4x", brand: "Thẻ Visa/Master/JCB", issueDate: nil, iconUrl: nil, number: "5", scheme: nil)
        m.enable3d = true
        m.params = ["cardScheme" : "CreditCard", "deviceId": "phone", "environment": "MobileApp", "description": "ticket"]
        return m
    }
    static func atm() -> PaymentCardDetail {
        var m = PaymentCardDetail(id: "6x", brand: "Thẻ ATM", issueDate: nil, iconUrl: nil, number: "6", scheme: nil)
        m.params = ["cardScheme" : "AtmCard", "deviceId": "phone", "environment": "MobileApp", "description": "ticket"]
        return m
    }
}

extension PaymentCardDetail: Equatable {}

enum SwitchPaymentType {
    case service(service: VatoServiceType)
    case topupNapas
    case all
    case food
    
    func listTypeAllow() -> [PaymentCardType] {
        return [.cash, .vatoPay]
    }
    
    func isAllowAddNapas() -> Bool {
        return false
    }
}


protocol SwitchPaymentRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol SwitchPaymentPresentable: Presentable {
    var listener: SwitchPaymentPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol SwitchPaymentListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func switchPaymentMoveBack()
    func switchPaymentChoose(by card: PaymentCardDetail)
}

final class SwitchPaymentInteractor: PresentableInteractor<SwitchPaymentPresentable>, SwitchPaymentInteractable, SwitchPaymentPresentableListener {
    
    var source: Observable<[PaymentCardDetail]> {
        return $mSource
    }
    
    let currentSelect: PaymentCardDetail
    weak var router: SwitchPaymentRouting?
    weak var listener: SwitchPaymentListener?
    @Replay(queue: MainScheduler.asyncInstance) private var mSource: [PaymentCardDetail]
    private lazy var mError: PublishSubject<Error> = PublishSubject()
    

    var error: Observable<Error> {
        return mError.observeOn(MainScheduler.asyncInstance)
    }
    
    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
     init(presenter: SwitchPaymentPresentable, currentSelect: PaymentCardDetail) {
        self.currentSelect = currentSelect
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        self.setupRX()
        // todo: Implement business logic here.
    }
    
    private func setupRX() {
        mSource = [.cash(), .vatoPay()]
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    func switchPaymentMoveBack() {
        self.listener?.switchPaymentMoveBack()
    }
    
    func switchPaymentSelect(at idx: IndexPath) {
        $mSource.take(1).subscribe(onNext: { [weak self] list in
            let select = list[safe: idx.item]
            self?.switchPaymentChoose(by: select)
        }).disposeOnDeactivate(interactor: self)
    }
    
    private func switchPaymentChoose(by card: PaymentCardDetail?) {
        guard let card = card else { return }
        self.listener?.switchPaymentChoose(by: card)
    }
}
