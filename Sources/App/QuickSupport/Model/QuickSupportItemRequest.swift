/* 
Copyright (c) 2020 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
enum QuickSupportStatus: Int, Codable {
    /*
     {0: đang chờ xử lý, 1: đã xử lý, 2: từ chối, 3: treo}
     */
    case processing = 0
    case complete = 1
    case reject = 2
    case pending = 3

    func string() -> String {
        switch self {
        case .processing:
            return "Đang xử lý"
        case .complete:
            return "Hoàn thành"
        case .reject:
            return "Từ chối"
        case .pending:
            return "Đang xử lý"
        }
    }
    
    func titleColor() -> UIColor {
        switch self {
        case .processing:
            return #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
        case .complete:
            return #colorLiteral(red: 0.2980392157, green: 0.7098039216, blue: 0.03137254902, alpha: 1)
        case .reject:
            return #colorLiteral(red: 0.8823529412, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
        case .pending:
            return #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
        }
    }
    
    func bgColor() -> UIColor {
        switch self {
        case .processing:
            return #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 0.2)
        case .complete:
            return #colorLiteral(red: 0.2980392157, green: 0.7098039216, blue: 0.03137254902, alpha: 0.2)
        case .reject:
            return #colorLiteral(red: 0.8823529412, green: 0.1411764706, blue: 0.1411764706, alpha: 0.2)
        case .pending:
            return #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 0.2)
        }
    }
    
    func isFinishStatus() -> Bool {
        switch self {
        case .complete, .reject, .pending:
            return true
        default:
            return false
        }
    }
}

struct QuickSupportItemRequest : Codable {
	let id : Int?
	let title : String?
	let description : String?
    let createdAt : Double?
	let status : QuickSupportStatus?
	let code : String?
	let images : [String]?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case title = "title"
		case description = "description"
		case createdAt = "createdAt"
		case status = "status"
		case code = "code"
		case images = "images"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		title = try values.decodeIfPresent(String.self, forKey: .title)
		description = try values.decodeIfPresent(String.self, forKey: .description)
		createdAt = try values.decodeIfPresent(Double.self, forKey: .createdAt)
		status = try values.decodeIfPresent(QuickSupportStatus.self, forKey: .status)
		code = try values.decodeIfPresent(String.self, forKey: .code)
		images = try values.decodeIfPresent([String].self, forKey: .images)
	}

}
