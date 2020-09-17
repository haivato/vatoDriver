//  File name   : BankInfoVC.swift
//
//  Author      : Vato
//  Created date: 11/8/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vu Dang. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import RxSwift

final class BankInfoVC: FormViewController {
    @IBOutlet weak var doneButton: UIButton!
    
    /// Class's public properties.

    /// Class's constructors.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init(with userBankInfo: BankCellModel, selectedUserBankInfoSubject: PublishSubject<BankCellModel>) {
        self.userBankInfo = userBankInfo
        self.selectedUserBankInfoSubject = selectedUserBankInfoSubject
        super.init(nibName: "\(BankInfoVC.self)", bundle: nil)
    }

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()

        let section = Section()
        section <<< MasterTextFieldRow() { [weak self] in
            $0.disabled = true
            $0.title = "Ngân hàng"
            $0.value = self?.userBankInfo.bankInfo?.bankShortName
        }
        section <<< MasterTextFieldRow() { [weak self] in
            $0.disabled = true
            $0.title = "Số tài khoản"
            $0.value = self?.userBankInfo.userBankInfo.bankAccount
        }
        section <<< MasterTextFieldRow() { [weak self] in
            $0.disabled = true
            $0.title = "Tên chủ tài khoản"
            $0.value = self?.userBankInfo.userBankInfo.accountName
        }
        
        if let idCard = self.userBankInfo.userBankInfo.idCard, idCard.count > 0 {
            section <<< MasterTextFieldRow() {
                $0.disabled = true
                $0.title = "Chứng minh thư"
                $0.value = idCard
            }
        }
        form +++ section
        
        if userBankInfo.isSelected {
            doneButton.isEnabled = false
            let background = #imageLiteral(resourceName: "bg_button01").withRenderingMode(.alwaysTemplate)

            doneButton.setBackgroundImage(background, for: .normal)
            doneButton.tintColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
    private let userBankInfo: BankCellModel
    private let selectedUserBankInfoSubject: PublishSubject<BankCellModel>

    private lazy var backItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back"), landscapeImagePhone: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(NewBankAccountVC.handleBackItemOnPressed(_:)))
        return item
    }()
}

// MARK: View's event handlers
extension BankInfoVC {
    override var shouldAutorotate: Bool {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UI_USER_INTERFACE_IDIOM() == .pad {
            return .all
        } else {
            return [.portrait, .portraitUpsideDown]
        }
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        // todo: Transfer data between views during presentation here.
    }

//    @IBAction func unwindTo(BankInfoVC segue: UIStoryboardSegue) {
//    }
}

// MARK: View's key pressed event handlers
extension BankInfoVC {
    @IBAction func handleBackItemOnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func handleDoneButtonOnPressed(_ sender: Any) {
        selectedUserBankInfoSubject.onNext(userBankInfo)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: Class's public methods
extension BankInfoVC {
}

// MARK: Class's private methods
private extension BankInfoVC {
    private func localize() {
        title = userBankInfo.bankInfo?.bankShortName
    }
    private func visualize() {
        navigationItem.leftBarButtonItems = [backItem]

        var frame = tableView.frame
        frame.size.height = 1.0
        tableView.tableHeaderView = UIView(frame: frame)
    }
}
