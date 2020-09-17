/* 
Copyright (c) 2019 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct QuoteShipment : Codable {
	let createdAt : Double?
	let createdBy : Double?
	let discountAmount : Int?
	let id : String?
	let method : Int?
	let methodDesc : String?
	let methodTitle : String?
	let price : Int?
	let specialPrice : Int?
	let updatedAt : Int?
	let updatedBy : Int?

	enum CodingKeys: String, CodingKey {

		case createdAt = "createdAt"
		case createdBy = "createdBy"
		case discountAmount = "discountAmount"
		case id = "id"
		case method = "method"
		case methodDesc = "methodDesc"
		case methodTitle = "methodTitle"
		case price = "price"
		case specialPrice = "specialPrice"
		case updatedAt = "updatedAt"
		case updatedBy = "updatedBy"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		createdAt = try values.decodeIfPresent(Double.self, forKey: .createdAt)
		createdBy = try values.decodeIfPresent(Double.self, forKey: .createdBy)
		discountAmount = try values.decodeIfPresent(Int.self, forKey: .discountAmount)
		id = try values.decodeIfPresent(String.self, forKey: .id)
		method = try values.decodeIfPresent(Int.self, forKey: .method)
		methodDesc = try values.decodeIfPresent(String.self, forKey: .methodDesc)
		methodTitle = try values.decodeIfPresent(String.self, forKey: .methodTitle)
		price = try values.decodeIfPresent(Int.self, forKey: .price)
		specialPrice = try values.decodeIfPresent(Int.self, forKey: .specialPrice)
		updatedAt = try values.decodeIfPresent(Int.self, forKey: .updatedAt)
		updatedBy = try values.decodeIfPresent(Int.self, forKey: .updatedBy)
	}

}
