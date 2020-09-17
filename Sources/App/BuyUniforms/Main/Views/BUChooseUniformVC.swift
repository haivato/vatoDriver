//
//  BUChooseUniformVC.swift
//  FC
//
//  Created by vato. on 3/10/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import RxSwift
import VatoNetwork

struct BUProductMainResponse: Codable, ResponsePagingProtocol {
    var values: [DisplayProduct]?
    
    var items: [DisplayProduct]? {
        return values
    }
    
    var next: Bool
}

struct BasketProductIem: BasketStoreValueProtocol {
    var note: String?
    
    var quantity: Int
}


final class BUChooseUniformVC: UIViewController, PagingListRequestDataProtocol {
     func buildRouter(from paging: Paging) -> Observable<APIRequestProtocol> {
        let param = ["offset": paging.page * paging.size,
                     "limit": paging.size]
           return self.request { key -> Observable<APIRequestProtocol> in
               return Observable.just(VatoFoodApi.getListSaleOrder(authenToken: key, params: param))
           }
           
       }
    
     func request<T>(router: APIRequestProtocol, decodeTo: T.Type) -> Observable<T> where T : Codable {
           guard let listener = listener  else {
               return Observable.empty()
           }
            
           return listener.request(router: router, decodeTo: decodeTo, block: {
               $0.dateDecodingStrategy = .customDateFireBase
           })
       }
    
    typealias Data = BUProductMainResponse
    typealias P = Paging
    
    struct Config {
        static let pageSize = 10
        static let pagingDefaut = Paging(page: -1, canRequest: true, size: Config.pageSize)
    }
    
    /// Class's public properties.
    weak var listener: BUMainPresentableListener?
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    /// Class's private properties.
    private lazy var disposeBag: DisposeBag = DisposeBag()
    private var listView: PagingListView<StoreProductSelectCell, BUChooseUniformVC, P>?
    private lazy var basketView: BasketItemsView = BasketItemsView(frame: .zero, value: listener?.basket)
    private var containerBasket: UIView?
    private var header = BUStationView.loadXib()
    private var basket: BasketModel = [:]
}

// MARK: View's event handlers
extension BUChooseUniformVC: RequestInteractorProtocol  {
    
    var token: Observable<String> {
        return Observable.just("")
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}


// MARK: Class's public methods
extension BUChooseUniformVC {
    func reloadData() {
        self.listView?.tableView.reloadData()
    }
}

// MARK: Class's private methods
private extension BUChooseUniformVC {
    private func localize() {
        // todo: Localize view's here.
    }
    
    private func visualize() {
        // todo: Visualize view's here
        let pagingView = PagingListView<StoreProductSelectCell, BUChooseUniformVC, P>.init(listener: self, type: .class, pagingDefault: { () -> QuickSupportMainVC.P in
            return Config.pagingDefaut
        }) { (tableView) -> NoItemView? in
            return NoItemView(imageName: "ic_quick_support_empty",
                              message: "Không có dữ liệu.",
                              subMessage: "",
                              on: tableView,
                              customLayout: nil)
        }
        
        let containerBasket = UIView(frame: .zero)
        containerBasket >>> view >>> {
            $0.backgroundColor = .clear
            $0.clipsToBounds = true
            $0.snp.makeConstraints({ (make) in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(0)
            })
        }
        self.containerBasket = containerBasket
        
        header >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.left.top.right.equalToSuperview()
            }
        }
        
        pagingView >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(header.snp_bottomMargin)
                make.left.right.equalToSuperview()
                make.bottom.equalTo(containerBasket.snp_topMargin)
            }
        }
        
        pagingView.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        pagingView.clipsToBounds = true
        self.listView = pagingView
        
        basketView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
    }
    
    private func setupRX() {
        listener?.basket.map { !$0.keys.isEmpty }.distinctUntilChanged().bind(onNext: weakify({ (show, wSelf) in
            let state: BasketItemsState = show ? .compact : .none
            wSelf.basketView.update(state: state)
            wSelf.view.bringSubviewToFront(wSelf.basketView)
        })).disposed(by: disposeBag)
        
        listView?.configureCell = { [weak self] (cell, item) in
            guard let wSelf = self else { return }
            let value = wSelf.basket[item]
            
            cell.editView.updateValue(v: value?.quantity ?? 0)
            cell.editView?.value.takeUntil(cell.rx.methodInvoked(#selector(UITableViewCell.prepareForReuse))).bind(onNext: { (value) in
                wSelf.listener?.update(item: item, value: BasketProductIem(note: "", quantity: value))
            }).disposed(by: wSelf.disposeBag)
        }
        
        header.button.rx.tap.bind { [weak self] (_) in
            self?.listener?.routeToListStation() 
        }.disposed(by: self.disposeBag)
        
        listener?.selectedEvent.bind(onNext: { [weak self] (item) in
            self?.header.titleLabel.text = item?.name
            self?.header.subTitle.text = item?.address
            self?.listView?.mRefreshControl.sendActions(for: .valueChanged)
        }).disposed(by: self.disposeBag)
        
        basketView.action.bind { [weak self] (action) in
            switch action {
            case .checkout:
                self?.listener?.didContinue()
            }
        }.disposed(by: self.disposeBag)
        
        listener?.basket.bind(onNext: { [weak self] (r) in
            self?.basket = r
        }).disposed(by: self.disposeBag)
    }
}
