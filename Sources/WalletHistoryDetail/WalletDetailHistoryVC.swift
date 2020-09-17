//  File name   : WalletDetailHistoryVC.swift
//
//  Author      : Dung Vu
//  Created date: 12/5/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import UIKit
import RxCocoa
import Eureka

protocol WalletDetailHistoryPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var source: Observable<WalletItemDisplayProtocol> { get }
    func moveBack()
}

final class WalletDetailHistoryVC: FormViewController, WalletDetailHistoryPresentable, WalletDetailHistoryViewControllable {

    /// Class's public properties.
    weak var listener: WalletDetailHistoryPresentableListener?
    private lazy var disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        super.loadView()
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.separatorColor = #colorLiteral(red: 0.8920077682, green: 0.9186214805, blue: 0.943768084, alpha: 1)
        self.tableView = tableView
    }
    
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
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0, 1:
            return 8
        case 2:
            return 16
        default:
            return 0.1
        }
    }
    
    /// Class's private properties.
    deinit {
        printDebug("\(#function)")
    }
}

extension WalletDetailHistoryVC {
}

// MARK: Class's private methods
private extension WalletDetailHistoryVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.title = "Chi tiết giao dịch"
        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back").withRenderingMode(.alwaysOriginal), landscapeImagePhone: #imageLiteral(resourceName: "ic_back").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = item
        item.rx.tap.bind { [weak self] in
            self?.listener?.moveBack()
        }.disposed(by: disposeBag)
    }
    
    private func setup(by item: WalletItemDisplayProtocol) {
        form.removeAll()
        // Create source
        var source: [[WalletHistoryItemDisplay]] = []
        let amount = "\(item.prefix)\(item.amount.currency)"
        source.append([WalletHistoryItemDisplay(title: item.title ?? "", value: amount, color: item.color)])
        let t = item.transactionDate / 1000
        let date = Date(timeIntervalSince1970: t)
        let s = date.string(from: "HH:mm dd/MM/yyyy")
        source.append([WalletHistoryItemDisplay(title: "Mã giao dịch", value: "\(item.id)", color: nil),
                       WalletHistoryItemDisplay(title: "Ngày giờ", value: s, color: nil)])
        source.append([WalletHistoryItemDisplay(title: "\(item.description ?? "")", value: "", color: nil)])
        
        var sections = [Section]()
        for s in source.enumerated() {
            let section = Section()
            switch s.offset {
            case 0:
                for item in s.element {
                    let row = Row<WalletHistoryDetailTitleCell>.init(tag: "")
                    row.value = item
                    section <<< row
                }
            case 1:
                for item in s.element {
                    let row = Row<WalletHistoryDetailItemCell>.init(tag: "")
                    row.value = item
                    section <<< row
                }
            case 2:
                for item in s.element {
                    let row = Row<WalletHistoryDetailDescriptionCell>.init(tag: "")
                    row.value = item
                    section <<< row
                }
            default:
                continue
            }
            sections.append(section)
        }
        
        UIView.performWithoutAnimation {
            form += sections
        }
    }
    
    private func setupRX() {
        // todo: Bind data to UI here.
        self.listener?.source.bind(onNext: { [weak self] in
            self?.setup(by: $0)
        }).disposed(by: disposeBag)
    }
}
