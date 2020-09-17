//  File name   : LinkingCardVC.swift
//
//  Author      : admin
//  Created date: 5/22/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import FwiCoreRX
import FwiCore
import RxSwift
import RxCocoa
import Atributika

protocol LinkingCardPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    
    func moveBack()
    func routeToAddCard(card: PaymentCardDetail)
    var listCardObs: Observable<[PaymentCardType]> { get }
}

final class LinkingCardVC: UIViewController, LinkingCardPresentable, LinkingCardViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: LinkingCardPresentableListener?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
    private let disposeBag = DisposeBag()
    @IBOutlet weak var tableView: UITableView!
}

// MARK: View's event handlers
extension LinkingCardVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension LinkingCardVC {
}

// MARK: Class's private methods
private extension LinkingCardVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        let buttonLeft = visualizeButtonLeft()
        buttonLeft.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.moveBack()
        }).disposed(by: disposeBag)
        
        visualizeNavigationBar(titleStr: "Liên kết thẻ")
        
        setUpTableView()
    }
    
    private func setUpTableView() {
        tableView.delegate = self

        tableView.separatorStyle = .none
        tableView.register(EWalletBuyingTableViewCell.nib, forCellReuseIdentifier: EWalletBuyingTableViewCell.identifier)
        tableView.rowHeight = 72.0
                
        self.listener?.listCardObs.bind(to: tableView.rx.items(cellIdentifier: EWalletBuyingTableViewCell.identifier, cellType: EWalletBuyingTableViewCell.self)) { (row, element, cell) in
            cell.displayCell(element)
        }.disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        tableView.rx.itemSelected.bind { [weak self] idx in
            self?.listener?.routeToAddCard(card: [PaymentCardDetail.credit(),PaymentCardDetail.atm()][idx.row])
        }.disposed(by: disposeBag)
    }
}

// MARK: Class's public methods
extension LinkingCardVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 166
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v: UIView = UIView()
        let lblTerm = AttributedLabel()
        lblTerm.numberOfLines = 0
        
        let p = NSMutableParagraphStyle()
        p.lineSpacing = 5
        p.alignment = .left
               
        let text = ["<b>Điều khoản liên kết thẻ:</b>","Hỗ trợ thanh toán thẻ Visa, MasterCard, JCB", "Tài khoản của bạn sẽ bị trừ 5,000đ khi thêm thẻ. Số tiền này sẽ được cộng vào tài khoản VATOPay của bạn ngay lập tức."].joined(separator: "\n- ")
        let all = Style.foregroundColor(#colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)).font(.systemFont(ofSize: 15, weight: .regular)).paragraphStyle(p)
        let b = Style("b").foregroundColor(#colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)).font(.systemFont(ofSize: 15, weight: .medium)).paragraphStyle(p)
        let att = text.style(tags: b).styleAll(all)
        
        lblTerm.attributedText = att
        lblTerm >>> v >>> {
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(v).inset(16)
                make.top.equalTo(v).inset(15)
                make.right.equalTo(v).inset(0)
            }
        }
        
        let btnAgree: UIButton = UIButton()
        btnAgree >>> v >>> {
            $0.backgroundColor = .clear
            $0.setImage(UIImage(named: "ic_form_checkbox_checked"), for: .normal)
            $0.setTitle("Đồng ý điều khoản", for: .normal)
            $0.setTitleColor(#colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1), for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
            $0.contentHorizontalAlignment = .left
            $0.rx.tap.bind(onNext: weakify { wSelf in
                let imgName = btnAgree.isSelected ? "ic_form_checkbox_checked" : "ic_form_checkbox_uncheck"
                btnAgree.setImage(UIImage(named: imgName), for: .normal)
                btnAgree.isSelected = !btnAgree.isSelected
            }).disposed(by: disposeBag)

            $0.snp.makeConstraints { (make) in
                make.left.equalTo(v).inset(16)
                make.top.equalTo(lblTerm.snp.bottom).inset(-23)
                make.right.equalTo(v).inset(0)
            }
        }
        return v
    }
}
