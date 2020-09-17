//
//  TopUpStream.swift
//  Vato
//
//  Created by khoi tran on 2/5/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import RxSwift


protocol TopUpStream {
    var listTopUpCellModel: Observable<[TopupCellModel]> { get }
}


protocol MutableTopUpStream: TopUpStream {
    
    func updateListTopUp(listTopUpLinkConfig: [TopupLinkConfigureProtocol])
    func updateListTopUp(listTopUpLinkConfig: [TopupLinkConfigureProtocol], listCard: [Card])
}

final class TopUpStreamImpl: MutableTopUpStream {
    
    @Replay(queue: MainScheduler.asyncInstance) private var mListTopUpCellModel: [TopupCellModel]

    var listTopUpCellModel: Observable<[TopupCellModel]> {
        return $mListTopUpCellModel
    }
    
    func updateListTopUp(listTopUpLinkConfig: [TopupLinkConfigureProtocol]) {
        mListTopUpCellModel = listTopUpLinkConfig.map{ TopupCellModel(item: $0, card: nil) }
    }
    
    func updateListTopUp(listTopUpLinkConfig: [TopupLinkConfigureProtocol], listCard: [Card]) {
        var result: [TopupCellModel] = []
        for topUpLinkConfig in listTopUpLinkConfig {
            if topUpLinkConfig.type == 1 { // napas
                for card in listCard {
                    let newConfig = topUpLinkConfig.clone()
                    let newTopUp = TopupCellModel(item: newConfig, card: card)
                    newTopUp.item.name = card.topUpName
                    newTopUp.item.iconURL = card.iconUrl
                    result.append(newTopUp)
                    
                }
            } else {
                if topUpLinkConfig.type == 2  { // zalo
                    result.append(TopupCellModel(item: topUpLinkConfig, card: PaymentCardDetail.zaloPay()))
                }
            
                if topUpLinkConfig.type == 4  { // momo
                    result.append(TopupCellModel(item: topUpLinkConfig, card: PaymentCardDetail.momo()))
                }
            }
        }
        
        
        
        mListTopUpCellModel = result
    }
    
    
}

