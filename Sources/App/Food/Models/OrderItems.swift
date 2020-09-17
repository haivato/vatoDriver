

import UIKit
import FwiCore

struct ProductOption: Codable, Hashable, CustomStringConvertible {
    enum OptionValueType: String, Codable {
        case money = "MONEY"
        case percent = "PERCENT"
    }
    
    enum OptionValueSelectType: String, Codable {
        case radio = "RADIO"
        case checkbox = "CHECK_BOX"
        case field = "FIELD"
        
        var icon: (normal: UIImage?, highlight: UIImage?)? {
            switch self {
            case .radio:
                return (UIImage(named: "ic_uncheck"), UIImage(named: "ic_check"))
            case .checkbox:
                return (UIImage(named: "ic_radio_unchecked"), UIImage(named: "ic_radio_checked"))
            default:
                return (UIImage(named: "ic_checked_default"), nil)
            }
        }
        
        var multiSelect: Bool {
            switch self {
            case .radio:
                return false
            case .checkbox:
                return true
            default:
                return true
            }
        }
        
        var canSelect: Bool {
            switch self {
            case .field:
                return false
            default:
                return true
            }
        }
    }
    
    struct OptionValue: Codable, Hashable {
        var id: Int?
        var price: Double
        var priceType: OptionValueType?
        var title: String?
        
        func hash(into hasher: inout Hasher) {
            var new = Hasher()
            new.combine(id.orNil(0))
            hasher = new
        }
    }
    
    var id: Int?
    var isRequired: Bool = false
    var type: OptionValueSelectType = .radio
    var title: String?
    var productOptionTypeValues: [OptionValue]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case isRequired
        case type
        case title
        case productOptionTypeValues
    }
    
    var params: JSON {
        var p = JSON()
        p["optionId"] = id
        p["qty"] = 0
        var values = JSON()
        let v = productOptionTypeValues?.map { "\($0.id.orNil(0))" }.joined(separator: ",")
        values["valueId"] = v
        p["values"] = values
        return p
    }
    
    var totalPrice: Double {
        return productOptionTypeValues?.sum(of: \.price) ?? 0
    }
    
    var attributeRequire: NSAttributedString {
        let color = isRequired ? #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1) : #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        let text = isRequired ? FwiLocale.localized("Bắt buộc") : FwiLocale.localized("Không bắt buộc")
        let font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return text.attribute >>> .font(f: font) >>> .color(c: color)
    }
    
    var description: String {
        let s0 = title
        let s1 = productOptionTypeValues?.compactMap { $0.title }.joined(separator: ", ")
        return String.makeStringWithoutEmpty(from: s0, s1 , seperator: ": ")
    }
    
    func hash(into hasher: inout Hasher) {
        var new = Hasher()
        new.combine(id.orNil(0))
        let h = productOptionTypeValues?.hashValue
        new.combine(h.orNil(0))
        hasher = new
    }
}

struct QuoteOption: Codable, CustomStringConvertible {
    var id: String?
    var optionId: Int
    var optionTitle: String?
    var qty: Int
    var values: [ProductOption.OptionValue]
    
    var description: String {
        let s0 = optionTitle
        let s1 = values.compactMap { $0.title }.joined(separator: ", ")
        return String.makeStringWithoutEmpty(from: s0, s1 , seperator: ": ")
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case optionId
        case optionTitle
        case qty
        case values
    }
    
    private struct Temp: Codable {
        var valueData: String
        var data: Data? {
            let d = valueData.data(using: .utf8)
            return d
        }
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(String.self, forKey: .id)
        optionId = try c.decode(Int.self, forKey: .optionId)
        optionTitle = try c.decodeIfPresent(String.self, forKey: .optionTitle)
        qty = try c.decode(Int.self, forKey: .qty)
        let temp = try c.decodeIfPresent(Temp.self, forKey: .values)
        guard let data = temp?.data else {
            values = []
            return
        }
        if let items = try JSONSerialization.jsonObject(with: data, options: []) as? [JSON] {
            let result = try items.map { try ProductOption.OptionValue.toModel(from: $0) }
            values = result
        } else {
            values = []
        }
    }
}

struct OrderItem: Codable {
    let id: String?
    let amountRefunded: Int?
    let baseAmountRefunded: Int?
    let baseCost: Int?
    let baseDiscountAmount: Int?
    let baseDiscountInvoice: Int?
    let baseDiscountRefunded: Int?
    let baseOriginalPrice: Int?
    let basePrice: Double?
    let basePriceInclTax: Double?
    let baseRowInvoiced: Int?
    let baseRowTotal: Double?
    let baseRowTotalInclTax: Double?
    let baseTaxAmount: Int?
    let baseTaxBeforeDiscount: Int?
    let baseTaxInvoiced: Int?
    let baseTaxRefunded: Int?
    let description: String?
    let finalPrice: Int?
    let discountAmount: Int?
    let discountInvoiced: Int?
    let discountPercent: Int?
    let discountRefunded: Int?
    let storeId: Int?
    let qty: Int?
    let productId: Int?
    let name: String?
    let images: String?
    let nameStore: String?
    let addressStore: String?
    let phoneStore: String?
    let available: Bool?
    let salesOrderItemOptions : String?
    let basePriceFinal: Double?
    let basePriceIncltaxFinal: Double?
//    let createdBy: Double?
//    let updatedBy: Double?
//    let createdAt: String?
//    let updatedAt: String?
    
    var productOptions: [QuoteOption]?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case amountRefunded = "amountRefunded"
        case baseAmountRefunded = "baseAmountRefunded"
        case baseCost = "baseCost"
        case baseDiscountAmount = "baseDiscountAmount"
        case baseDiscountInvoice = "baseDiscountInvoice"
        case baseDiscountRefunded = "baseDiscountRefunded"
        case baseOriginalPrice = "baseOriginalPrice"
        case basePrice = "basePrice"
        case basePriceInclTax = "basePriceInclTax"
        case baseRowInvoiced = "baseRowInvoiced"
        case baseRowTotal = "baseRowTotal"
        case baseRowTotalInclTax = "baseRowTotalInclTax"
        case baseTaxAmount = "baseTaxAmount"
        case baseTaxBeforeDiscount = "baseTaxBeforeDiscount"
        case baseTaxInvoiced = "baseTaxInvoiced"
        case baseTaxRefunded = "baseTaxRefunded"
        case description = "description"
        case finalPrice = "finalPrice"
        case discountAmount = "discountAmount"
        case discountInvoiced = "discountInvoiced"
        case discountPercent = "discountPercent"
        case discountRefunded = "discountRefunded"
        case storeId = "storeId"
        case qty = "qty"
        case productId = "productId"
        case name = "name"
        case images = "images"
        case nameStore = "nameStore"
        case addressStore = "addressStore"
        case phoneStore = "phoneStore"
        case available = "available"
        case salesOrderItemOptions
        case basePriceFinal
        case basePriceIncltaxFinal
//        case createdBy = "createdBy"
//        case updatedBy = "updatedBy"
//        case createdAt = "createdAt"
//        case updatedAt = "updatedAt"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        amountRefunded = try values.decodeIfPresent(Int.self, forKey: .amountRefunded)
        baseAmountRefunded = try values.decodeIfPresent(Int.self, forKey: .baseAmountRefunded)
        baseCost = try values.decodeIfPresent(Int.self, forKey: .baseCost)
        baseDiscountAmount = try values.decodeIfPresent(Int.self, forKey: .baseDiscountAmount)
        baseDiscountInvoice = try values.decodeIfPresent(Int.self, forKey: .baseDiscountInvoice)
        baseDiscountRefunded = try values.decodeIfPresent(Int.self, forKey: .baseDiscountRefunded)
        baseOriginalPrice = try values.decodeIfPresent(Int.self, forKey: .baseOriginalPrice)
        basePrice = try values.decodeIfPresent(Double.self, forKey: .basePrice)
        basePriceInclTax = try values.decodeIfPresent(Double.self, forKey: .basePriceInclTax)
        baseRowInvoiced = try values.decodeIfPresent(Int.self, forKey: .baseRowInvoiced)
        baseRowTotal = try values.decodeIfPresent(Double.self, forKey: .baseRowTotal)
        baseRowTotalInclTax = try values.decodeIfPresent(Double.self, forKey: .baseRowTotalInclTax)
        baseTaxAmount = try values.decodeIfPresent(Int.self, forKey: .baseTaxAmount)
        baseTaxBeforeDiscount = try values.decodeIfPresent(Int.self, forKey: .baseTaxBeforeDiscount)
        baseTaxInvoiced = try values.decodeIfPresent(Int.self, forKey: .baseTaxInvoiced)
        baseTaxRefunded = try values.decodeIfPresent(Int.self, forKey: .baseTaxRefunded)
        finalPrice = try values.decodeIfPresent(Int.self, forKey: .finalPrice)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        discountAmount = try values.decodeIfPresent(Int.self, forKey: .discountAmount)
        discountInvoiced = try values.decodeIfPresent(Int.self, forKey: .discountInvoiced)
        discountPercent = try values.decodeIfPresent(Int.self, forKey: .discountPercent)
        discountRefunded = try values.decodeIfPresent(Int.self, forKey: .discountRefunded)
        storeId = try values.decodeIfPresent(Int.self, forKey: .storeId)
        qty = try values.decodeIfPresent(Int.self, forKey: .qty)
        productId = try values.decodeIfPresent(Int.self, forKey: .productId)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        images = try values.decodeIfPresent(String.self, forKey: .images)
        nameStore = try values.decodeIfPresent(String.self, forKey: .nameStore)
        addressStore = try values.decodeIfPresent(String.self, forKey: .addressStore)
        phoneStore = try values.decodeIfPresent(String.self, forKey: .phoneStore)
        available = try values.decodeIfPresent(Bool.self, forKey: .available)
        basePriceFinal = try values.decodeIfPresent(Double.self, forKey: .basePriceFinal)
        basePriceIncltaxFinal = try values.decodeIfPresent(Double.self, forKey: .basePriceIncltaxFinal)
        salesOrderItemOptions = try values.decodeIfPresent(String.self, forKey: .salesOrderItemOptions)
//        createdBy = try values.decodeIfPresent(Double.self, forKey: .createdBy)
//        updatedBy = try values.decodeIfPresent(Double.self, forKey: .updatedBy)
//        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
//        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        
        guard let d = salesOrderItemOptions?.data(using: .utf8) else {
            return
        }
        do {
            let jsons = try JSONSerialization.jsonObject(with: d, options: []) as? [JSON]
            let news = try jsons?.map { try QuoteOption.toModel(from: $0) }
            productOptions = news
        } catch {
            #if DEBUG
               assert(false, error.localizedDescription)
            #endif
        }
    }
    
}


struct FoodOderModel: Codable {
    let id: String?
    let code: String?
    let orderItems: [OrderItem]?
    let grandTotal: Double?
    let feeShip: Double?
    let discountAmount: Double?
    let discountShippingFee: Double?
    let createdAt: String?
    let customerNote: String?
    let baseGrandTotal: Double?
    let merchantFinalPrice: Double?
    let vatoAppliedRuleIds: String?
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case code = "code"
        case orderItems = "orderItems"
        case grandTotal = "grandTotal"
        case feeShip = "feeShip"
        case discountAmount = "discountAmount"
        case discountShippingFee = "discountShippingFee"
        case createdAt = "createdAt"
        case customerNote = "customerNote"
        case baseGrandTotal = "baseGrandTotal"
        case merchantFinalPrice = "merchantFinalPrice"
        case vatoAppliedRuleIds = "vatoAppliedRuleIds"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        code = try values.decodeIfPresent(String.self, forKey: .code)
        orderItems = try values.decodeIfPresent([OrderItem].self, forKey: .orderItems)
        grandTotal = try values.decodeIfPresent(Double.self, forKey: .grandTotal)
        feeShip = try values.decodeIfPresent(Double.self, forKey: .feeShip)
        discountAmount = try values.decodeIfPresent(Double.self, forKey: .discountAmount)
        discountShippingFee = try values.decodeIfPresent(Double.self, forKey: .discountShippingFee)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        customerNote = try values.decodeIfPresent(String.self, forKey: .customerNote)
        baseGrandTotal = try values.decodeIfPresent(Double.self, forKey: .baseGrandTotal)
        merchantFinalPrice = try values.decodeIfPresent(Double.self, forKey: .merchantFinalPrice)
        vatoAppliedRuleIds = try values.decodeIfPresent(String.self, forKey: .vatoAppliedRuleIds)
        
    }
    
    static func decodeFromString(string: String?) -> FoodOderModel? {
        guard let string = string else { return nil }
        if let data = string.data(using: .utf8) {
            do {
                return try JSONDecoder().decode(FoodOderModel.self, from: data)
            } catch let err {
                print(err.localizedDescription)
            }
            
        }
        return nil
    }
    var getPrice: Double? {
        guard let grandTotal = self.baseGrandTotal else {
            return nil
        }
        
        guard let feeShip = self.feeShip else {
            return grandTotal
        }
        
        return grandTotal - feeShip
    }
    var discountPromtion: Double? {
        if self.vatoAppliedRuleIds != nil {
            return 0
        }
        return self.discountAmount
    }
}

