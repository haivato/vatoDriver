//
//  Product.swift
//  Vato
//
//  Created by khoi tran on 11/21/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import Atributika
import FwiCore

enum ProductType: String {
    case SIMPLE = "SIMPLE"
}

struct DisplayProductCategory: Codable {
    var name: String?
    var id: Int?
    var products: [DisplayProduct]?
}

struct DisplayProduct : Codable, Equatable, StoreProductDisplayProtocol, Hashable {
    var productId : Int?
    var productName : String?
    var productPrice : Double?
    var images : [String]?
    var productDescription : String?
    var productIsOpen : Bool?
    var category : Int?
    var sku : String?
    var specialPrice : Double?
    var finalPrice : Double?
    var isPromo : Bool?
    var specialFromDate : String?
    var specialToDate : String?
    var qty : Int?
    var status : Int?
    
    var name: String? {
        return productName
    }
    var price: Double? {
        return self.isAppliedSpecialPrice ? self.finalPrice : self.productPrice
    }
    var description: String? {
        return productDescription
    }
    var imageURL: String? {
        return images?.first
    }
    
    func hash(into hasher: inout Hasher) {
        hasher = Hasher()
        let id = productId ?? 0
        hasher.combine(id)
    }
    
    
    enum CodingKeys: String, CodingKey {
        
        case productId = "productId"
        case productName = "productName"
        case productPrice = "productPrice"
        case images = "images"
        case productDescription = "productDescription"
        case productIsOpen = "productIsOpen"
        case category = "category"
        case sku = "sku"
        case specialPrice = "specialPrice"
        case finalPrice = "finalPrice"
        case isPromo = "isPromo"
        case specialFromDate = "specialFromDate"
        case specialToDate = "specialToDate"
        case qty = "qty"
        case status = "status"
    }
    
    init() {}
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        productId = try values.decodeIfPresent(Int.self, forKey: .productId)
        productName = try values.decodeIfPresent(String.self, forKey: .productName)
        productPrice = try values.decodeIfPresent(Double.self, forKey: .productPrice)
        images = try values.decodeIfPresent([String].self, forKey: .images)
        productDescription = try values.decodeIfPresent(String.self, forKey: .productDescription)
        productIsOpen = try values.decodeIfPresent(Bool.self, forKey: .productIsOpen)
        category = try values.decodeIfPresent(Int.self, forKey: .category)
        sku = try values.decodeIfPresent(String.self, forKey: .sku)
        specialPrice = try values.decodeIfPresent(Double.self, forKey: .specialPrice)
        finalPrice = try values.decodeIfPresent(Double.self, forKey: .finalPrice)
        isPromo = try values.decodeIfPresent(Bool.self, forKey: .isPromo)
        specialFromDate = try values.decodeIfPresent(String.self, forKey: .specialFromDate)
        specialToDate = try values.decodeIfPresent(String.self, forKey: .specialToDate)
        qty = try values.decodeIfPresent(Int.self, forKey: .qty)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
    }
    
    static func == (lhs: DisplayProduct, rhs: DisplayProduct) -> Bool {
        return lhs.productId == rhs.productId
    }
    
    
    var isAppliedSpecialPrice: Bool {
        guard let specialFromDate = Date.date(from: self.specialFromDate, format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") else { return false }
        
        if let specialToDate = Date.date(from: self.specialToDate, format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") {

            let date = Date().toGMT()
            let result = specialFromDate > specialToDate ? false : specialFromDate...specialToDate ~= date
            let different = productPrice != finalPrice
            return result && different
            
        } else {
            return true
        }
    }
}

extension DisplayProduct {
    init?(order: OrderItem?) {
        guard let order = order else { return nil }
        var item = DisplayProduct()
        item.productId = order.productId
        item.productName = order.name
        item.productPrice = Double(order.basePrice ?? 0)
        var images: [String] = []
        images.addOptional(order.images)
        item.images = images
        item.finalPrice = Double(order.basePriceInclTax ?? 0)
        self = item
    }
    
    init(quoteItem: QuoteItem) {
        var item = DisplayProduct()
        var images: [String] = []
        images.addOptional(quoteItem.images?.trim())
        item.images = images
        item.productId = quoteItem.productId
        item.productName = quoteItem.name
        item.productPrice = quoteItem.basePrice
        item.finalPrice = quoteItem.basePriceInclTax ?? 0
        self = item
    }
}


protocol EcomDisplayProductProtocol {
    associatedtype Value
    var lblNote: UILabel? { get }
    func displayDetail(item: Value)
}

extension EcomDisplayProductProtocol {
    func display(productOptionDesription: String?,
                 note: String?,
                 product: DisplayProduct)
    {
        let s1 = productOptionDesription
        var s2 = ""
        if let t = note, !t.isEmpty {
            s2 = "\(FwiLocale.localized("Ghi chú")): \(t)"
        }
        var s3 = ""
//        if product.productPrice != product.finalPrice {
//            s3 = "<b>\(product.productPrice.orNil(0).currency)</b>"
//        }
        let final = String.makeStringWithoutEmpty(from: s1, s2, s3, seperator: "\n")
        let b = Atributika.Style("b").strikethroughStyle(.single)
        let p1 = NSMutableParagraphStyle()
        p1.alignment = .left
        p1.lineSpacing = 4
        let all = Atributika.Style()
            .font(.systemFont(ofSize: 13, weight: .regular))
            .foregroundColor(#colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1))
            .paragraphStyle(p1)
        let att = final.style(tags: b).styleAll(all).attributedString
        lblNote?.attributedText = att
    }
}

extension EcomDisplayProductProtocol where Value == OrderItem {
    func displayDetail(item: OrderItem) {
        let s = item.productOptions?.map(\.description).joined(separator: "\n")
        guard let product = DisplayProduct(order: item) else {
            return
        }
        self.display(productOptionDesription: s, note: item.description, product: product)
    }
}

extension EcomDisplayProductProtocol where Value == QuoteItem {
    func displayDetail(item: QuoteItem) {
        let product = DisplayProduct(quoteItem: item)
        let s = item.quoteItemOptions?.map(\.description).joined(separator: "\n")
        self.display(productOptionDesription: s, note: item.description, product: product)
    }
}

