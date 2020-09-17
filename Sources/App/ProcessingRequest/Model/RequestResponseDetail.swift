//
//  RequestResponseDetail.swift
//  FC
//
//  Created by MacbookPro on 4/7/20.
//  Copyright © 2020 Vato. All rights reserved.
//

//struct RequestResponseDetail: Codable {
//    var id: Int?
//    var content: String?
//    var status: ProcessRequestType
//    let user: UserRequest?
//    let feedback: Feedback?
//    let createdBy, updatedBy: Int?
//    let createdAt, updatedAt: Int?
//    let requestTypeId: String?
//    var requestTypeName: String?
//    let zoneID: String?
//    let appVersion: Int?
//
//    enum CodingKeys: String, CodingKey {
//        case id, content, status, user, feedback
//        case createdBy = "created_by"
//        case updatedBy = "updated_by"
//        case createdAt = "created_at"
//        case updatedAt = "updated_at"
//        case requestTypeId = "request_type_id"
//        case requestTypeName = "request_type_name"
//        case zoneID = "zone_id"
//        case appVersion = "app_version"
//    }
//}
//
//struct UserRequest: Codable {
//    let id: Int
//    let phone, firebaseID, fullName: String?
//    let avatar: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id, phone
//        case firebaseID = "firebase_id"
//        case fullName = "full_name"
//        case avatar
//    }
//}
//
//struct Feedback: Codable {
//    let id: Int
//    let user: UserRequest
//    let userRequestID: Int
//    let content, status, createdAt: String
//
//    enum CodingKeys: String, CodingKey {
//        case id, user
//        case userRequestID = "user_request_id"
//        case content, status
//        case createdAt = "created_at"
//    }
//}

struct RequestResponseDetail: Codable {
    var id: Int?
    var content: String?
    var status: ProcessRequestType
    let user: UserRequest?
    let feedback: Feedback?
    let createdBy, updatedBy, createdAt, updatedAt: Double?
    let requestTypeId: String?
    var requestTypeName: String?
    let zoneID: Int?
    let appVersion: String?

    enum CodingKeys: String, CodingKey {
        case id, content, status, user, feedback
        case createdBy = "created_by"
        case updatedBy = "updated_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case requestTypeId = "request_type_id"
        case requestTypeName = "request_type_name"
        case zoneID = "zone_id"
        case appVersion = "app_version"
    }
}

struct Feedback: Codable {
    let id: Int
    let user: UserRequest
    let createdBy, updatedBy, createdAt, updatedAt: Double
    let userRequestID: Int
    let content, status: String

    enum CodingKeys: String, CodingKey {
        case id, user
        case createdBy = "created_by"
        case updatedBy = "updated_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userRequestID = "user_request_id"
        case content, status
    }
}

struct UserRequest: Codable {
    let id: Int
    let phone, firebaseID, fullName, avatar: String?

    enum CodingKeys: String, CodingKey {
        case id, phone
        case firebaseID = "firebase_id"
        case fullName = "full_name"
        case avatar
    }
}

struct UserRequestTypeFireStore: Codable {
    var enable: Bool {
        return (active ?? 0 > 0)
    }
    
    var description: String? {
        return content
    }
    var id: String?
    var title: String?
    var content: String?
    var active: Int?
    var position: Int?
    var index: Int?
    var appType: String?
    var imageUploadDescription: String?
    var isPinRequired: Bool?
    
}

struct KeyRegisterFood: Codable {
    var foodRegistrationId: String?
}
