/* 
Copyright (c) 2020 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
enum QuickSupportItemResponseType: Int, Codable {
    case vato = 1
    case user = 2
}

struct QuickSupportItemResponse : Codable {
    struct FeedBackUser: Codable {
        var avatarUrl: String?
        var fullName: String?
        var phone: String?
        var id: Int?
        
        enum CodingKeys: String, CodingKey {
            case avatarUrl = "avatarUrl"
            case fullName = "fullName"
            case phone = "phone"
            case id = "id"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decodeIfPresent(Int.self, forKey: .id)
            phone = try values.decodeIfPresent(String.self, forKey: .phone)
            fullName = try values.decodeIfPresent(String.self, forKey: .fullName)
            avatarUrl = try values.decodeIfPresent(String.self, forKey: .avatarUrl)
            fullName = try values.decodeIfPresent(String.self, forKey: .fullName)
        }
    }
    
    var id : String?
    var read: Int?
    var type : QuickSupportItemResponseType?
    var content : String?
    var createdAt: Date?
    var fullName: String? {
        return feedBackUser?.fullName
    }
    var feedBackUser: FeedBackUser?
    var avatarUrl: String? {
        return feedBackUser?.avatarUrl
    }
    var isSupporter: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case content = "content"
        case createdAt = "createdAt"
        case read = "read"
        case feedBackUser = "user"
        case isSupporter = "isSupporter"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        type = try values.decodeIfPresent(QuickSupportItemResponseType.self, forKey: .type)
        content = try values.decodeIfPresent(String.self, forKey: .content)
        createdAt = try values.decodeIfPresent(Date.self, forKey: .createdAt)
        read = try values.decodeIfPresent(Int.self, forKey: .read)
        feedBackUser = try values.decodeIfPresent(FeedBackUser.self, forKey: .feedBackUser)
        isSupporter = try values.decodeIfPresent(Int.self, forKey: .isSupporter)
    }
    
    func wasRead() -> Bool {
        return (self.read == 1)
    }
    
    func fromSupporter() -> Bool {
        let currentUserId = UserManager.shared.getUserId() ?? 0
        let isMessageFromsupporter = ((self.isSupporter == 1) && (feedBackUser?.id != currentUserId))
        return isMessageFromsupporter
    }
}
