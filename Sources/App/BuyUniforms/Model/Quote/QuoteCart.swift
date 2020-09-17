/* 
Copyright (c) 2019 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct QuoteCart : Codable {
	let createdBy : Double?
	let updatedBy : Double?
	let createdAt : Double?
	let updatedAt : Double?
	let id : String?
	let baseGrandTotal : Double?
	let baseSubTotal : Double?
	let baseSubTotalWithDiscount : Double?
	let quoteCoupons : [String]?
	let quotePayments : [QuotePayments]?
	let customerId : Int?
	let grandTotal : Double?
	let active : Bool?
	let changed : Bool?
	let persistent : Bool?
	let discountAmount : Double?
	let itemsCount : Int?
	let itemsQty : Int?
	let storeId : Int?
	let reservedOderId : String?
	let subTotal : Double?
	let subTotalWithDiscount : Double?
	let convertedAt : String?
	let appliedRuleIds : String?
	let timePickup : Double?
	let quoteItems : [QuoteItem]?
	let quoteShipments : [QuoteShipment]?
	let quoteAddresses : [QuoteAddresses]?

	enum CodingKeys: String, CodingKey {

		case createdBy = "createdBy"
		case updatedBy = "updatedBy"
		case createdAt = "createdAt"
		case updatedAt = "updatedAt"
		case id = "id"
		case baseGrandTotal = "baseGrandTotal"
		case baseSubTotal = "baseSubTotal"
		case baseSubTotalWithDiscount = "baseSubTotalWithDiscount"
		case quoteCoupons = "quoteCoupons"
		case quotePayments = "quotePayments"
		case customerId = "customerId"
		case grandTotal = "grandTotal"
		case active = "active"
		case changed = "changed"
		case persistent = "persistent"
		case discountAmount = "discountAmount"
		case itemsCount = "itemsCount"
		case itemsQty = "itemsQty"
		case storeId = "storeId"
		case reservedOderId = "reservedOderId"
		case subTotal = "subTotal"
		case subTotalWithDiscount = "subTotalWithDiscount"
		case convertedAt = "convertedAt"
		case appliedRuleIds = "appliedRuleIds"
		case timePickup = "timePickup"
		case quoteItems = "quoteItems"
		case quoteShipments = "quoteShipments"
		case quoteAddresses = "quoteAddresses"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		createdBy = try values.decodeIfPresent(Double.self, forKey: .createdBy)
		updatedBy = try values.decodeIfPresent(Double.self, forKey: .updatedBy)
		createdAt = try values.decodeIfPresent(Double.self, forKey: .createdAt)
		updatedAt = try values.decodeIfPresent(Double.self, forKey: .updatedAt)
		id = try values.decodeIfPresent(String.self, forKey: .id)
		baseGrandTotal = try values.decodeIfPresent(Double.self, forKey: .baseGrandTotal)
		baseSubTotal = try values.decodeIfPresent(Double.self, forKey: .baseSubTotal)
		baseSubTotalWithDiscount = try values.decodeIfPresent(Double.self, forKey: .baseSubTotalWithDiscount)
		quoteCoupons = try values.decodeIfPresent([String].self, forKey: .quoteCoupons)
		quotePayments = try values.decodeIfPresent([QuotePayments].self, forKey: .quotePayments)
		customerId = try values.decodeIfPresent(Int.self, forKey: .customerId)
		grandTotal = try values.decodeIfPresent(Double.self, forKey: .grandTotal)
		active = try values.decodeIfPresent(Bool.self, forKey: .active)
		changed = try values.decodeIfPresent(Bool.self, forKey: .changed)
		persistent = try values.decodeIfPresent(Bool.self, forKey: .persistent)
		discountAmount = try values.decodeIfPresent(Double.self, forKey: .discountAmount)
		itemsCount = try values.decodeIfPresent(Int.self, forKey: .itemsCount)
		itemsQty = try values.decodeIfPresent(Int.self, forKey: .itemsQty)
		storeId = try values.decodeIfPresent(Int.self, forKey: .storeId)
		reservedOderId = try values.decodeIfPresent(String.self, forKey: .reservedOderId)
		subTotal = try values.decodeIfPresent(Double.self, forKey: .subTotal)
		subTotalWithDiscount = try values.decodeIfPresent(Double.self, forKey: .subTotalWithDiscount)
		convertedAt = try values.decodeIfPresent(String.self, forKey: .convertedAt)
		appliedRuleIds = try values.decodeIfPresent(String.self, forKey: .appliedRuleIds)
		timePickup = try values.decodeIfPresent(Double.self, forKey: .timePickup)
		quoteItems = try values.decodeIfPresent([QuoteItem].self, forKey: .quoteItems)
		quoteShipments = try values.decodeIfPresent([QuoteShipment].self, forKey: .quoteShipments)
		quoteAddresses = try values.decodeIfPresent([QuoteAddresses].self, forKey: .quoteAddresses)
	}

}


extension QuoteCart: Equatable {
    static func == (lhs: QuoteCart, rhs: QuoteCart) -> Bool {
        return lhs.id == rhs.id
    }
}
