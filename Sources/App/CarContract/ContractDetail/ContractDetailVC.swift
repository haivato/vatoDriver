//  File name   : ContractDetailVC.swift
//
//  Author      : Phan Hai
//  Created date: 28/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxCocoa
import RxSwift

protocol ContractDetailPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var itemContractDetail: Observable<OrderContract> { get }
    var textError: Observable<String> { get }
    func moveBackHome()
    func moveToChat()
    func updateStatus() 
}

final class ContractDetailVC: UIViewController, ContractDetailPresentable, ContractDetailViewControllable{    
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: ContractDetailPresentableListener?
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = 0.1
        tableView.register(CarContractCell.nib, forCellReuseIdentifier: CarContractCell.identifier)
        tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        tableView.allowsSelection = false
    }
    @IBOutlet weak var sliderViewContainer: MBSliderView!
    @IBOutlet weak var tableView: UITableView!
    private var item: OrderContract?
    private var sliderView: MBSliderView = MBSliderView.createDefautTemplate()
    private var dataSource: Variable<[OrderContract]> = Variable.init([])
    @IBOutlet weak var hButtonSlider: NSLayoutConstraint!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    private let disposeBag = DisposeBag()
    
    /// Class's private properties.
}

// MARK: View's event handlers
extension ContractDetailVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension ContractDetailVC {
}

// MARK: Class's private methods
private extension ContractDetailVC {
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
        buttonLeft.rx.tap.bind { _ in
            self.listener?.moveBackHome()
        }.disposed(by: disposeBag)
        title = "Chi tiết hợp đồng"
        self.view.layoutIfNeeded()
        
        self.sliderView.delegate = self
        sliderView.text = "Bắt đầu chuyến đi"
        self.sliderViewContainer?.addSubview(self.sliderView)
        self.sliderView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
            make.height.equalToSuperview()
        }
        self.sliderViewContainer.isHidden = true
        
        self.sliderViewContainer?.backgroundColor = orangeColor
        let radius = (self.sliderViewContainer?.frame.size.height ?? 0)/2
        self.setViewRoundCorner(self.sliderViewContainer, withRadius: radius)
    }
    private func setupRX() {
        self.listener?.itemContractDetail.bind(onNext: weakify({ (item, wSelf) in
            wSelf.item = item
            wSelf.dataSource.value = [item]
            switch wSelf.item?.order_status {
            case .adminCancelOrder, .clientCancelOrder, .finished:
                
                wSelf.hButtonSlider.constant = 0
            default:
                guard let tripStatus =  wSelf.item?.trip_status else {
                    return
                }
                wSelf.sliderViewContainer.isHidden = false
                wSelf.updateSliderStatus(type: tripStatus)
            }
            wSelf.sliderView.resetDefaultState()
            wSelf.tableView.reloadData()
        })).disposed(by: disposeBag)
        
        self.dataSource.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: CarContractCell.identifier, cellType: CarContractCell.self)) {[weak self] (row, element, cell) in
                guard let wSelf = self else { return }
                switch wSelf.item?.order_status {
                case .adminCancelOrder, .clientCancelOrder, .finished:
                    cell.viewCarContract.updateUI(type: .DRIVER_FINISHED)
                default:
                    guard let tripStatus =  wSelf.item?.trip_status else {
                        return
                    }
                    wSelf.updateStatus(cell: cell, type: tripStatus)
                }
                cell.setupDisplay(item: wSelf.item)
                
                cell.call = {
                    var phone: String = ""
                    if let p = wSelf.item?.other_phone {
                        phone = p
                    } else {
                        phone = wSelf.item?.user?.phone ?? ""
                    }
                    if let url = URL(string: "tel://\(phone)") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
                cell.btChat = {
                    self?.listener?.moveToChat()
                }
        }.disposed(by: disposeBag)
        
        self.listener?.textError.bind(onNext: weakify({ (text, wSelf) in
            AlertVC.showMessageAlert(for: self,
                                     title: "Thông báo", message: text, actionButton1: "Đóng", actionButton2: nil, handler1: {
                                        wSelf.listener?.moveBackHome()
            }, handler2: nil)
            })).disposed(by: disposeBag)
        
    }
    private func updateStatus(cell: CarContractCell, type: TripContractStatus) {
        switch type {
        case .CREATED:
            cell.viewCarContract.updateUI(type: .CREATED)
        case .DRIVER_ACCEPTED:
            cell.viewCarContract.updateUI(type: .DRIVER_ACCEPTED)
        case .DRIVER_STARTED:
            cell.viewCarContract.updateUI(type: .DRIVER_STARTED)
        case .ADMIN_CANCELED, .CLIENT_CANCELED, .ADMIN_FINISHED, .DRIVER_FINISHED:
            cell.viewCarContract.updateUI(type: .DRIVER_FINISHED)
        default:
            break
        }
    }
    private func updateSliderStatus(type: TripContractStatus) {
        switch type {
        case .CREATED:
            self.sliderView.text = "Bắt đầu chuyến đi"
        case .DRIVER_ACCEPTED:
            self.sliderView.text = "Đi đón khách"
        case .DRIVER_STARTED:
            self.sliderView.text = "Kết thúc chuyến đi"
        case .DRIVER_FINISHED, .ADMIN_CANCELED, .CLIENT_CANCELED, .ADMIN_FINISHED:
            self.sliderViewContainer.isHidden = true
            self.hButtonSlider.constant = 0
        default:
            break
        }
    }
}
extension ContractDetailVC: MBSliderViewDelegate {
    func sliderDidSlide(_ slideView: MBSliderView!, shouldResetState reset: UnsafeMutablePointer<ObjCBool>!) {
        self.listener?.updateStatus()
    }
    
    
}
