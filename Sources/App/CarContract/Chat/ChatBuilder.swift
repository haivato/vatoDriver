//  File name   : ChatBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 1/4/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency
protocol ChatDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var chatStream: ChatStreamImpl { get }
}

final class ChatComponent: Component<ChatDependency> {
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol ChatBuildable: Buildable {
    func build(withListener listener: ChatListener, item: OrderContract) -> ChatRouting
}

final class ChatBuilder: Builder<ChatDependency>, ChatBuildable {

    override init(dependency: ChatDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: ChatListener, item: OrderContract) -> ChatRouting {
        let component = ChatComponent(dependency: dependency)
        let viewController = ChatVC()

        let interactor = ChatInteractor(presenter: viewController,
                                        chatStream: component.dependency.chatStream,
                                        item: item)
        interactor.listener = listener

        return ChatRouter(interactor: interactor, viewController: viewController)
    }
}
