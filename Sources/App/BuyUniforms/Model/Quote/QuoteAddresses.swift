/* 
Copyright (c) 2019 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct QuoteAddresses : Codable {
	let createdBy : Double?
	let updatedBy : Double?
	let createdAt : Double?
	let updatedAt : Double?
	let id : String?
	let address : String?
	let zoneName : String?
	let zoneId : Int?
	let lat : Double?
	let lon : Double?
	let customerId : Int?
	let customerNotes : String?
	let baseDiscountAmount : Double?
	let baseGrandTotal : Double?
	let baseShippingAmount : Double?
	let baseShippingInclTax : Double?
	let baseShippingTaxAmount : Double?
	let baseSubTotal : Double?
	let baseSubTotalInclTax : Double?
	let baseSubTotalWithDiscount : Double?
	let baseTaxAmount : Double?
	let discountAmount : Double?
	let discountDesc : String?
	let email : String?
	let phone : String?

	enum CodingKeys: String, CodingKey {

		case createdBy = "createdBy"
		case updatedBy = "updatedBy"
		case createdAt = "createdAt"
		case updatedAt = "updatedAt"
		case id = "id"
		case address = "address"
		case zoneName = "zoneName"
		case zoneId = "zoneId"
		case lat = "lat"
		case lon = "lon"
		case customerId = "customerId"
		case customerNotes = "customerNotes"
		case baseDiscountAmount = "baseDiscountAmount"
		case baseGrandTotal = "baseGrandTotal"
		case baseShippingAmount = "baseShippingAmount"
		case baseShippingInclTax = "baseShippingInclTax"
		case baseShippingTaxAmount = "baseShippingTaxAmount"
		case baseSubTotal = "baseSubTotal"
		case baseSubTotalInclTax = "baseSubTotalInclTax"
		case baseSubTotalWithDiscount = "baseSubTotalWithDiscount"
		case baseTaxAmount = "baseTaxAmount"
		case discountAmount = "discountAmount"
		case discountDesc = "discountDesc"
		case email = "email"
		case phone = "phone"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		createdBy = try values.decodeIfPresent(Double.self, forKey: .createdBy)
		updatedBy = try values.decodeIfPresent(Double.self, forKey: .updatedBy)
		createdAt = try values.decodeIfPresent(Double.self, forKey: .createdAt)
		updatedAt = try values.decodeIfPresent(Double.self, forKey: .updatedAt)
		id = try values.decodeIfPresent(String.self, forKey: .id)
		address = try values.decodeIfPresent(String.self, forKey: .address)
		zoneName = try values.decodeIfPresent(String.self, forKey: .zoneName)
		zoneId = try values.decodeIfPresent(Int.self, forKey: .zoneId)
		lat = try values.decodeIfPresent(Double.self, forKey: .lat)
		lon = try values.decodeIfPresent(Double.self, forKey: .lon)
		customerId = try values.decodeIfPresent(Int.self, forKey: .customerId)
		customerNotes = try values.decodeIfPresent(String.self, forKey: .customerNotes)
		baseDiscountAmount = try values.decodeIfPresent(Double.self, forKey: .baseDiscountAmount)
		baseGrandTotal = try values.decodeIfPresent(Double.self, forKey: .baseGrandTotal)
		baseShippingAmount = try values.decodeIfPresent(Double.self, forKey: .baseShippingAmount)
		baseShippingInclTax = try values.decodeIfPresent(Double.self, forKey: .baseShippingInclTax)
		baseShippingTaxAmount = try values.decodeIfPresent(Double.self, forKey: .baseShippingTaxAmount)
		baseSubTotal = try values.decodeIfPresent(Double.self, forKey: .baseSubTotal)
		baseSubTotalInclTax = try values.decodeIfPresent(Double.self, forKey: .baseSubTotalInclTax)
		baseSubTotalWithDiscount = try values.decodeIfPresent(Double.self, forKey: .baseSubTotalWithDiscount)
		baseTaxAmount = try values.decodeIfPresent(Double.self, forKey: .baseTaxAmount)
		discountAmount = try values.decodeIfPresent(Double.self, forKey: .discountAmount)
		discountDesc = try values.decodeIfPresent(String.self, forKey: .discountDesc)
		email = try values.decodeIfPresent(String.self, forKey: .email)
		phone = try values.decodeIfPresent(String.self, forKey: .phone)
	}

}
