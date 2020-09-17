/* 
Copyright (c) 2019 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct SalesOrderPayment : Codable {
//	let createdBy : Double?
//	let updatedBy : Double?
//	let createdAt : Double?
//	let updatedAt : Double?
	let id : String?
	let amountOrdered : Int?
	let amountPaid : Int?
	let amountRefunded : Int?
	let shippingAmount : Int?
	let paymentMethod : Int?
	let paymentMethodDes : String?
	let salesTransactionPayments : [SalesTransactionPayment]?

	enum CodingKeys: String, CodingKey {

//		case createdBy = "createdBy"
//		case updatedBy = "updatedBy"
//		case createdAt = "createdAt"
//		case updatedAt = "updatedAt"
		case id = "id"
		case amountOrdered = "amountOrdered"
		case amountPaid = "amountPaid"
		case amountRefunded = "amountRefunded"
		case shippingAmount = "shippingAmount"
		case paymentMethod = "paymentMethod"
		case paymentMethodDes = "paymentMethodDes"
		case salesTransactionPayments = "salesTransactionPayments"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
//		createdBy = try values.decodeIfPresent(Double.self, forKey: .createdBy)
//		updatedBy = try values.decodeIfPresent(Double.self, forKey: .updatedBy)
//		createdAt = try values.decodeIfPresent(Double.self, forKey: .createdAt)
//		updatedAt = try values.decodeIfPresent(Double.self, forKey: .updatedAt)
		id = try values.decodeIfPresent(String.self, forKey: .id)
		amountOrdered = try values.decodeIfPresent(Int.self, forKey: .amountOrdered)
		amountPaid = try values.decodeIfPresent(Int.self, forKey: .amountPaid)
		amountRefunded = try values.decodeIfPresent(Int.self, forKey: .amountRefunded)
		shippingAmount = try values.decodeIfPresent(Int.self, forKey: .shippingAmount)
		paymentMethod = try values.decodeIfPresent(Int.self, forKey: .paymentMethod)
		paymentMethodDes = try values.decodeIfPresent(String.self, forKey: .paymentMethodDes)
		salesTransactionPayments = try values.decodeIfPresent([SalesTransactionPayment].self, forKey: .salesTransactionPayments)
	}

}
