//  File name   : BuyPointInteractor.swift
//
//  Author      : admin
//  Created date: 5/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Alamofire

protocol BuyPointRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.

    func moveToWithDrawCF(item: TopupCellModel, point: Int, balance: DriverBalance)
}

protocol BuyPointPresentable: Presentable {
    var listener: BuyPointPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol BuyPointListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func moveBackFromBuyPoint()
    func moveBackSourceWallet()
}

final class BuyPointInteractor: PresentableInteractor<BuyPointPresentable> {
    /// Class's public properties.
    weak var router: BuyPointRouting?
    weak var listener: BuyPointListener?
    /// Class's constructor.
        
    init(presenter: BuyPointPresentable, list: [Any], balance: DriverBalance?, indexSelect: IndexPath?) {
        self.listMethod = list
        self.balance = balance
        self.indexSelect = indexSelect
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        
        
        if let methods = self.listMethod {
            self.mListMethod = methods
        }
             
        mLastSelectedCard = listSelectedCard.first

        if let balance = self.balance {
            self.mBalance = balance
        }
        if let index = self.indexSelect {
            self.mIndexSelect = index
        }
        
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
    private lazy var network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
    private var listTopUpObs: PublishSubject<[TopUpMethod]> = PublishSubject.init()
    
    private var listTopUpMethod: [TopUpMethod]?
    private var listMethod: [Any]?
    private var indexSelect: IndexPath?

    private var mLastSelectedCard: Card?
    @CacheFile(fileName: "TopUpCard") var listSelectedCard: [Card]
    @Replay(queue: MainScheduler.asyncInstance) private var mListMethod: [Any]
    @Replay(queue: MainScheduler.asyncInstance) private var mIndexSelect: IndexPath
    
    private var balance: DriverBalance?
    @Replay(queue: MainScheduler.asyncInstance) private var mBalance: DriverBalance
}


// MARK: BuyPointInteractable's members
extension BuyPointInteractor: BuyPointInteractable {
    func moveBackSourceWallet() {
        self.listener?.moveBackSourceWallet()
    }

    func moveBackFromWithDrawConfirm() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
}

// MARK: BuyPointPresentableListener's members
extension BuyPointInteractor: BuyPointPresentableListener {
    
    var listMethodObser: Observable<[Any]> {
        return self.$mListMethod
    }
    
    var indexObs: Observable<IndexPath> {
        return self.$mIndexSelect
    }

    func moveBack() {
        self.listener?.moveBackFromBuyPoint()
    }
    
    var lastSelectedCard: Card? {
        return mLastSelectedCard
    }
    
    func selectCard(card: Card?) {
        _listSelectedCard.add(item: card)
    }

    var balanceObs: Observable<DriverBalance> {
        return self.$mBalance
    }

    func moveToWithDrawCF(item: TopupCellModel, point: Int) {
        guard let driverbalance = self.balance else {
            return
        }
        self.router?.moveToWithDrawCF(item: item, point: point, balance: driverbalance)
    }
}

// MARK: Class's private methods
private extension BuyPointInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
        
}
