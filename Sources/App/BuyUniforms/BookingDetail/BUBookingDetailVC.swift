//  File name   : BUBookingDetailVC.swift
//
//  Author      : vato.
//  Created date: 3/12/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import Eureka

protocol BUBookingDetailPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    
    var mBasket: Observable<BasketModel> { get }
    var store: Observable<FoodExploreItem?> { get }
    var eLoadingObser: Observable<(Bool, Double)> { get }
    var currentSelect: Observable<PaymentCardDetail> { get }
    
    func buyUniformsDetailMoveBackRoot()
    func didSelectCheckout()
    func bookingDetailMoveBack()
    func routeToSwitchPayment()
}

final class BUBookingDetailVC: FormViewController, BUBookingDetailPresentable, BUBookingDetailViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: BUBookingDetailPresentableListener?

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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
          return 0.1
      }
    /// Class's private properties.
    private lazy var disposeBag: DisposeBag = DisposeBag()
    private var header = BUStationView.loadXib()
    private var checkoutButton: UIButton?
    private var isLoading = false;
}

// MARK: View's event handlers
extension BUBookingDetailVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension BUBookingDetailVC {
    func showError(error: NSError) {
        AlertVC.showError(for: self, error: error)
    }
}

// MARK: Class's private methods
private extension BUBookingDetailVC {
    private func localize() {
        // todo: Localize view's here.
        self.title = "Mua đồng phục"
        
        let image = UIImage(named: "ic_back")?.withRenderingMode(.alwaysOriginal)
        let leftBarItem = UIBarButtonItem(image: image, landscapeImagePhone: image, style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = leftBarItem
        leftBarItem.rx.tap.bind { [weak self] in
            guard let wSelf = self else {
                return
            }
            wSelf.listener?.bookingDetailMoveBack()
        }.disposed(by: disposeBag)
        
        let imageR = UIImage(named: "ic_header_vato")?.withRenderingMode(.alwaysOriginal)
        let rightBarItem = UIBarButtonItem(image: imageR, landscapeImagePhone: imageR, style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = rightBarItem
        rightBarItem.rx.tap.bind { [weak self] in
            guard let wSelf = self else {
                return
            }
            wSelf.listener?.buyUniformsDetailMoveBackRoot()
        }.disposed(by: disposeBag)
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        self.view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        
        let lable = UILabel.create {
            $0.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 0.1)
            $0.textAlignment = .center
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.text = "Vui lòng xác nhận thông tin đơn hàng."
        }
        lable >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(48)
            }
        }
        header >>> view >>> {
            $0.button.isHidden = true
            $0.backgroundColor = .white
            $0.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(lable.snp_bottomMargin)
            }
        }
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(header.snp_bottomMargin)
        }
        
        let checkoutBtn = UIButton.create {
            $0.setTitleColor(.white, for: .normal)
            $0.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
            $0.cornerRadius = 24
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            $0.setTitle("Đặt hàng", for: .normal)
        }
        
        checkoutBtn >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
                make.top.equalTo(tableView.snp_bottomMargin)
                make.height.equalTo(48)
                make.bottom.equalToSuperview().offset(-30)
            }
        }
        self.checkoutButton = checkoutBtn
        
        let section = Section()
        section <<< BUBookingDetailCellEureka()
        UIView.performWithoutAnimation {
            self.form += [section]
        }
    }
    
    func reloadTable(basket: BasketModel) {
        self.form.removeAll()
        let section = Section()
        section <<< BUBookingDetailCellEureka("BUBookingDetailCellEureka") { row in
            row.cell.display(mBasket: basket)
            row.cell.btnChangeMethod?.rx.tap.bind(onNext: weakify({ (wSelf) in
                wSelf.listener?.routeToSwitchPayment()
            })).disposed(by: disposeBag)
        }
        UIView.performWithoutAnimation {
            self.form += [section]
        }
    }
    
    func setupListenChangeMethod() {
        listener?.currentSelect.bind(onNext: weakify({ (m, wSelf) in
            guard let row = wSelf.form.rowBy(tag: "BUBookingDetailCellEureka") as? BUBookingDetailCellEureka else {
                return
            }
            row.cell.lblMethod?.text = m.type.generalName.uppercased()
            row.cell.bgMethod?.backgroundColor = m.type.color
        })).disposed(by: disposeBag)
    }
    
    func setupRX() {
        listener?.eLoadingObser.bind(onNext: { [weak self] (value) in
            self?.isLoading = value.0
            value.0 ? LoadingManager.instance.show() : LoadingManager.instance.dismiss()
        }).disposed(by: disposeBag)
        
        listener?.store.bind(onNext: { [weak self] (item) in
            self?.header.titleLabel.text = item?.name
            self?.header.subTitle.text = item?.address
        }).disposed(by: disposeBag)
        
        listener?.mBasket.bind(onNext: { [weak self] (basket) in
            self?.reloadTable(basket: basket)
            self?.setupListenChangeMethod()
        }).disposed(by: disposeBag)
        
        self.checkoutButton?.rx.tap.bind(onNext: { [weak self] (_) in
            if self?.isLoading == true { return }
            self?.listener?.didSelectCheckout()
        }).disposed(by: disposeBag)
    }
    
}
