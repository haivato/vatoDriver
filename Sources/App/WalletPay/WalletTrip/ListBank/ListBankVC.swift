//  File name   : ListBankVC.swift
//
//  Author      : MacbookPro
//  Created date: 5/22/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import RxCocoa

protocol ListBankPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var listBankObser: Observable<[BankInfoServer]> { get }
}

final class ListBankVC: UIViewController, ListBankPresentable, ListBankViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: ListBankPresentableListener?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightTableView: NSLayoutConstraint!
    private var listBank: [BankInfoServer] = []
    private let disposeBag = DisposeBag()
    private let maxCellDisPlay = 5
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
}

// MARK: View's event handlers
extension ListBankVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension ListBankVC {
}

// MARK: Class's private methods
private extension ListBankVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        let buttonLeft = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        buttonLeft.setImage(UIImage(named: "ic_arrow_navi_left"), for: .normal)
        buttonLeft.contentEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: buttonLeft)
        navigationItem.leftBarButtonItem = leftBarButton
        buttonLeft.rx.tap.bind(onNext: weakify { wSelf in
//            wSelf.listener?.walletTripMoveBack()
        }).disposed(by: disposeBag)
        title = "Danh sách ngân hàng"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ListBankCell.nib, forCellReuseIdentifier: ListBankCell.identifier)
        let v: HeaderCornerView = HeaderCornerView(with: 7)
        v.containerColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.tableView.insertSubview(v, at: 0)
        v >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }

        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 10
        
        UIView.animate(withDuration: 0, animations: {
            self.tableView.layoutIfNeeded()
        }) { (complete) in
            var heightOfTableView: CGFloat = 0.0
            let cells = self.tableView.visibleCells
            let count = min(cells.count, self.maxCellDisPlay)
            for (index, element) in cells.enumerated() {
                if index < count {
                    heightOfTableView += element.frame.height
                }
            }
            self.heightTableView.constant = heightOfTableView + 86
            self.view.isHidden = false
            self.view.layoutIfNeeded()
        }

    }
    
    private func setupRX() {
        listener?.listBankObser.bind(onNext: weakify { (listBank, wSelf) in
            wSelf.listBank = listBank
            if listBank.count <= wSelf.maxCellDisPlay {
                wSelf.tableView.isScrollEnabled = false
            } else {
                wSelf.tableView.isScrollEnabled = true
            }
            wSelf.tableView.reloadData()
        }).disposed(by: disposeBag)
    }
}
extension ListBankVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 26
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v: UIView = UIView()
        
        let lbTitle: UILabel = UILabel(frame: .zero)
        lbTitle.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        lbTitle.text = Text.listBank.localizedText
        lbTitle.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        
        v.addSubview(lbTitle)
        lbTitle.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
        }
        
        return v
    }
    
}
extension ListBankVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listBank.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListBankCell.identifier) as! ListBankCell
        cell.updateUI(model: self.listBank[indexPath.row])
        return cell
    }
}
