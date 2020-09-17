//
//  TripMapInfoView.swift
//  FC
//
//  Created by khoi tran on 3/20/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import RxSwift
import FwiCore
import FwiCoreRX
import VatoNetwork
import Alamofire


@objcMembers
class TripMapInfoView: UIView, UpdateDisplayProtocol, Weakifiable {
    
    struct Config {
        static let cellHeight: CGFloat = 70
    }
    @IBOutlet weak var locationTableView: UITableView!
    @IBOutlet weak var lblTripStatus: UILabel!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var stvBottom: UIStackView!
    
    @IBOutlet weak var lblService: UILabel!
    @IBOutlet weak var viewService: UIView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var viewPrice: UIView!
    @IBOutlet weak var lblPaymentMethod: UILabel!
    @IBOutlet weak var viewPaymentMethod: UIView!
    @IBOutlet weak var lblPromotion: UILabel!
    @IBOutlet weak var viewPromotion: UIView!
    @IBOutlet weak var locationTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var lbTextMoney: UILabel!
    @IBOutlet weak var imgViewBonus: UIImageView!
    @IBOutlet weak var noteView: UIView!
    @IBOutlet weak var lbNote: UILabel!
    @IBOutlet weak var hLbMoney: NSLayoutConstraint!
    
    private var booking: FCBooking?
    private var source: [TripMapLocationDisplay] = []
    
    private var locationPickerWrapper: LocationPickerWrapperObjC?
    private var addDestinationConfirmWrapper: AddDestinationConfirmWrapper?
    private var hadNewPrice = false
    
    private var disposeBag = DisposeBag()
    
    @Replay(queue: MainScheduler.asyncInstance) var info: AddDestinationTripInfo?
    private lazy var networkRequester = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
    private var isEditing = false
    private var allowModify = false
    private var isUseLast = false
    private var controller: UIViewController?
    @IBOutlet weak var hNoteView: NSLayoutConstraint!
    @objc var showAlert: ((_ tap: UITapGestureRecognizer) -> Void)?
    private var viewBG: BottomCornerView?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.visualize()
        self.setupRX()
    }
    
    private func visualize() {
        self.locationTableView.delegate = self
        self.locationTableView.dataSource = self
        self.locationTableView.register(TripMapLocationTVC.nib, forCellReuseIdentifier: TripMapLocationTVC.identifier)
        
        self.imgViewBonus.isHidden = true
    }
    
   @objc func setupDisplay(item: FCBooking?) {
        self.booking = item
        if self.booking != nil {
            self.requestTripDetail()
        }
    }
    
    @objc public func startTrip(item: FCBooking?) {
        guard let item = item else { return }
        self.booking = item
        lblTripStatus.text = "TRẢ KHÁCH"
        if item.deliveryMode() || item.deliveryFoodMode() {
            lblTripStatus.text = "Đang đi giao hàng"
        }
        if item.info.serviceId == 1024 {
            lbTextMoney.text = ""
        } else {
            switch item.info.payment {
            case PaymentMethodCash:
                lbTextMoney.text = ""
                self.hLbMoney.constant = 0
            default:
                lbTextMoney.text = "KHÔNG THU TIỀN MẶT CỦA KHÁCH HÀNG"
            }
        }
        isUseLast = true
        self.updateNoteView(item: item)
    }
    
    private func updateNoteView(item: FCBooking) {
        guard item.info.note != nil && item.info.note == " " else {
            self.noteView.isHidden = true
            self.hNoteView.constant = 5
            return
        }
        self.lbNote.text = item.info.note
        let text = item.info.note
        self.scanerPhoneNumber(text) { (phone, range) in
            if ((phone != nil) && range.length > 0) {
                self.lbNote.underlineText(originString: text, at: range)
            }
        }
    }
    
    @objc public func receiveVisitor(item: FCBooking?) {
        guard let item = item else { return }
        self.booking = item
        
        lblTripStatus.text = "ĐÓN KHÁCH";
        if (item.info?.serviceId == 1024) {
            lblTripStatus.text = "Đang đi mua hàng"
        } else if (item.deliveryMode()) {
            lblTripStatus.text = "Đang đi nhận hàng";
        } else if (item.deliveryFoodMode()) {
            lblTripStatus.text = "Đang đến cửa hàng";
        }
        //setup
        if item.info.serviceId == 1024 {
            lbTextMoney.text = ""
        } else {
            switch item.info.payment {
            case PaymentMethodCash:
                lbTextMoney.text = ""
                self.hLbMoney.constant = 0
            default:
                lbTextMoney.text = "KHÔNG THU TIỀN MẶT CỦA KHÁCH HÀNG"
            }
        }
        self.updateNoteView(item: item)
    }
    
    @objc public func updatePriceView(started: Bool, booking: FCBooking?, hideTarget: Bool) {
        guard let booking = self.booking, !hadNewPrice else { return }
        self.lblService.text = booking.info.localizeServiceName()
        switch booking.info.payment {
        case PaymentMethodVisa, PaymentMethodMastercard:
            self.lblPaymentMethod.text = "Visa/Master"
            self.lblPaymentMethod.textColor = .white
            self.viewPaymentMethod.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.4862745098, blue: 0.1333333333, alpha: 1)
        case PaymentMethodATM:
            self.lblPaymentMethod.text = "ATM"
            self.lblPaymentMethod.textColor = .white
            self.viewPaymentMethod.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.4862745098, blue: 0.1333333333, alpha: 1)
        case PaymentMethodVATOPay:
            self.lblPaymentMethod.text = "VATOPay"
            self.lblPaymentMethod.textColor = .white
            self.viewPaymentMethod.backgroundColor =  #colorLiteral(red: 0.937254902, green: 0.4862745098, blue: 0.1333333333, alpha: 1)
        default:
            self.lblPaymentMethod.text = "Tiền mặt"
            self.lblPaymentMethod.textColor = .black
            self.viewPaymentMethod.backgroundColor = #colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8705882353, alpha: 1)
        }
        
        if let promotion = booking.info.promotionCode, !promotion.isEmpty  {
            self.lblPromotion.text = "KM"
            self.viewPromotion.isHidden = false
        } else {
            self.lblPromotion.text = ""
            self.viewPromotion.isHidden = true
        }
        
        if booking.info.getDiscountAmount() > 0 {
            self.lblPromotion.text = "KM"
            self.viewPromotion.isHidden = false
        }
        
        
        let isDigitalTrip = (booking.info.tripType == Int(BookTypeOneTouch.rawValue))
        if (isDigitalTrip) {
            self.lblPrice.text = ""
            self.viewPrice.isHidden = true
        } else {
                let bookPrice = booking.info.getBookPrice()
                let offerPrice = bookPrice + booking.info.additionPrice

            if (hideTarget) {
                self.lblPrice.text = ""
                self.viewPrice.isHidden = true
            } else {
                self.lblPrice.text = offerPrice.currency
                self.viewPrice.isHidden = false
            }
        }
        
        if let bookExtraData = booking.extraData {
            self.imgViewBonus.isHidden = (bookExtraData.partnerTipping == 0) ? true : false
        }
    }
    
    @objc func initRibWrapper(controller: UIViewController) {
        locationPickerWrapper = LocationPickerWrapperObjC.init(with: controller)
        locationPickerWrapper?.delegate = self
        
        addDestinationConfirmWrapper = AddDestinationConfirmWrapper.init(with: controller)
        addDestinationConfirmWrapper?.delegate = self
        
        self.controller = controller
        
        AddDestinationCommunication.shared.delegate = self
    }
    
    func useLast() {
        defer {
            self.locationTableView?.reloadData()
        }
        guard !source.isEmpty, source.count > 1 else { return }
        var newSource = source
        isUseLast = true
        newSource.removeFirst()
        source = newSource
    }
    
    @objc func updateLastPriceView(price: NSInteger) {
        self.lblPrice.text = price.currency
    }
    @IBAction func noteClick(_ sender: UITapGestureRecognizer) {
        self.showAlert?(sender)
    }
}

extension TripMapInfoView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let height = CGFloat(min(3, self.source.count)) * Config.cellHeight
        self.locationTableViewHeight.constant = height
        return source.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Config.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TripMapLocationTVC.identifier, for: indexPath) as? TripMapLocationTVC else {
            fatalError("")
        }
        
        cell.setupDisplay(item: source[indexPath.row])
        
        let canModify = (indexPath.row == source.count-1) && self.allowModify
        let viewDotHidden = self.source.count == 1 || indexPath.row == source.count-1
        cell.updateDisplay(isAllowEdit: false, isAllowAddNew: canModify, viewDotHidden: viewDotHidden)
        
        if booking?.info.serviceId == VatoServiceFood.rawValue {
            cell.btnEdit.rx.tap
                .takeUntil(cell.rx.methodInvoked(#selector(UITableViewCell.prepareForReuse)))
                .subscribe(onNext: {[weak self] _ in
                    guard let wSelf = self else { return }
                    if let url = URL(string: "tel://\(wSelf.booking?.info.contactPhone ?? "")") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }).disposed(by: disposeBag)
            
        } else {
            cell.btnEdit.rx.tap
                .takeUntil(cell.rx.methodInvoked(#selector(UITableViewCell.prepareForReuse)))
                .subscribe(onNext: {[weak self] _ in
                    guard let wSelf = self else { return }
                    wSelf.isEditing = true
                    if let locationPickerWrapper = wSelf.locationPickerWrapper {
                        locationPickerWrapper.placeModel = wSelf.source[indexPath.row].address
                        locationPickerWrapper.present()
                    }
                }).disposed(by: disposeBag)
        }
        
        cell.btnAdd.rx.tap
            .takeUntil(cell.rx.methodInvoked(#selector(UITableViewCell.prepareForReuse)))
            .subscribe(onNext: {[weak self] _ in
                guard let wSelf = self else { return }
                wSelf.isEditing = false
                if let locationPickerWrapper = wSelf.locationPickerWrapper {
                    locationPickerWrapper.placeModel = wSelf.source[indexPath.row].address
                    locationPickerWrapper.present()
                }
            }).disposed(by: disposeBag)
        
        
        if booking?.info.tripType == 30 {
            cell.btnAdd.isHidden = true
        }
        
        if booking?.info.serviceId == VatoServiceFood.rawValue && indexPath.row == 0 {
            cell.btnEdit.setImage(UIImage(named: "ic_call_shop"), for: .normal)
            cell.btnEdit.isHidden = false
        }
        
        if booking?.info.serviceId == VatoServiceFood.rawValue && self.source.count <= 1 {
            cell.btnEdit.isHidden = true
        }
        
        return cell
    }

    
}

extension TripMapInfoView: LocationPickerDelegateProtocol {
    func didSelectAddress(model: AddressProtocol) {
        guard let booking = self.booking else { return }
        var type: AddDestinationType
        if self.isEditing {
            type = .edit(destination: model)
        } else {
            type = .new(destination: model)
        }
        
        addDestinationConfirmWrapper?.present(type: type, tripId: booking.info.tripId)
    }
}


extension TripMapInfoView {
    func requestTripDetail() {
        guard let tripId = self.booking?.info.tripId else {
            return
        }
        let router = VatoAPIRouter.customPath(authToken: "", path: "trip/trip_detail", header: nil, params: ["id": tripId], useFullPath: false)
        networkRequester.request(using: router, decodeTo: OptionalMessageDTO<AddDestinationTripInfo>.self).bind(onNext: weakify({ (result, wSelf) in
            switch result {
            case .success(let r):
                wSelf.info = r.data
            case .failure(let e):
                print(e.localizedDescription)
            }
        })).disposed(by: disposeBag)
    }
 
    
    private func setupRX() {
        $info.filterNil().bind(onNext: weakify({ (info, wSelf) in
            if let editable = info.trip?.fromSource?.editable {
                wSelf.allowModify = editable
            } else {
                wSelf.allowModify = false
            }
            //            self.lblPrice.text = info.trip?.price.currency ?? ""
            
            var newSource = TripMapLocationModel.initLocations(addDestinationTripInfo: info)
            if wSelf.isUseLast {
                newSource.removeFirst()
            }
            self.source = newSource
            wSelf.locationTableView.reloadData()
            self.backgroundColor = .white
            
            //setup
            if self.booking?.info.serviceId != 1024 {
                if let v = self.viewBG {
                    v.removeFromSuperview()
                }
                self.viewBG = BottomCornerView(with: 7)
                self.viewBG?.containerColor = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1)
                if let v = self.viewBG {
                    self.insertSubview(v, at: 0)
                    v >>> {
                        $0.snp.makeConstraints({ (make) in
                            make.edges.equalToSuperview()
                        })
                    }
                }
            } else {
                self.backgroundColor = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1)
            }
        })).disposed(by: disposeBag)
    }
}


extension TripMapInfoView: AddDestinationConfirmWrapperDelegate {
    func addDestinationSuccess(points: [DestinationPoint], newPrice: AddDestinationNewPrice) {
        if let last = points.last {
            var locationModel = TripMapLocationModel.init(address: last.address)
            locationModel.isOrigin = false
            self.source.append(locationModel)
            self.locationTableView.reloadData()
        }
        
        self.viewPromotion.isHidden = true
//        self.lblPrice.text = newPrice.final_fare.currency
        
        self.hadNewPrice = true
    }
}

extension Notification.Name {
    static let addDestinationTripCancel = Notification.Name(rawValue: "addDestinationCancel")
}

extension TripMapInfoView: AddDestinationProtocol {
    func showConfirmView(detail: AddDestinationRequestDetail) {
        
        self.$info.take(1).observeOn(MainScheduler.asyncInstance).bind(onNext: weakify({ (info, wSelf) in
            guard let controller = wSelf.controller, let trip = info?.trip, let booking = wSelf.booking else { return }
            
            if wSelf.booking?.info.tripId != detail.tripId {
                return
            }
            
            let actionCancel = AlertAction(style: .newCancel, title: "Huỷ bỏ") { [weak self] in
                guard let wSelf = self else { return }
                wSelf.reponseChangeAddress(orderId: detail.id, action: .reject, reason: "Huỷ thêm.")
            }
            let style = StyleButton(view: .newDefault, textColor: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), font: .systemFont(ofSize: 15, weight: .medium), cornerRadius: 0, borderWidth: 0, borderColor: .clear)
            let eCancel = NotificationCenter.default.rx.notification(.addDestinationTripCancel).map { _ in }
            let actionOK = AlertActionTimer(style: style, timeInterval: 30, invokedMethod: eCancel, delegateUI: { (seconds, button) in
                button?.setTitle("Đồng ý(\(Int(seconds))s)", for: .normal)
            }) { [weak self] in
                guard let wSelf = self else { return }
                wSelf.reponseChangeAddress(orderId: detail.id, action: .accept)
            }
            
                
            let v = ConfirmChangeAddressView.loadXib()
            let bookPrice = booking.info.getBookPrice()
            let offerPrice = bookPrice + booking.info.additionPrice
            v.updateOldPriceView(oldPrice: offerPrice.currency)
            v.setupDisplay(item: detail)
            
            AlertCustomVC.show(on: controller, option: .customView, arguments: [AlertCustomOption.customView: v], buttons: [actionCancel, actionOK], orderType: .horizontal)
            })).disposed(by: disposeBag)
    }
    
    func reponseChangeAddress(orderId:Int?, action: AddDestinationActionType, reason: String? = nil) {
        guard let orderId = orderId else { return }
        var params = [String: Any]()
        params["reason"] = reason ?? ""
        params["status"] = action.rawValue
        let router = VatoAPIRouter.customPath(authToken: "", path: "driver/destination-orders/\(orderId)", header: nil, params: params, useFullPath: false)
        networkRequester.request(using: router, decodeTo: OptionalMessageDTO<String>.self, method: .put, encoding: JSONEncoding.default).bind(onNext: weakify({ (result, wSelf) in
            switch result {
            case .success(let s):
                if s.status == 200 {
                    if action == .accept {
                        wSelf.reloadTrip()
                    }
                } else {
                     wSelf.showErrorView(message: "Không thể thực hiện tác vụ!")
                }
            case .failure(let e):
                wSelf.showErrorView(message: e.localizedDescription)
            }
        })).disposed(by: disposeBag)
    }
    
    func reloadTrip() {
        self.requestTripDetail()
    }
    
    func showErrorView(message: String) {
        AlertVC.showError(for: self.controller, message: message)
    }
}
