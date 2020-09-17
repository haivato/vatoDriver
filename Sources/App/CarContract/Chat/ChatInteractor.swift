//  File name   : ChatInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 1/4/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import RxCocoa

protocol ChatRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol ChatPresentable: Presentable {
    var listener: ChatPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol ChatListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func chatMoveBack()
    func send(message: String)
}

final class ChatInteractor: PresentableInteractor<ChatPresentable>, ChatInteractable {
    
    

    weak var router: ChatRouting?
    weak var listener: ChatListener?
    private var item: OrderContract?

    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    init(presenter: ChatPresentable, chatStream: ChatStreamImpl, item: OrderContract?) {
        self.chatStream = chatStream
        self.item = item
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // todo: Implement business logic here.
        guard let driver = UserManager.shared.getCurrentUser() else {
            return
        }
        mDriver = driver
    }
    @Replay(queue: MainScheduler.asyncInstance) private var mDriver: FCDriver
    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    private (set) var chatStream: ChatStreamImpl
}
extension ChatInteractor: ChatPresentableListener {
    var currentUser: Observable<FCDriver> {
        return self.$mDriver
    }
}

extension ChatInteractor {
    func sendMessage(_ message: String) {
        let clientId = item?.user?.id.orNil(0)
        let driverId = item?.driverInfo?.id.orNil(0)
        let time = FireBaseTimeHelper.default.offset + Date().timeIntervalSince1970 * 1000
        let chatMessage = ChatMessage(message: message, sender: "d~\(driverId ?? 0)", receiver: "c~\(clientId ?? 0)", id: Int64(time), time: time)
        do {
            defer {
                self.chatStream.update(newMessage: chatMessage)
            }
            let node = FireBaseTable.chats >>> .custom(identify: item?.order_id ?? "")
            let ref = Database.database().reference(withPath: node.path).childByAutoId()
            let json = try chatMessage.toJSON()
            ref.setValue(json) { (e, data) in
                guard let e = e else { return }
                assert(false, e.localizedDescription)
            }
        } catch {
            assert(false, error.localizedDescription)
        }
    }
 
    
    func chatMoveBack() {
        listener?.chatMoveBack()
    }
}
