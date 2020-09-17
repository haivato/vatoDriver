//  File name   : BankTransferVC.swift
//
//  Author      : Futa Corp
//  Created date: 2/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import UIKit
import Kingfisher

protocol BankTransferPresentableListener: class {
    var banks: Observable<[FirebaseModel.BankTransferConfig]> { get }

    func handleBackItemAction()
    func handleCellSelectionAction(bank: FirebaseModel.BankTransferConfig)
}

final class BankTransferVC: UITableViewController, BankTransferPresentable, BankTransferViewControllable {
    private struct Config {
        static let title = "Chuyển khoản ngân hàng"
        static let description1 = "Để nạp vào tiền tín dụng nhận chuyến bằng cách chuyến khoản, quý khách vui lòng chuyển tới 1 trong các tài khoản trên của VATO."
        static let description2 = "Sau khi nhận được số tiền chuyển khoản, VATO sẽ thực hiện cộng tiền vào tiền tín dụng nhận chuyến và thông báo đến bạn"
    }

    /// Class's public properties.
    weak var listener: BankTransferPresentableListener?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        
        tableView.register(BankTransferTVC.self, forCellReuseIdentifier: BankTransferTVC.identifier)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()

        guard let footerView = tableView.tableFooterView else {
            return
        }
        let maxWidth = tableView.bounds.width - 40.0
        description1Label.preferredMaxLayoutWidth = maxWidth
        description2Label.preferredMaxLayoutWidth = maxWidth

        footerView.layoutSubviews()
        footerView.frame.size = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

//        let height = footerView.frame.size.height
//        footerView >>> { $0.snp.updateConstraints {
//            $0.height.equalTo(height + 10)
//        }}

        tableView.tableFooterView = footerView
    }

    /// Class's private properties.
    private lazy var description1Label = UILabel()
    private lazy var description2Label = UILabel()
    private lazy var backItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back"), style: .plain, target: nil, action: nil)
        return item
    }()

    private lazy var banks: [FirebaseModel.BankTransferConfig] = []
    private lazy var disposeBag = DisposeBag()
}

// MARK: View's event handlers
extension BankTransferVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: UITableViewDataSource's members
extension BankTransferVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return banks.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = BankTransferTVC.dequeueCell(tableView: tableView)
        let bank = banks[indexPath.row]

        cell.titleLabel.text = bank.bankName

        cell.iconImageView.kf.setImage(with: bank.icon, placeholder: #imageLiteral(resourceName: "ic_topup_bank"), options: nil, progressBlock: nil) { (image, _, _, _) in
            guard let image = image else {
                return
            }

            DispatchQueue.main.async {
                cell.iconImageView.image = image
            }
        }
        return cell
    }
}

// MARK: UITableViewDelegate's members
extension BankTransferVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        listener?.handleCellSelectionAction(bank: banks[indexPath.row])
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72.0
    }
}

// MARK: Class's private methods
private extension BankTransferVC {
    private func localize() {
        title = Config.title
    }
    private func visualize() {
        navigationItem.leftBarButtonItems = [backItem]

        let headerView = UIView()
        headerView >>> {
            var frame = UIScreen.main.bounds
            frame.size.height = 30.0
            $0.frame = frame
            tableView.tableHeaderView = $0
        }

        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
        footerView >>> {
            tableView.tableFooterView = $0

            description1Label >>> $0 >>> {
                $0.text = Config.description1
                $0.textColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1)
                $0.numberOfLines = 0
                $0.lineBreakMode = .byWordWrapping
                $0.font = UIFont.systemFont(ofSize: 14)
                $0.snp.makeConstraints {
//                    $0.centerX.equalToSuperview()
                    $0.top.equalToSuperview()
                    $0.left.equalToSuperview().inset(20)
                    $0.right.equalToSuperview().inset(20)
                }
            }

            description2Label >>> $0 >>> {
                $0.text = Config.description2
                $0.textColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1)
                $0.numberOfLines = 0
                $0.lineBreakMode = .byWordWrapping
                $0.font = UIFont.systemFont(ofSize: 14)
                $0.snp.makeConstraints {
                    $0.top.equalTo(description1Label.snp.bottom).offset(20)
                    $0.left.equalTo(description1Label.snp.left)
                    $0.right.equalTo(description1Label.snp.right)
                    $0.bottom.equalToSuperview().inset(20)
                }
            }
        }

        tableView >>> {
            $0?.separatorStyle = .singleLine
        }
    }
    private func setupRX() {
        listener?.banks
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (banks) in
                self?.banks = banks
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        backItem.rx.tap
            .bind { [weak self] in
                self?.listener?.handleBackItemAction()
            }
            .disposed(by: disposeBag)
    }
}
