//
//  ChatSream.swift
//  FC
//
//  Created by Phan Hai on 29/08/2020.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FwiCore
import UserNotificationsUI

protocol UserDisplayProtocol {
    var fullName: String? { get }
    var avatarUrl: String? { get }
}

protocol ChatStream {
    var currentDriver: UserDisplayProtocol? { get }
    var currentList: Observable<[ChatMessageProtocol]> { get }
    var notifyNewChat: Observable<Int> { get }
    
    func resetChatBadges()
}

protocol MutableChatStream: ChatStream {
    func update(listChat list:[ChatMessageProtocol]?)
    func update(newMessage message: ChatMessageProtocol?)
    func update(driver u:UserDisplayProtocol)
}

final class ChatStreamImpl: SafeAccessProtocol {
    /// Class's public properties.
    private (set) lazy var lock: NSRecursiveLock = NSRecursiveLock()
    private var list = [ChatMessageProtocol]()
    private lazy var disposeBag = DisposeBag()
    
    /// Class's private properties.
    private lazy var currentListSubject = BehaviorRelay<[ChatMessageProtocol]>.init(value: [])
    private (set) var currentDriver: UserDisplayProtocol?
    @Replay(queue: MainScheduler.asyncInstance) private var mNotifyNewChat: Int
    
    init(with currentDriver: UserDisplayProtocol?) {
        self.currentDriver = currentDriver
    }
}

extension ChatStreamImpl: MutableChatStream {
    var notifyNewChat: Observable<Int> {
        return $mNotifyNewChat
    }
    
    var currentList: Observable<[ChatMessageProtocol]> {
        return currentListSubject.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    
    func resetChatBadges() {
        mNotifyNewChat = 0
    }
    
    func update(listChat list: [ChatMessageProtocol]?) {
        guard let list = list else {
            return
        }
        self.excute { [unowned self] in
           self.currentListSubject.accept(list)
        }
    }
    
    func update(newMessage message: ChatMessageProtocol?) {
        guard let m = message else {
            mNotifyNewChat = 0
            return
        }
        self.excute { [unowned self] in
            var list = self.currentListSubject.value
            let userId = UserManager.shared.getCurrentUser()?.user.id ?? 0
            let sender = "d~\(userId)"
            guard !list.contains(where: { $0.id == m.id }) else {
                self.mNotifyNewChat = 0
                return
            }
            list.insert(m, at: 0)
            self.currentListSubject.accept(list)
            let me = message?.sender == sender
            self.mNotifyNewChat = me ? 0 : 1
            guard !me else { return }
            notify(message: m)
        }
    }
    
    func update(driver u: UserDisplayProtocol) {
        self.currentDriver = u
    }
    
    func notify(message: ChatMessageProtocol) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Tin nhắn từ khách hàng"
        content.body = message.message ?? ""
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "message.wav"))
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "com.driver.chat", content: content, trigger: trigger)
        center.add(request) { (e) in
            guard let e = e else { return }
            assert(false, e.localizedDescription)
        }
    }
    
}



