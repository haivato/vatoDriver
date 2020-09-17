//  File name   : WalletListHistoryVC.swift
//
//  Author      : Dung Vu
//  Created date: 12/6/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import UIKit
import SnapKit
import FwiCore

protocol WalletListHistoryPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var eUpdate: Observable<WalletListHistoryUpdate> { get }
    var eLoading: Observable<Bool> { get }
    var typeListHistory: Observable<Int> { get }
    func moveBack()
    func requestData()
    func refresh()
    func update()
    func showDetail(by item: WalletItemDisplayProtocol)
}

final class WalletListHistoryVC: UIViewController, WalletListHistoryPresentable, WalletListHistoryViewControllable {

    /// Class's public properties.
    weak var listener: WalletListHistoryPresentableListener?
    private lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .grouped)
        t.backgroundColor = .clear
        return t
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let r = UIRefreshControl(frame: .zero)
        if #available(iOS 10, *) {
            self.tableView.refreshControl = r
        } else {
            self.tableView.addSubview(r)
        }
        return r
    }()
    
    private lazy var disposeBag = DisposeBag()
    private lazy var noItemView = NoItemView(imageName: "notify_noItem",
                                             message: "Bạn chưa có hoạt động nào",
                                             on: self.tableView)
    private var source = [WalletListHistorySection]()
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        listener?.requestData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
    deinit {
        printDebug("\(#function)")
    }
}

// MARK: Class's private methods
private extension WalletListHistoryVC {
    private func localize() {
        // todo: Localize view's here.
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        self.view.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.9176470588, blue: 0.9450980392, alpha: 1)
        self.tableView.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.9176470588, blue: 0.9450980392, alpha: 1)
        tableView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        self.tableView.register(WalletItemTVC.self, forCellReuseIdentifier: WalletItemTVC.identifier)
        self.tableView.separatorColor = #colorLiteral(red: 0.8920077682, green: 0.9186214805, blue: 0.943768084, alpha: 1)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.title = "Lịch sử giao dịch"
        let b = UIImage(named: "back")
        self.navigationController?.navigationBar.tintColor = .white
        let item = UIBarButtonItem(image: b, landscapeImagePhone: b, style: .plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = item
        item.rx.tap.bind { [weak self] in
            self?.listener?.moveBack()
        }.disposed(by: disposeBag)
    }
    private func setupRX() {
         listener?.typeListHistory.bind(onNext: weakify { (type, wSelf) in
            if (type == ListHistoryType.credit.rawValue) {
                self.title = "Giao dịch điểm nhận chuyến"
            } else {
                self.title = "Giao dịch doanh thu" 
            }
               }).disposed(by: disposeBag)
        
        // todo: Bind data to UI here.
        self.listener?.eUpdate.bind(onNext: { [weak self](update) in
            guard let wSelf = self else {
                return
            }
            wSelf.refreshControl.endRefreshing()
            let previous = wSelf.source.count
            let next = update.source.count
            wSelf.source = update.source
            if update.from >= 0 {
                wSelf.tableView.beginUpdates()
                defer {
                    wSelf.tableView.endUpdates()
                }
                // reload
                let reload = update.from
                if wSelf.source[reload].needReload {
                    wSelf.tableView.reloadSections([reload], with: .none)
                }
                // Insert
                guard previous < next else {
                    return
                }
                
                wSelf.tableView.insertSections(IndexSet(integersIn: previous..<next), with: .none)
            } else {
                wSelf.tableView.reloadData()
                wSelf.source.count > 0 ? wSelf.noItemView.detach() : wSelf.noItemView.attach()
            }
            
        }).disposed(by: disposeBag)
        
        self.refreshControl.rx.controlEvent(.valueChanged).bind { [weak self] in
//            self?.source = []
            self?.refreshControl.beginRefreshing()
            self?.listener?.refresh()
        }.disposed(by: disposeBag)
    }
}

extension WalletListHistoryVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return source.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = WalletItemTVC.dequeueCell(tableView: tableView)
        let item = source[indexPath.section].items[indexPath.item]
        cell.setupDisplay(by: item)
        return cell
    }
}

extension WalletListHistoryVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView.create {
            $0.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 32))
        }
        let name = source[section].name
        
        UILabel.create {
            $0.text = name
            $0.textColor = #colorLiteral(red: 0.3843137255, green: 0.4431372549, blue: 0.4980392157, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            } >>> v >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(16)
                    make.bottom.equalTo(-5)
                })
        }
        
        return v
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 49
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let item = self.source[indexPath.section].items[indexPath.item]
        self.listener?.showDetail(by: item)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let c = scrollView.contentOffset.y + scrollView.bounds.height
        let delta = max(scrollView.contentSize.height, scrollView.bounds.height) - 150
        guard c >= delta else {
            return
        }
        
        // Update
        self.listener?.update()
    }
    
}


