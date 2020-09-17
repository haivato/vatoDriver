/* 
Copyright (c) 2019 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct SalesOrderStatusHistory : Codable {
//	let createdBy : Double?
//	let updatedBy : Double?
//	let createdAt : Double?
//	let updatedAt : Double?
	let id : String?
	let comment : String?
	let customerNotified : Bool?
	let visibleOnFront : Bool?
	let status : Int?
	let state : Int?
	let statusDes : String?
	let stateDes : String?

	enum CodingKeys: String, CodingKey {

//		case createdBy = "createdBy"
//		case updatedBy = "updatedBy"
//		case createdAt = "createdAt"
//		case updatedAt = "updatedAt"
		case id = "id"
		case comment = "comment"
		case customerNotified = "customerNotified"
		case visibleOnFront = "visibleOnFront"
		case status = "status"
		case state = "state"
		case statusDes = "statusDes"
		case stateDes = "stateDes"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
//		createdBy = try values.decodeIfPresent(Double.self, forKey: .createdBy)
//		updatedBy = try values.decodeIfPresent(Double.self, forKey: .updatedBy)
//		createdAt = try values.decodeIfPresent(Double.self, forKey: .createdAt)
//		updatedAt = try values.decodeIfPresent(Double.self, forKey: .updatedAt)
		id = try values.decodeIfPresent(String.self, forKey: .id)
		comment = try values.decodeIfPresent(String.self, forKey: .comment)
		customerNotified = try values.decodeIfPresent(Bool.self, forKey: .customerNotified)
		visibleOnFront = try values.decodeIfPresent(Bool.self, forKey: .visibleOnFront)
		status = try values.decodeIfPresent(Int.self, forKey: .status)
		state = try values.decodeIfPresent(Int.self, forKey: .state)
		statusDes = try values.decodeIfPresent(String.self, forKey: .statusDes)
		stateDes = try values.decodeIfPresent(String.self, forKey: .stateDes)
	}

}
