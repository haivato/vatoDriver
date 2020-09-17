//  File name   : BankTransferDetailVC.swift
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

protocol BankTransferDetailPresentableListener: class {
    var phoneNumber: Observable<String> { get }

    func handleBackItemAction()
}

final class BankTransferDetailVC: UIViewController, BankTransferDetailPresentable, BankTransferDetailViewControllable {
    private struct Config {
        static let accountNo = "Số TK"
        static let accountName = "Tên TK"
        static let bank = "Ngân hàng"
        static let copied = "Đã lưu lại"
        static let description = "Nội dung"

        static let dismiss = "Đóng"
    }

    /// Class's public properties.
    weak var listener: BankTransferDetailPresentableListener?

    /// Class's constructors.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init(with bank: FirebaseModel.BankTransferConfig) {
        self.bank = bank
        super.init(nibName: nil, bundle: nil)
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

    /// Class's private properties.
    private lazy var bankNameLabel = UILabel()
    private lazy var accountNoLabel = UILabel()
    private lazy var accountNameLabel = UILabel()
    private lazy var descriptionLabel = UILabel()
    private lazy var accountNoButton = UIButton(type: .system)
    private lazy var descriptionButton = UIButton(type: .system)

    private lazy var dismissButton = UIButton(type: .system)
    private lazy var backItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back"), style: .plain, target: nil, action: nil)
        return item
    }()

    private let bank: FirebaseModel.BankTransferConfig
    private lazy var disposeBag = DisposeBag()
}

// MARK: View's event handlers
extension BankTransferDetailVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension BankTransferDetailVC {
}

// MARK: Class's private methods
private extension BankTransferDetailVC {
    private func localize() {
        title = bank.bankName
    }
    private func visualize() {
        let tag1Label = UILabel()
        let tag2Label = UILabel()
        let tag3Label = UILabel()
        let tag4Label = UILabel()
        [tag1Label, tag2Label, tag3Label, tag4Label].forEach {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            $0.textColor = #colorLiteral(red: 0.4666666667, green: 0.4666666667, blue: 0.4666666667, alpha: 1)
            $0.snp.makeConstraints { $0.width.greaterThanOrEqualTo(90) }
        }

        [bankNameLabel, accountNoLabel, accountNameLabel, descriptionLabel].forEach {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            $0.lineBreakMode = .byWordWrapping
            $0.numberOfLines = 0
        }

        // Bank
        let bankView = UIStackView(arrangedSubviews: [tag1Label, bankNameLabel])
        bankView >>> {
            $0.axis = .horizontal
            $0.alignment = .top
            $0.distribution = .fillProportionally
            $0.spacing = 8
            tag1Label.text = "\(Config.bank):"
            bankNameLabel.text = bank.bankNameFull
        }

        // Account No
        let copyIcon1ImageView = UIImageView(image: #imageLiteral(resourceName: "ic_copy"))
        let accountNoView = UIStackView(arrangedSubviews: [tag2Label, accountNoLabel, copyIcon1ImageView])
        accountNoView >>> {
            $0.axis = .horizontal
            $0.distribution = .fillProportionally
            $0.spacing = 8
            tag2Label.text = "\(Config.accountNo):"
            accountNoLabel.text = bank.accountNumber
            accountNoLabel.textColor = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1)
        }
        copyIcon1ImageView >>> {
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints {
                $0.width.equalTo(16)
            }
        }

        // Account Name
        let accountNameView = UIStackView(arrangedSubviews: [tag3Label, accountNameLabel])
        accountNameView >>> {
            $0.axis = .horizontal
            $0.alignment = .top
            $0.distribution = .fillProportionally
            $0.spacing = 8
            tag3Label.text = "\(Config.accountName):"
            accountNameLabel.text = bank.accountName
        }

        // Description
        let copyIcon2ImageView = UIImageView(image: #imageLiteral(resourceName: "ic_copy"))
        let descriptionView = UIStackView(arrangedSubviews: [tag4Label, descriptionLabel, copyIcon2ImageView])
        descriptionView >>> {
            $0.axis = .horizontal
            $0.alignment = .top
            $0.distribution = .fillProportionally
            $0.spacing = 8
            tag4Label.text = "\(Config.description):"
            descriptionLabel.textColor = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1)
        }
        copyIcon2ImageView >>> {
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints {
                $0.width.equalTo(16)
            }
        }

        let containerView = UIView()

        // todo: Visualize view's here.
        let bankNameView = UIStackView(arrangedSubviews: [bankView,
                                                          generateLine(),
                                                          accountNoView,
                                                          generateLine(),
                                                          accountNameView,
                                                          generateLine(),
                                                          descriptionView])
        bankNameView >>> containerView >>> {
            $0.axis = .vertical
            $0.spacing = 16

            $0.snp.makeConstraints {
                $0.edges.equalTo(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
            }
        }

        let scrollView = UIScrollView()
        scrollView >>> view >>> { $0.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }}

        let bannerImageView = UIImageView()
        bannerImageView >>> scrollView >>> {
            $0.contentMode = .scaleAspectFit
            $0.kf.setImage(with: bank.banner)

            $0.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalToSuperview().inset(24)
                $0.leading.equalToSuperview().inset(24)
                $0.trailing.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }

        containerView >>> scrollView >>> {
            view.backgroundColor = .white

            $0.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
            $0.cornerRadius = 4
            $0.borderWidth = 1
            $0.borderColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)

            $0.snp.makeConstraints {
                $0.top.equalTo(bannerImageView.snp.bottom).offset(24)
                $0.leading.equalToSuperview().inset(16)
                $0.trailing.equalToSuperview().inset(16)
            }
        }

        // Add buttons
        navigationItem.leftBarButtonItems = [backItem]

        accountNoButton >>> containerView >>> { $0.snp.makeConstraints {
            $0.top.equalTo(accountNoLabel.snp.top)
            $0.leading.equalTo(accountNoLabel.snp.leading)
            $0.trailing.equalTo(copyIcon1ImageView.snp.trailing)
            $0.bottom.equalTo(accountNoLabel.snp.bottom)
        }}

        descriptionButton >>> containerView >>> { $0.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.top)
            $0.leading.equalTo(descriptionLabel.snp.leading)
            $0.trailing.equalTo(copyIcon2ImageView.snp.trailing)
            $0.bottom.equalTo(descriptionLabel.snp.bottom)
        }}

        dismissButton >>> scrollView >>> {
            $0.setTitle(Config.dismiss, for: .normal)
            $0.tintColor = .black
            $0.cornerRadius = 8
            $0.borderWidth = 1
            $0.borderColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)

            $0.snp.makeConstraints {
                $0.top.equalTo(containerView.snp.bottom).offset(112)
                $0.leading.equalTo(containerView.snp.leading)
                $0.trailing.equalTo(containerView.snp.trailing)
                $0.bottom.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }
    }
    private func setupRX() {
        listener?.phoneNumber.take(1)
            .map { phone -> String in
                if phone.hasPrefix("+84") {
                    return "0\(phone.substring(fromIndex: 3))"
                }
                return phone
            }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (phone) in
                self?.descriptionLabel.text = "[ \(phone) ] - \(self?.bank.content ?? "Thanh toán dịch vụ VATO")"
            })
            .disposed(by: disposeBag)

        backItem.rx.tap
            .bind { [weak self] in
                self?.listener?.handleBackItemAction()
            }
            .disposed(by: disposeBag)

        accountNoButton.rx.tap
            .bind { [weak self] in
                guard let wSelf = self else {
                    return
                }
                UIPasteboard.general.string = wSelf.accountNoLabel.text
                wSelf.showToast(with: Config.copied)
            }
            .disposed(by: disposeBag)

        descriptionButton.rx.tap
            .bind { [weak self] in
                guard let wSelf = self else {
                    return
                }
                UIPasteboard.general.string = wSelf.descriptionLabel.text
                wSelf.showToast(with: Config.copied)
            }
            .disposed(by: disposeBag)

        dismissButton.rx.tap
            .bind { [weak self] in
                self?.listener?.handleBackItemAction()
            }
            .disposed(by: disposeBag)
    }

    private func generateLine() -> UIImageView {
        let imageView = UIImageView()
        imageView.backgroundColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)
        imageView.snp.makeConstraints { $0.height.equalTo(1) }
        return imageView
    }

    private func showToast(with message: String) {
        Toast.show(using: message, on: view, layout: {
            $0.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.bottom.equalToSuperview().inset(20)
            }
        })
        .bind {
            printDebug("Complete!")
        }
        .disposed(by: disposeBag)
    }
}
