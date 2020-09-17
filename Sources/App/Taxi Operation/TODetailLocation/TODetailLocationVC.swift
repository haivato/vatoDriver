//  File name   : TODetailLocationVC.swift
//
//  Author      : Dung Vu
//  Created date: 2/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

enum TODetailLocationVCType: Int {
    case all = 0
    case taxi4 = 1
    case taxi7 = 2
}

typealias ListPickUpDriver = [TODetailLocationVCType: [TODriverSectionType: [TODriverInfoModel]]]

protocol TODetailLocationPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var item: Observable<TODetailLocationProtocol?> { get }
    var listDriver: Observable<ListPickUpDriver> { get }
    var actionButtonType: Observable<TODetailLocationVC.ActionButtonType> { get }
    func TODetailLocationMoveBack()
    func actionButtonDidPressed()
    func requestLeavePickupStation()
    var eLoadingObser: Observable<(Bool, Double)> { get }
    var pickUpStationId: Int? { get }
}

final class TODetailLocationVC: UIViewController, TODetailLocationPresentable, TODetailLocationViewControllable {
    
    enum ActionButtonType {
        case request
        case leaveQueue
        case cancelRequest
        case pending
        
        func buttonConfig() -> (title: String, titleColor: UIColor, bgColor: UIColor, borderColor: UIColor) {
            switch self {
            case .request:
                return ("Yêu cầu xếp tài", .white, #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1), .clear)
            case .leaveQueue:
                return ("Huỷ xếp tài", #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1), .white, #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1))
            case .cancelRequest:
                return ("Huỷ yêu cầu xếp tài", #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1), .white, #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1))
            case .pending:
                return ("Chờ phản hồi", #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1), .white, #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1))
            }
        }
    }
    
    /// Class's public properties.
    weak var listener: TODetailLocationPresentableListener?
    private lazy var disposeBag = DisposeBag()
    private var disposeTimer: Disposable?
    private lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .grouped)
        t.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        return t
    }()
    private var actionButton: UIButton?
    // MARK: View's lifecycle
    override func loadView() {
        super.loadView()
        self.tableView.separatorColor = .clear
        self.tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 40
        self.tableView.register(TODriverNearbyTVC.nib, forCellReuseIdentifier: TODriverNearbyTVC.identifier)
    }
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
    private var source: ListPickUpDriver = [:]
    private var header: TODetailLocationHeader?
    private var cachedHeaderView: [Int: UIView] = [:]

    private var type = TODetailLocationVCType.all
    private var isLoading = false
}

// MARK: View's event handlers
extension TODetailLocationVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension TODetailLocationVC {
    func setupButtonAction(type: ActionButtonType) {
        let buttonConfig = type.buttonConfig()
        actionButton?.setTitleColor(buttonConfig.titleColor, for: .normal)
        actionButton?.setTitle(buttonConfig.title, for: .normal)
        actionButton?.backgroundColor = buttonConfig.bgColor
        actionButton?.layer.borderColor = buttonConfig.borderColor.cgColor
        
        disposeTimer?.dispose()
        if let itemId = self.listener?.pickUpStationId,
            type == .pending{
            disposeTimer = TOManageCommunication
                .shared
                .manageTimer[itemId]?
                .bind(onNext: { [weak self] (countDown) in
                    if countDown.remain > 0 {
                        self?.actionButton?.setTitle("\(buttonConfig.title) (\(countDown.remain)s)", for: .normal)
                    }
                })
        }
    }
    
    func showAlertConfirm() {
        AlertVC.showMessageAlert(for: self,
                                 title: "Xác nhận",
                                 message: "Bạn có chắc chắn muốn huỷ xếp tài?",
                                 actionButton1: "Không",
                                 actionButton2: "Huỷ Xếp Tài",
                                 handler2: { [weak self] in
                    self?.listener?.requestLeavePickupStation()
        })
    }
}

// MARK: Class's private methods
private extension TODetailLocationVC {
    private func localize() {
        // todo: Localize view's here.
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        let buttonLeft = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        buttonLeft.setImage(UIImage(named: "ic_arrow_navi_left"), for: .normal)
        buttonLeft.contentEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: buttonLeft)
        navigationItem.leftBarButtonItem = leftBarButton
        buttonLeft.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.TODetailLocationMoveBack()
        }).disposed(by: disposeBag)
       
        let lblVersion = LabelVersion(frame: .zero)
        lblVersion >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(15)
                make.bottom.equalTo(-20)
            }
        }
        
        let button = UIButton.create {
            $0.setTitle("Yêu cầu xếp tài", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.cornerRadius = 8
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.clear.cgColor
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            $0.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
            } >>> view >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(16)
                    make.right.equalTo(-16)
                    make.bottom.equalTo(lblVersion.snp.top)
                    make.height.equalTo(56)
                })
        }
        self.actionButton = button
        tableView >>> view >>> {
            $0.rowHeight = 80
            $0.snp.makeConstraints { (make) in
                make.left.top.right.equalToSuperview()
                make.bottom.equalTo(button.snp.top).offset(-10)
            }
        }
    }
    
    func setupRX() {
        listener?.actionButtonType.bind(onNext: { [weak self] (type) in
            self?.setupButtonAction(type: type)
        }).disposed(by: disposeBag)
        
        listener?.item.bind(onNext: weakify({ (i, wSelf) in
            wSelf.title = i?.name
            let info = i?.info ?? []
            let groups = RoundGroupView(frame: .zero, edges: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
            groups.update(sources: info)
            let s = groups.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width - 32, height: CGFloat.greatestFiniteMagnitude), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            
            let titles = ["TẤT CẢ", "4 CHỔ", "7 CHỖ"]
            let segment = VatoSegmentView(numberSegment: 3, space: 0) { [weak wSelf] (button, idx) in
                guard let wSelf = wSelf else { return }
                let text = titles[safe: idx]
                button.setTitle(text, for: .normal)
                button.setTitleColor(#colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1), for: .normal)
                button.setTitleColor(#colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1), for: .selected)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                button.rx.tap.bind { [weak wSelf] (_) in
                    guard let wSelf = wSelf,
                    let type = TODetailLocationVCType.init(rawValue: idx)else { return }
                    wSelf.type = type
                    wSelf.tableView.reloadData()
                }.disposed(by: wSelf.disposeBag)
            }
            let h: CGFloat = 48
            let space: CGFloat = 8
            let height = space + h + (info.isEmpty ? 0 : s.height)
            let header = TODetailLocationHeader(with: groups, size: s, segment: segment, hSegment: h, frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: height + 16)))
            header.backgroundColor = .white
            wSelf.header?.removeFromSuperview()
            wSelf.header = header
            
            self.view.addSubview(header)
            header.snp.makeConstraints { (make) in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(height + 16)
            }
            
            guard let actionButton = wSelf.actionButton else { return }
            wSelf.tableView.snp.remakeConstraints { (make) in
                make.top.equalTo(header.snp.bottom)
                make.left.right.equalToSuperview()
                make.bottom.equalTo(actionButton.snp.top).offset(-10)
            }
            
            if let i = i {
                actionButton.isHidden = !i.canRequestTaxiQueue
            }
            
        })).disposed(by: disposeBag)
        
        listener?.listDriver.bind(onNext: {[weak self] (listDriver) in
            guard let wSelf = self else { return }
            wSelf.source = listDriver
            wSelf.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        actionButton?.rx.tap.bind(onNext: weakify({ (wSelf) in
            guard wSelf.isLoading == false else { return }
            wSelf.listener?.actionButtonDidPressed()
        })).disposed(by: disposeBag)
        
        TOManageCommunication.shared.eLoadingObser.bind(onNext: { [weak self] (value) in
            self?.isLoading = value.0
            value.0 ? LoadingManager.instance.show() : LoadingManager.instance.dismiss()
        }).disposed(by: disposeBag)
        
        self.listener?.eLoadingObser.bind(onNext: { (value) in
            value.0 ? LoadingManager.instance.show() : LoadingManager.instance.dismiss()
        }).disposed(by: disposeBag)
        
        TOManageCommunication.shared.error.bind(onNext: { [weak self] (e) in
            guard let wSelf = self else { return }
            AlertVC.showError(for: wSelf, error: e)
        }).disposed(by: disposeBag)
    }
    
}

extension TODetailLocationVC {
    
}

extension TODetailLocationVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return source.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let status = TODriverSectionType.init(rawValue: section) else { return 0 }
        return source[self.type]?[status]?.count ?? 0
    }
    
    func tableView(_: UITableView, heightForHeaderInSection section : Int) -> CGFloat {
        guard TODriverSectionType.init(rawValue: section) != nil else { return 0.1 }
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let status = TODriverSectionType.init(rawValue: section) else { return nil }
        if let data = source[self.type]?[status] {
            if let v = cachedHeaderView[section] {
                let lable = v.viewWithTag(992) as? UILabel
                lable?.text = status.headerString(number: data.count)
                return v
            }
            let v = UIView()
            let label = UILabel(frame: .zero)
            label >>> v >>> {
                $0.tag = 992
                $0.textColor = #colorLiteral(red: 0.4623882771, green: 0.5225807428, blue: 0.5743968487, alpha: 1)
                $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                $0.text =  status.headerString(number: data.count)
                $0.snp.makeConstraints { (make) in
                    make.left.equalTo(16)
                    make.bottom.equalTo(-8)
                }
            }
            cachedHeaderView[section] = v
            return v
        }
        
        return nil
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TODriverNearbyTVC.identifier, for: indexPath) as? TODriverNearbyTVC else  {
            fatalError("")
        }
        
        cell.updateIndex(index: indexPath.row + 1)
        if let status = TODriverSectionType.init(rawValue: indexPath.section), let data = source[self.type]?[status] {
            cell.setupDisplay(item: data[indexPath.row])
        }
        
        return cell
    }

}
