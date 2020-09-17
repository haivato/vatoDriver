//  File name   : TOShortcutVC.swift
//
//  Author      : khoi tran
//  Created date: 2/17/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import FwiCoreRX
import FwiCore
import SnapKit
import RxSwift
import RxCocoa

protocol TOShortcutPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var dataSource: Observable<[TOShortutModel]> { get }
    func requestData()
    func routeToNearbyDriver()
    func routeToOrder()
    func routeToQuickSupport()
    func showTripDigital()
    func TOShortcutListenerMoveBack()
    func getBadgeQuickSupport()
    func loadCreateCar()
    func routeToBU()
    func routeToFavouritePlace()
    func processingRequest()
    func registerFood(typeRequest: ProcessRequestType)
    func registerService()
    var eLoadingObser: Observable<(Bool,Double)> { get }
    
}

final class TOShortcutVC: UIViewController, TOShortcutPresentable, TOShortcutViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: TOShortcutPresentableListener?
    
    final override var hidesBottomBarWhenPushed: Bool {
        get {
            return navigationController?.viewControllers.last != self
        } set {
            super.hidesBottomBarWhenPushed = newValue
        }
    }
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRX()
        visualize()
        self.listener?.requestData()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.setStatusBar(using: .lightContent)
        self.listener?.getBadgeQuickSupport()
        localize()
    }
    
    /// Class's private properties.
    private var tableView: UITableView = UITableView(frame: .zero, style: .plain)
    var source:[TOShortutModel] = []
    private var disposeBag = DisposeBag()
    
}

// MARK: View's event handlers
extension TOShortcutVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension TOShortcutVC {
}

// MARK: Class's private methods
private extension TOShortcutVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.setupNavigation()
        tableView.estimatedRowHeight = 40
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
        
        tableView.register(TOShortcutTVC.nib, forCellReuseIdentifier: TOShortcutTVC.identifier)
        tableView.register(TOShortcutAutoReceiveTripTVC.nib, forCellReuseIdentifier: TOShortcutAutoReceiveTripTVC.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(view.layoutMarginsGuide.snp.top)
                make.right.bottom.left.equalToSuperview()
            }
        }
    }
    
    func setupRX() {
        listener?.eLoadingObser.bind(onNext: { (item) in
            item.0 ? LoadingManager.instance.show() : LoadingManager.instance.dismiss()
        }).disposed(by: disposeBag)
        
        
        self.listener?.dataSource.bind(onNext: {[weak self] listShortcut in
            guard let me = self else { return }
            me.source = listShortcut
            me.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        let buttonLeft = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        buttonLeft.setImage(UIImage(named: "ic_arrow_navi_left"), for: .normal)
        buttonLeft.contentEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: buttonLeft)
        navigationItem.leftBarButtonItem = leftBarButton
        buttonLeft.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.TOShortcutListenerMoveBack()
        }).disposed(by: disposeBag)
    }
    
    func showAlertCreateCar() {
        AlertVC.showMessageAlert(for: self, title: "Thông báo", message: "Rấc tiếc, bạn chưa đăng ký xe nào trong hệ thống.\nĐăng ký ngay!", actionButton1: "Đóng", actionButton2: "Đăng ký", handler1: {
        }, handler2: { [weak self] in
            self?.listener?.loadCreateCar()
        })
    }

    func changeModeAutoReceiTrip(switchOnOff: UISwitch) {
        let driver = UserManager.shared.getCurrentUser()
        guard driver?.vehicle != nil else {
            self.showAlertCreateCar()
            AutoReceiveTripManager.shared.flagAutoReceiveTripManager = false
            switchOnOff.setOn(false, animated: false)
            return
        }
        guard let accept = UserManager.shared.autoAccept, accept else {
            AlertVC.showMessageAlert(for: self,
                                     title: "Thông báo",
                                     message: "Tính năng đang tạm khoá. Vui lòng gửi yêu cầu hỗ trợ hoặc gọi 19006667.",
                                     actionButton1: "Đóng",
                                     actionButton2: nil)
            AutoReceiveTripManager.shared.flagAutoReceiveTripManager = false
            switchOnOff.setOn(false, animated: false)
            return
        }
        
        if switchOnOff.isOn == true {
            AlertVC.showMessageAlert(for: self,
                                     title: "Xác nhận",
                                     message: "Bạn có thực sự muốn bật tính năng tự động nhận chuyến?",
                                     actionButton1: "Hủy",
                                     actionButton2: "Bật",
                                     handler1: {
                switchOnOff.setOn(false, animated: false)
            }, handler2:  {
                AutoReceiveTripManager.shared.flagAutoReceiveTripManager = switchOnOff.isOn
            })
        } else {
            AutoReceiveTripManager.shared.flagAutoReceiveTripManager = switchOnOff.isOn
        }
    }
}


extension TOShortcutVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = source[indexPath.row]
        if model.type == .autoReceiveTrip {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TOShortcutAutoReceiveTripTVC.identifier, for: indexPath) as? TOShortcutAutoReceiveTripTVC else  {
                fatalError("")
            }
            cell.didSelectswitch = { [weak self] switchOnOff in
                guard let switchOnOff = switchOnOff else { return }
                self?.changeModeAutoReceiTrip(switchOnOff: switchOnOff)
            }
            cell.setupDisplayIndex(index: indexPath)
            cell.setupDisplay(item: source[indexPath.row])
            cell.switchOnOff.setOn(AutoReceiveTripManager.shared.flagAutoReceiveTripManager, animated: false)
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TOShortcutTVC.identifier, for: indexPath) as? TOShortcutTVC else  {
            fatalError("")
        }
        
        cell.setupDisplayIndex(index: indexPath)
        cell.setupDisplay(item: source[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.handleSelection(item: self.source[indexPath.row])
    }
    
    private func setupNavigation() {
        self.title = "Menu nhanh"
    }
    
    func handleSelection(item: TOShortutModel) {
        switch item.type {
        case .digitalClock:
            self.listener?.showTripDigital()
        case .quickSupport:
            self.listener?.routeToQuickSupport()
        case .orderTaxi:
            self.listener?.routeToOrder()
        case .autoReceiveTrip:
            break
        case .buyUniforms:
            self.listener?.routeToBU()
        case .favPlace:
            self.listener?.routeToFavouritePlace()
        case .processingRequest:
            self.listener?.processingRequest()
        case .registerFood:
            self.listener?.registerFood(typeRequest: .REGISTER_FOOD)
        case .registerService:
            self.listener?.registerService()
        }
    }
    
}
