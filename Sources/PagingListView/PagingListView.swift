//  File name   : PagingListView.swift
//
//  Author      : Dung Vu
//  Created date: 1/6/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa
import VatoNetwork
//import KeyPathKit
protocol RequestInteractorProtocol: AnyObject {
    var token: Observable<String> { get }
}

extension RequestInteractorProtocol {
    func request<E>(map: @escaping (String) -> Observable<E>) -> Observable<E> {
        return token.flatMap(map)
    }
}
protocol UpdateDisplayProtocol {
    associatedtype Value
    func setupDisplay(item: Value?)
}

protocol ResponsePagingProtocol {
    associatedtype Element
    var next: Bool { get }
    var items: [Element]? { get }
}

protocol PagingListRequestDataProtocol: AnyObject {
    associatedtype Data: ResponsePagingProtocol & Codable
    associatedtype P: PagingNextProtocol
    func buildRouter(from paging: P) -> Observable<APIRequestProtocol>
    func request<T: Codable>(router: APIRequestProtocol, decodeTo: T.Type) -> Observable<T>
}


enum PagingListCellType {
    case `class`
    case nib
}

final class PagingListView<C: UITableViewCell, Listener: PagingListRequestDataProtocol, P>: UIView, UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching, Weakifiable, ActivityTrackingProgressProtocol where C: UpdateDisplayProtocol, C.Value == Listener.Data.Element, Listener.P == P {
    /// Class's public properties.
    typealias Item = Listener.Data.Element
    private weak var listener: Listener?
    private (set) var tableView: UITableView
    private lazy var disposeBag = DisposeBag()
    private var type: PagingListCellType = .class
    @VariableReplay(wrappedValue: []) private var source: [Item]
    
    // Adjust Cell
    var heightCell: CGFloat = UITableView.automaticDimension
    var configureCell: ((_ cell: C, _ item: Item) -> ())?
    var distanceItemRequest: Int = 5 {
        didSet {
            assert(distanceItemRequest >= 0, "Check !!!!!!")
        }
    }
    
    var selected: Observable<Item> {
        return $mSelected.observeOn(MainScheduler.asyncInstance)
    }
    
    private var pagingDefault: (() -> P)?
    private var noItemView: ((UITableView) -> NoItemView?)?
    private var paging: P?
    private var load: Bool = false
    private lazy var mNoItemView: NoItemView? = {
        let v = self.noItemView?(tableView)
        return v
    }()
    @Published private var mSelected: Item
    @Replay(queue: MainScheduler.asyncInstance) private var mUpdate: ListUpdate<Item>
    private var disposeRequest: Disposable?
    
    private (set) lazy var mRefreshControl: UIRefreshControl = {
        let f = UIRefreshControl(frame: .zero)
        return f
    }()
    
    
    init(listener: Listener?,
                     type: PagingListCellType = .class,
                     pagingDefault: (() -> P)? = nil,
                     tableView: UITableView? = nil,
                     noItemView: ((UITableView) -> NoItemView?)? = nil) {
        self.tableView = tableView ?? {
            let t = UITableView(frame: .zero, style: .plain)
            t.separatorStyle = .none
            return t
        }()
        super.init(frame: .zero)
        self.pagingDefault = pagingDefault
        self.noItemView = noItemView
        self.listener = listener
        self.type = type
        visualize()
        setupRX()
        requestData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// Class's private properties.
    
    override func removeFromSuperview() {
        disposeRequest?.dispose()
        super.removeFromSuperview()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightCell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return $source.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let c = tableView.dequeueReusableCell(withIdentifier: C.identifier) as? C else {
            fatalError("Please Implement")
        }
        let item = $source.value[indexPath.item]
        c.setupDisplay(item: item)
        configureCell?(c, item)
        return c
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let idx = indexPaths.last?.item else { return }
        let total = $source.value.count
        guard total - idx <= distanceItemRequest else { return }
        requestData()
    }
    
    func insert(items: [Item]) {
        let before = self.source
        let after = before + items
        self.source = after
        let range = (before.count ..< after.count)
        guard !range.isEmpty else { return }
        self.tableView.beginUpdates()
        defer {
            self.tableView.endUpdates()
        }
        let indexs = range.map { IndexPath(item: $0, section: 0) }
        self.tableView.insertRows(at: indexs, with: .bottom)
    }
}

// MARK: Class's private methods
private extension PagingListView {
    private func initialize() {
        // todo: Initialize view's here.
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        tableView >>> self >>> {
            $0.backgroundColor = .clear
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        switch type {
        case .class:
            tableView.register(C.self, forCellReuseIdentifier: C.identifier)
        case .nib:
            tableView.register(C.nib, forCellReuseIdentifier: C.identifier)
        }
        paging = pagingDefault?() ?? .default
        tableView.refreshControl = mRefreshControl
        tableView.prefetchDataSource = self
    }
    
    func handler(_ event: ListUpdate<Item>) {
        if self.mRefreshControl.isRefreshing {
            self.mRefreshControl.endRefreshing()
        }
        
        switch event {
        case let .reload(items):
            self.source = items
            self.tableView.reloadData()
        case let .update(items):
            insert(items: items)
        }
    }
    
    func requestData() {
        guard let listener = self.listener, let paging = paging else { return }
        let p: P = pagingDefault?() ?? .default
        let first = paging.page == p.page
        guard first || !load else { return }
        guard let next = paging.next else { return }
        disposeRequest?.dispose()
        disposeRequest = listener.buildRouter(from: next).flatMap {[unowned listener] in
            listener.request(router: $0, decodeTo: Listener.Data.self)
        }
        .trackProgressActivity(indicator)
        .subscribe(weakify({ (event, wSelf) in
            switch event {
            case .next(let result):
                let r = result
                let items = r.items ?? []
                wSelf.paging = P(page: next.page, canRequest: r.next , size: next.size)
                if first {
                    wSelf.mUpdate = .reload(items: items)
                } else {
                    wSelf.mUpdate = .update(items: items)
                }
            case .error(let e):
                print(e.localizedDescription)
                wSelf.mUpdate = .reload(items: [])
            default:
                break
            }
        }))
    }
    
    func refresh() {
        self.paging = pagingDefault?() ?? .default
        mRefreshControl.beginRefreshing()
        requestData()
    }
    
    func setupRX() {
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        tableView.rx.setDataSource(self).disposed(by: disposeBag)
        $source.skip(1).map { $0.isEmpty }
            .observeOn(MainScheduler.asyncInstance)
            .bind(onNext: weakify({ (empty, wSelf) in
            let noItemView = wSelf.mNoItemView
            empty ? noItemView?.attach() : noItemView?.detach()
        })).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.map { [unowned self] in
            return self.source[safe: $0.item]
        }.filterNil().bind(to: $mSelected).disposed(by: disposeBag)
        
        mRefreshControl.rx.controlEvent(.valueChanged).bind(onNext: weakify({ (wSelf) in
            wSelf.refresh()
        })).disposed(by: disposeBag)
        
        $mUpdate.bind(onNext: weakify({ (update, wSelf) in
            wSelf.handler(update)
        })).disposed(by: disposeBag)
        
        loadingProgress.bind(onNext: weakify({ (r, wSelf) in
            wSelf.load = r.0
        })).disposed(by: disposeBag)
        
        
    }
}
