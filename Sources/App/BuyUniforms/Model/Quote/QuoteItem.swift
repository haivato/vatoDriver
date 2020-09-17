/* 
Copyright (c) 2019 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct QuoteItem : Codable, Equatable {
	let createdBy : Double?
	let updatedBy : Double?
	let createdAt : Double?
	let updatedAt : Double?
	let id : String?
	let name : String?
	let baseDiscountAmount : Double?
	let basePrice : Double?
	let basePriceInclTax : Double?
	let baseTaxAmount : Double?
	let baseTaxBeforeDiscount : Double?
	let price : Double?
	let priceInclTax : Double?
	let description : String?
	let discountAmount : Double?
	let discountPercent : Double?
	let freeShipping : Bool?
	let qty : Int?
	let storeId : Int?
	let productId : Int?
	let available : Bool?
	let appliedRuleIds : String?
	let quoteItemOptions : [String]?
    let images: String?

	enum CodingKeys: String, CodingKey {

		case createdBy = "createdBy"
		case updatedBy = "updatedBy"
		case createdAt = "createdAt"
		case updatedAt = "updatedAt"
		case id = "id"
		case name = "name"
		case baseDiscountAmount = "baseDiscountAmount"
		case basePrice = "basePrice"
		case basePriceInclTax = "basePriceInclTax"
		case baseTaxAmount = "baseTaxAmount"
		case baseTaxBeforeDiscount = "baseTaxBeforeDiscount"
		case price = "price"
		case priceInclTax = "priceInclTax"
		case description = "description"
		case discountAmount = "discountAmount"
		case discountPercent = "discountPercent"
		case freeShipping = "freeShipping"
		case qty = "qty"
		case storeId = "storeId"
		case productId = "productId"
		case available = "available"
		case appliedRuleIds = "appliedRuleIds"
		case quoteItemOptions = "quoteItemOptions"
        case images
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		createdBy = try values.decodeIfPresent(Double.self, forKey: .createdBy)
		updatedBy = try values.decodeIfPresent(Double.self, forKey: .updatedBy)
		createdAt = try values.decodeIfPresent(Double.self, forKey: .createdAt)
		updatedAt = try values.decodeIfPresent(Double.self, forKey: .updatedAt)
		id = try values.decodeIfPresent(String.self, forKey: .id)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		baseDiscountAmount = try values.decodeIfPresent(Double.self, forKey: .baseDiscountAmount)
		basePrice = try values.decodeIfPresent(Double.self, forKey: .basePrice)
		basePriceInclTax = try values.decodeIfPresent(Double.self, forKey: .basePriceInclTax)
		baseTaxAmount = try values.decodeIfPresent(Double.self, forKey: .baseTaxAmount)
		baseTaxBeforeDiscount = try values.decodeIfPresent(Double.self, forKey: .baseTaxBeforeDiscount)
		price = try values.decodeIfPresent(Double.self, forKey: .price)
		priceInclTax = try values.decodeIfPresent(Double.self, forKey: .priceInclTax)
		description = try values.decodeIfPresent(String.self, forKey: .description)
		discountAmount = try values.decodeIfPresent(Double.self, forKey: .discountAmount)
		discountPercent = try values.decodeIfPresent(Double.self, forKey: .discountPercent)
		freeShipping = try values.decodeIfPresent(Bool.self, forKey: .freeShipping)
		qty = try values.decodeIfPresent(Int.self, forKey: .qty)
		storeId = try values.decodeIfPresent(Int.self, forKey: .storeId)
		productId = try values.decodeIfPresent(Int.self, forKey: .productId)
		available = try values.decodeIfPresent(Bool.self, forKey: .available)
		appliedRuleIds = try values.decodeIfPresent(String.self, forKey: .appliedRuleIds)
		quoteItemOptions = try values.decodeIfPresent([String].self, forKey: .quoteItemOptions)
        images = try values.decodeIfPresent(String.self, forKey: .images)
	}

    static func == (lhs: QuoteItem, rhs: QuoteItem) -> Bool {
        return lhs.id == rhs.id
    }
}
