//
//  BUHistoryVC.swift
//  FC
//
//  Created by vato. on 3/10/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import RxSwift
import VatoNetwork

struct BUProductHistoryResponse: Codable, ResponsePagingProtocol {
    var orderOfflineList: [SalesOrder]?
    
    var items: [SalesOrder]? {
        return orderOfflineList
    }
    
    var next: Bool {
        return (indexPage ?? 0 < totalPage ?? 0)
    }
    
    var indexPage: Int?
    var sizePage: Int?
    var totalRows: Int?
    var totalPage: Int?
}

final class BUHistoryVC: UIViewController, PagingListRequestDataProtocol {
     func buildRouter(from paging: Paging) -> Observable<APIRequestProtocol> {
           let param: [String : Any] = [
               "indexPage": max(paging.page, 0),
               "sizePage": Config.pageSize
           ]
           return self.request { key -> Observable<APIRequestProtocol> in
               return Observable.just(VatoFoodApi.getListSaleOrderOffline(authenToken: key, params: param))
           }
           
       }
    
     func request<T>(router: APIRequestProtocol, decodeTo: T.Type) -> Observable<T> where T : Codable {
           guard let listener = listener  else {
               return Observable.empty()
           }
            
           return listener.requestHistory(router: router, decodeTo: decodeTo, block: {
               $0.dateDecodingStrategy = .customDateFireBase
           })
       }
    
    typealias Data = BUProductHistoryResponse
    typealias P = Paging
    
    private struct Config {
        static let pageSize = 10
        static let pagingDefaut = Paging(page: -1, canRequest: true, size: 10)
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
    private var listView: PagingListView<BUHistoryCellTableViewCell, BUHistoryVC, P>?
}

// MARK: View's event handlers
extension BUHistoryVC: RequestInteractorProtocol  {
    
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
extension BUHistoryVC {
    func refresh(needScrollTop: Bool = false) {
        if needScrollTop {
            self.listView?.tableView.setContentOffset(CGPoint.zero, animated: false)
        }
        self.listView?.mRefreshControl.sendActions(for: .valueChanged)
    }
    
}

// MARK: Class's private methods
private extension BUHistoryVC {
    private func localize() {
        // todo: Localize view's here.
    }
    
    private func visualize() {
        // todo: Visualize view's here
        let pagingView = PagingListView<BUHistoryCellTableViewCell, BUHistoryVC, P>.init(listener: self, type: .nib, pagingDefault: { () -> QuickSupportMainVC.P in
            return Config.pagingDefaut
        }) { (tableView) -> NoItemView? in
            return NoItemView(imageName: "ic_quick_support_empty",
                              message: "Không có dữ liệu.",
                              subMessage: "",
                              on: tableView,
                              customLayout: nil)
        }
        
        pagingView >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.top.left.right.bottom.equalToSuperview()
            }
        }
        
        pagingView.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        pagingView.clipsToBounds = true
        
        self.listView = pagingView
    }
    
    private func setupRX() {
        self.listView?.configureCell = { (cell, item) in
            cell.cancelButton?.rx.tap
                .takeUntil(cell.rx.methodInvoked(#selector(UITableViewCell.prepareForReuse)))
                .bind(onNext: { [weak self] in
                    guard let wSelf = self,
                        let id = item.id else { return }
                    wSelf.showAlertConfirmCancel(idOrderOffline: id)
                }).disposed(by: self.disposeBag)
            
            cell.signButton?.rx.tap
            .takeUntil(cell.rx.methodInvoked(#selector(UITableViewCell.prepareForReuse)))
            .observeOn(MainScheduler.asyncInstance)
            .bind(onNext: { [weak self] in
                guard let wSelf = self,
                    let id = item.id else { return }
                wSelf.showAlertSignOrder(idOrderOffline: id)
            }).disposed(by: self.disposeBag)
        }
    }
    
    func showAlertSignOrder(idOrderOffline: String) {
        
        let alertVC = UIAlertController(title: "Xác nhận đơn hàng", message: "Tôi đã thanh toán đủ tiền, và đã nhận đủ hàng", preferredStyle: .alert)
        
        let signAction = UIAlertAction(title: "Ký nhận", style: .default, handler:{ [weak self] (_) in
            self?.listener?.updateState(state: .COMPLETE, idOrderOffline: idOrderOffline)
        })
        let cancelAction = UIAlertAction(title: "Quay lại", style: .cancel)
        
        alertVC.addAction(signAction)
        alertVC.addAction(cancelAction)
                
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func showAlertConfirmCancel(idOrderOffline: String) {
        AlertVC.showMessageAlert(for: self, title: "Xác nhận", message: "Bạn có chắc chắn muốn huỷ đơn hàng này không?", actionButton1: "Không", actionButton2: "Huỷ đơn hàng", handler2: { [weak self] in
            self?.listener?.updateState(state: .CANCELED, idOrderOffline: idOrderOffline)
        })
    }
}
