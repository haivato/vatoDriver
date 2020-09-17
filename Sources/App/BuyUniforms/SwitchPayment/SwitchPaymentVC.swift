//  File name   : SwitchPaymentVC.swift
//
//  Author      : Dung Vu
//  Created date: 3/12/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import UIKit
import RxCocoa
import Kingfisher
import FwiCoreRX

final class SwitchPaymentCell: UITableViewCell {
    private var iconView: UIImageView?
    private var lblTitle: UILabel?
    private var iconCheck: UIImageView?
    private var task: DownloadTask?
    
    
    override var isSelected: Bool {
        didSet {
            iconCheck?.isHighlighted = isSelected
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.task?.cancel()
        self.iconView?.image = nil
        
    }
    
    private func visualize() {
        self.selectionStyle = .none
        let iconView = UIImageView(frame: .zero) >>> contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.size.equalTo(CGSize(width: 46, height: 36))
                make.centerY.equalToSuperview()
            })
        }
        
        self.iconView = iconView
        
        let iconCheck = UIImageView.create {
            $0.highlightedImage = UIImage(named: "ic_payment_check")
            } >>> contentView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.right.equalTo(-16)
                    make.size.equalTo(CGSize(width: 20, height: 20))
                    make.centerY.equalToSuperview()
                })
        }
        self.iconCheck = iconCheck
        
        let lblTitle = UILabel.create {
            $0.textColor = .black
            $0.font = UIFont.systemFont(ofSize: 16)
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            } >>> contentView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(74)
                    make.centerY.equalToSuperview()
                    make.right.equalTo(iconCheck.snp.left).offset(-5)
                })
        }
        self.lblTitle = lblTitle
    }
    
    func setupDisplay(by card: PaymentCardDetail) {
        let p = UIImage(named: card.placeHolder)
        self.iconView?.image = p
        let url = URL(string: card.iconUrl.orNil(""))
        self.task = self.iconView?.kf.setImage(with: url, placeholder: p)
        let brand = card.brand.orNil("")
        let number = card.number.orNil("")
        var text: String = brand
        if number.count > 0 {
            let last = number.suffix(4)
            text = text + " ***\(last)"
        }
        self.lblTitle?.text = text
    }
}

protocol SwitchPaymentPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var source: Observable<[PaymentCardDetail]> { get }
    var currentSelect: PaymentCardDetail { get }
    var error: Observable<Error> { get }

    func switchPaymentMoveBack()
    func switchPaymentSelect(at idx: IndexPath)
}

final class SwitchPaymentVC: UIViewController, SwitchPaymentPresentable, SwitchPaymentViewControllable, DisposableProtocol {

    struct Config {
        static let title = Text.paymentMethod.localizedText
        static let header = Text.selectPaymentMethod.localizedText.capitalized
        
        struct Error {
            static let title = Text.error.localizedText
            static let messageError = Text.thereWasAnError.localizedText
            static let close = Text.dismiss.localizedText
        }
    }
    
    /// Class's public properties.
    weak var listener: SwitchPaymentPresentableListener?
    lazy var disposeBag = DisposeBag()
    
    private lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .grouped)
        t.rowHeight = 69
        t.separatorInset = UIEdgeInsets(top: 0, left: 74, bottom: 0, right: 0)
        return t
    }()

    
    private var addNewBtn = UIButton(frame: .zero)
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
}

// MARK: View's event handlers
extension SwitchPaymentVC {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}


// MARK: Class's public methods
extension SwitchPaymentVC {
}

// MARK: Class's private methods
private extension SwitchPaymentVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        UIApplication.setStatusBar(using: .lightContent)
        self.view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.barTintColor = Color.darkGreen
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        self.title = Config.title
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.tableView.backgroundColor = .clear
        
        let image = UIImage(named: "ic_close")?.withRenderingMode(.alwaysTemplate)
        let rightBarItem = UIBarButtonItem(image: image, landscapeImagePhone: image, style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = rightBarItem
        
        rightBarItem.rx.tap.bind { [unowned self] in
            self.listener?.switchPaymentMoveBack()
        }.disposed(by: disposeBag)
        
        
        tableView.register(SwitchPaymentCell.self, forCellReuseIdentifier: SwitchPaymentCell.identifier)
        tableView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
    }
    
    private func setupRX() {
        // todo: Bind data to UI here.
        self.tableView.rx.setDelegate(self).disposed(by: disposeBag)
        self.listener?.source
            .bind(to: tableView.rx.items(cellIdentifier: SwitchPaymentCell.identifier, cellType: SwitchPaymentCell.self))
            { [weak self](row, element, cell) in
                cell.setupDisplay(by: element)
                cell.isSelected = self?.listener?.currentSelect == element
            }.disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected.bind { [weak self] idx in
            self?.listener?.switchPaymentSelect(at: idx)
        }.disposed(by: disposeBag)
        
        self.listener?.error.subscribe(onNext: { [weak self] _ in
            self?.alertError()
        }).disposed(by: disposeBag)
        
    }
    
    private func alertError() {
        let action = AlertAction.init(style: .cancel, title: Config.Error.close) {}
        AlertVC.show(on: self, title: Config.Error.title, message: Config.Error.messageError, from: [action], orderType: .horizontal)
    }
}

extension SwitchPaymentVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.create {
            $0.backgroundColor = .clear
        }
        
        UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.textColor = #colorLiteral(red: 0.3843137255, green: 0.4431372549, blue: 0.4980392157, alpha: 1)
            $0.text = Config.header
            } >>> view >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(16)
                    make.bottom.equalTo(-8)
                })
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}
