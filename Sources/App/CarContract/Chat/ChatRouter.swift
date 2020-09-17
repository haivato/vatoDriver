//  File name   : ChatRouter.swift
//
//  Author      : Dung Vu
//  Created date: 1/4/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol ChatInteractable: Interactable {
    var router: ChatRouting? { get set }
    var listener: ChatListener? { get set }
}

protocol ChatViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ChatRouter: ViewableRouter<ChatInteractable, ChatViewControllable>, ChatRouting {

    // todo: Constructor inject child builder protocols to allow building children.
    override init(interactor: ChatInteractable, viewController: ChatViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
