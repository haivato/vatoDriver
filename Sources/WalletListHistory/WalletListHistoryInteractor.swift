//  File name   : WalletListHistoryInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 12/6/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

//import RIBs
//import RxSwift
//import VatoNetwork
import SVProgressHUD
//import FwiCoreRX
//import FwiCore
import RIBs
import RxSwift
import CoreLocation
import RxCocoa
import FwiCore
import FwiCoreRX
import VatoNetwork
import Alamofire

protocol WalletListHistoryRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func showDetail(by item: WalletItemDisplayProtocol)
}

protocol WalletListHistoryPresentable: Presentable {
    var listener: WalletListHistoryPresentableListener? { get set }
    
    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol WalletListHistoryListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func listDetailMoveBack()
    func showDetail(by item: WalletItemDisplayProtocol)
}


struct WalletListHistoryUpdate {
    let from: Int
    let to: Int
    let source: [WalletListHistorySection]
}

final class WalletListHistoryInteractor: PresentableInteractor<WalletListHistoryPresentable>, WalletListHistoryInteractable, WalletListHistoryPresentableListener, ActivityTrackingProgressProtocol {
    var eLoading: Observable<Bool> {
        return indicator.asObservable()
    }
    weak var router: WalletListHistoryRouting?
    weak var listener: WalletListHistoryListener?
    let authenticated: AuthenticatedStream
    private var currentPage: Int = 0
    private var canLoadMore: Bool = true {
        didSet {
            guard canLoadMore else {
                return
            }
            // Update next
            currentPage += 1
        }
    }
    
    private lazy var disposeBag = DisposeBag()
    
    var eUpdate: Observable<WalletListHistoryUpdate> {
        return _eUpdate.observeOn(MainScheduler.asyncInstance)
    }
    
    private var source = [WalletListHistorySection]()
    private lazy var _eUpdate = PublishSubject<WalletListHistoryUpdate>()
    private lazy var indicator = ActivityIndicator()
    private var isLoading: Bool = false
    private let balanceType: Int
    private lazy var network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
    @Replay(queue: MainScheduler.asyncInstance) private var mTypeListHistory: Int
    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    init(presenter: WalletListHistoryPresentable, authenticated: AuthenticatedStream, balanceType: Int) {
        self.authenticated = authenticated
        self.balanceType = balanceType
        super.init(presenter: presenter)
        presenter.listener = self
        setupRX()
        self.mTypeListHistory = self.balanceType
    }
    
    override func didBecomeActive() {
        super.didBecomeActive()
        // todo: Implement business logic here.
        
    }
    
    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
        
    }
    
    private func setupRX() {
        self.indicator.asObservable().observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] in
            $0 ? SVProgressHUD.show(withStatus: "Đang xử lý") : SVProgressHUD.dismiss()
            self?.isLoading = $0
            }, onDisposed: {
                SVProgressHUD.dismiss()
        }).disposed(by: disposeBag)
        
    }
    
    func moveBack() {
        self.listener?.listDetailMoveBack()
    }
    
    func showDetail(by item: WalletItemDisplayProtocol) {
        //        router?.showDetail(by: item)
        self.listener?.showDetail(by: item)
    }
    
    func detailHistoryMoveBack() {
        //        self.router?.dismissCurrentRoute(completion: nil)
    }
    var typeListHistory: Observable<Int> {
        return self.$mTypeListHistory
    }
    
    struct Config {
        static let limitdays: Double = 2505600000
    }
    
    private func update(from list: [WalletTransactionItem]?) {
        guard let list = list else {
            return
        }
        let lastSectionIndex = self.source.count - 1
        var next = lastSectionIndex
        let last = self.source.last
        var temp: WalletListHistorySection? = last
        list.forEach { (item) in
            do {
                if temp == nil {
                    throw ListHistorySection.notExists
                }
                
                try temp?.add(from: item)
                temp?.needReload = temp == last
                
            } catch {
                let new = WalletListHistorySection(by: item)
                self.source.append(new)
                next += 1
                temp = new
            }
        }
        
        let value = WalletListHistoryUpdate(from: lastSectionIndex, to: next, source: self.source)
        _eUpdate.onNext(value)
    }
    
    func requestData() {
        disposableNext?.dispose()
        self.requestListTransactions()
        
    }
    
    private var disposableNext: Disposable?
    func update() {
        guard !isLoading, canLoadMore else {
            return
        }
        
        disposableNext?.dispose()
        self.requestListTransactions()
    }
    
    func refresh() {
        self.source = []
        self.canLoadMore = true
        self.currentPage = 0
        
        self.requestData()
    }
    
    private func requestListTransactions() {
        guard canLoadMore else {
            return
        }
        
        let to = Date().timeIntervalSince1970 * 1000
        let from = to - Config.limitdays
        let p = currentPage
        let balanceType = self.balanceType
        let textUrl = "?from=\(UInt64(from))&to=\(UInt64(to))&page=\(p)&balanceType=\(balanceType)&size=10"
        let url = TOManageCommunication.path("/api/balance/transactions\(textUrl)")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true)
        network.request(using: router,
                        decodeTo: OptionalMessageDTO<WalletTransactionsHistoryResponse>.self,
                        method: .get,
                        encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                guard let wSelf = self else { return }
                switch result {
                case .success(let d):
                    if d.fail == false {
                        wSelf.update(from: d.data?.transactions)
                    } else {
                        print(d.message ?? "")
                    }
                case .failure(let e):
                    print(e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
    
    deinit {
        printDebug("\(#function)")
    }
}
