/* 
Copyright (c) 2020 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
enum QuickSupportModelType: Int, Codable {
    case home
    case detail
}
struct QuickSupportModel : Codable {
    
    var id : String?
    var title : String?
    var content : String?
    var createdAt : Date?
    var status : QuickSupportStatus?
    var code : String?
    var images : [String]?
    var lastComment: QuickSupportItemResponse?
    var numberOfUnread: Int?
    
    var type: QuickSupportModelType?
	var response : [QuickSupportItemResponse]?

	enum CodingKeys: String, CodingKey {
		case response = "response"
        case id = "id"
        case title = "title"
        case content = "content"
        case createdAt = "createdAt"
        case status = "status"
        case code = "code"
        case images = "images"
        case lastComment = "lastComment"
        case numberOfUnread = "numberOfUnread"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		response = try values.decodeIfPresent([QuickSupportItemResponse].self, forKey: .response)

        id = try values.decodeIfPresent(String.self, forKey: .id)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        content = try values.decodeIfPresent(String.self, forKey: .content)
        createdAt = try values.decodeIfPresent(Date.self, forKey: .createdAt)
        status = try values.decodeIfPresent(QuickSupportStatus.self, forKey: .status)
        code = try values.decodeIfPresent(String.self, forKey: .code)
        images = try values.decodeIfPresent([String].self, forKey: .images)
        lastComment = try values.decodeIfPresent(QuickSupportItemResponse.self, forKey: .lastComment)
        numberOfUnread = try values.decodeIfPresent(Int.self, forKey: .numberOfUnread)
	}
    
    
    init() {}

}
