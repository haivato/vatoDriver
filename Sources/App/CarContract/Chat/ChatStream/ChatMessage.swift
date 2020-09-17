//
//  ChatMessage.swift
//  FC
//
//  Created by Phan Hai on 29/08/2020.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import Firebase

struct ChatMessage: Codable, ModelFromFireBaseProtocol, ChatMessageProtocol, Comparable {
    var message: String?
    var sender: String?
    var receiver: String?
    let id: Int64
    let time: TimeInterval
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.time == rhs.time
    }
    
    static func < (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.time < rhs.time
    }
}

protocol ChatMessageProtocol {
    var message: String? { get }
    var sender: String? { get }
    var receiver: String? { get }
    var id: Int64 { get }
    var time: TimeInterval { get }
}
