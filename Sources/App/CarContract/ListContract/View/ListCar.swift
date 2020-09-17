//
//  ListCar.swift
//  FC
//
//  Created by Phan Hai on 09/09/2020.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import VatoNetwork
import SVProgressHUD
import FwiCore
import FwiCoreRX

class ListCar: UIViewController, ListCarContractRemoveProtocol, ActivityTrackingProgressProtocol, SafeAccessProtocol {
    func remove(item: ContractHistoryType) {
        
    }
    
    func refresh() {
        self.mRefreshControl.beginRefreshing()
        self.paging = .default
        requestList()
    }
    
    private (set) lazy var lock: NSRecursiveLock = NSRecursiveLock()
    var type: ContractCarOrderType = .listRequest
    weak var listener: ListCarHistoryHandlerProtocol?
    private var mSource: [ContractHistoryType] = [] {
        didSet {
            mSource.isEmpty ? noItemView.attach() : noItemView.detach()
        }
    }
    private var update: ReplaySubject<ListUpdate<ContractHistoryType>> = ReplaySubject.create(bufferSize: 1)
    private var paging: Paging = .default
    @IBOutlet weak var tableView: UITableView!
    private var loading: Bool = false
    private lazy var noItemView = NoItemView(imageName: "ic_no_contract", message: "Bạn chưa có chuyến xe nào", on: tableView)
    private var disposeRequest: Disposable?
    private lazy var mRefreshControl: UIRefreshControl = {
        let f = UIRefreshControl(frame: .zero)
        return f
    }()
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        requestList()
    }
    deinit {
        disposeRequest?.dispose()
    }
}
extension ListCar {
    private func visualize() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = 0.1
        tableView.register(CarContractCell.nib, forCellReuseIdentifier: CarContractCell.identifier)
        tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        tableView.refreshControl = mRefreshControl
        tableView.prefetchDataSource = self
    }
    private func setupRX() {
        mRefreshControl.rx.controlEvent(.valueChanged).bind { [weak self](_) in
            self?.refresh()
        }.disposed(by: disposeBag)
        
        indicator.asObservable()
            .observeOn(MainScheduler.instance)
            .bind(onNext: weakify({ (load, wSelf) in
                wSelf.loading = load.0
                load.0 ? LoadingManager.instance.show() : LoadingManager.instance.dismiss()
            })).disposed(by: disposeBag)
        
        update.observeOn(MainScheduler.asyncInstance).bind(onNext: weakify({ (event, wSelf) in
            wSelf.update(event: event)
        })).disposed(by: disposeBag)
        
        self.listener?.itemGetList.bind(onNext: weakify({ (isGet, wSelf) in
            if (isGet) {
                wSelf.paging = .default
                wSelf.requestList()
            }
            })).disposed(by: disposeBag)
    }
    func requestList() {
        guard paging.page == 0 || !loading else {
            return
        }
        
        guard let next = paging.next else {
            return
        }
//        self.tableView.allowsSelection = (self.type == .listRequest) ? true : false
        disposeRequest?.dispose()
        let isFirst = next.first
        var params: [String: Any] = [:]
        params["page"] = next.page
        params["size"] = next.size
        params["filter"] = self.type.textValue
        disposeRequest = listener?
            .requestList(params: params)
            .trackProgressActivity(self.indicator)
            .subscribe(onNext: weakify({ (res, wSelf) in
                wSelf.paging = Paging(page: res.currentPage ?? 0, canRequest: res.next, size: next.size)
            if isFirst {
                wSelf.update.onNext(.reload(items: res.items ?? []))
            } else {
                wSelf.update.onNext(.update(items: res.items ?? []))
            }
        }), onError: { [weak self] (e) in
            guard let wSelf = self else { return }
            if isFirst {
                wSelf.update.onNext(.reload(items: []))
            } else {
                wSelf.update.onNext(.update(items:[]))
            }
        })
    }
    private func update(event: ListUpdate<ContractHistoryType>) {
        if self.mRefreshControl.isRefreshing {
            self.mRefreshControl.endRefreshing()
        }
        
        switch event {
        case let .reload(items):
            excute { self.mSource = items }
            self.tableView?.reloadData()
        case let .update(items):
            let before = self.mSource.count
            excute { self.mSource += items }
            let range = (before ..< (items.count + before))
            guard !range.isEmpty else { return }
            self.tableView?.beginUpdates()
            defer {
                self.tableView?.endUpdates()
            }
            let indexs = range.map { IndexPath(item: $0, section: 0) }
            self.tableView?.insertRows(at: indexs, with: .bottom)
        }
    }
}
extension ListCar: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let idx = indexPaths.last?.item else { return }
        let total = excute(block: { return self.mSource.count })
        guard total - idx <= 10 else { return }
        requestList()
    }
}
extension ListCar: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CarContractCell.identifier) as! CarContractCell
        cell.selectionStyle = .none
        let element = self.mSource[indexPath.row]
        cell.viewCarContract.updateUI(type: self.type)
        cell.setupDisplay(item: element)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.mSource[indexPath.row]
        self.listener?.select(item: item)
    }
}
