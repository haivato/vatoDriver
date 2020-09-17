/* 
Copyright (c) 2019 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct SalesTransactionPayment : Codable {
	let createdBy : Double?
	let updatedBy : Double?
	let createdAt : Double?
	let updatedAt : Double?
	let id : String?
	let transactionTime : Double?
	let fromId : Int?
	let toId : Int?
	let type : String?
	let balance : String?
	let status : Int?
	let referId : String?
	let amount : Int?
	let description : String?
	let information : String?

	enum CodingKeys: String, CodingKey {

		case createdBy = "createdBy"
		case updatedBy = "updatedBy"
		case createdAt = "createdAt"
		case updatedAt = "updatedAt"
		case id = "id"
		case transactionTime = "transactionTime"
		case fromId = "fromId"
		case toId = "toId"
		case type = "type"
		case balance = "balance"
		case status = "status"
		case referId = "referId"
		case amount = "amount"
		case description = "description"
		case information = "information"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		createdBy = try values.decodeIfPresent(Double.self, forKey: .createdBy)
		updatedBy = try values.decodeIfPresent(Double.self, forKey: .updatedBy)
		createdAt = try values.decodeIfPresent(Double.self, forKey: .createdAt)
		updatedAt = try values.decodeIfPresent(Double.self, forKey: .updatedAt)
		id = try values.decodeIfPresent(String.self, forKey: .id)
		transactionTime = try values.decodeIfPresent(Double.self, forKey: .transactionTime)
		fromId = try values.decodeIfPresent(Int.self, forKey: .fromId)
		toId = try values.decodeIfPresent(Int.self, forKey: .toId)
		type = try values.decodeIfPresent(String.self, forKey: .type)
		balance = try values.decodeIfPresent(String.self, forKey: .balance)
		status = try values.decodeIfPresent(Int.self, forKey: .status)
		referId = try values.decodeIfPresent(String.self, forKey: .referId)
		amount = try values.decodeIfPresent(Int.self, forKey: .amount)
		description = try values.decodeIfPresent(String.self, forKey: .description)
		information = try values.decodeIfPresent(String.self, forKey: .information)
	}

}
