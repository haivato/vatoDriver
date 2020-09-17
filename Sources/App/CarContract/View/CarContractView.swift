//
//  CarContractView.swift
//  FC
//
//  Created by Phan Hai on 28/08/2020.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
enum OrderContractType {
    case listRequest
    case contract
    case seeMore
    case explain
    case detail
}

enum OrderContractStatus: String, Codable {
    case NEW, CONFIRMED, ASSIGNED, DRIVER_STARTED, DRIVER_ACCEPTED, DRIVER_FINISHED, DEPOSITED, FINISHED, CLIENT_CANCELED, ADMIN_CANCELED
}
enum TripContractStatus: String, Codable {
    case Start, PickUp, InTrip, CREATED, DRIVER_ACCEPTED, DRIVER_STARTED, DRIVER_FINISHED, CLIENT_CANCELED, ADMIN_CANCELED, ADMIN_FINISHED
}

class CarContractView: UIView {
    struct Config {
        static let wAvatar: CGFloat = 59
        static let paddingAvatar: CGFloat = -30
        static let sizeArrow: CGSize = CGSize(width: 20, height: 8)
    }
    @IBOutlet weak var viewStatus: UIView!
    @IBOutlet weak var viewBill: UIView!
    @IBOutlet weak var viewRestPrice: UIView!
    @IBOutlet weak var viewInforUser: UIView!
    @IBOutlet weak var viewAvatar: UIView!
    @IBOutlet weak var btChat: UIButton!
    @IBOutlet weak var btCancel: UIButton!
    @IBOutlet weak var viewLocation: UIView!
    @IBOutlet weak var stackViewButton: UIStackView!
    @IBOutlet weak var viewLineTime: UIView!
    @IBOutlet weak var hViewButton: NSLayoutConstraint!
    @IBOutlet weak var viewButton: UIView!
    @IBOutlet weak var viewTotalPrice: UIView!
    @IBOutlet weak var viewDestination: UIView!
    @IBOutlet weak var vNote: UIView!
    @IBOutlet weak var viewLineLocation: UIView!
    @IBOutlet weak var vHistoryDeposit: UIView!
    @IBOutlet weak var vHistoryPaid: UIView!
    @IBOutlet weak var vLineDeposit: UIView!
    @IBOutlet weak var vLineBill: UIView!
    
    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var lbTripID: UILabel!
    @IBOutlet weak var lbTimeStart: UILabel!
    @IBOutlet weak var lbDateStart: UILabel!
    @IBOutlet weak var lbTimeEnd: UILabel!
    @IBOutlet weak var lbDateEnd: UILabel!
    @IBOutlet weak var lblbDestinationHistory: UILabel!
    @IBOutlet weak var lbSubDestinationHistory: UILabel!
    @IBOutlet weak var lbPickUp: UILabel!
    @IBOutlet weak var lbSubPickUp: UILabel!
    @IBOutlet weak var lbDestination: UILabel!
    @IBOutlet weak var lbSubDestination: UILabel!
    @IBOutlet weak var lbGuest: UILabel!
    @IBOutlet weak var lbStandard: UILabel!
    @IBOutlet weak var lbService: UILabel!
    @IBOutlet weak var lbNote: UILabel!
    @IBOutlet weak var lbTotalPrice: UILabel!
    @IBOutlet weak var lbPricePaid: UILabel!
    @IBOutlet weak var lbRestPrice: UILabel!
    @IBOutlet weak var lbPriceTotal: UILabel!
    @IBOutlet weak var lbFullNameClient: UILabel!
    @IBOutlet weak var lbNumberPhoneClient: UILabel!
    @IBOutlet weak var lbEmailClient: UILabel!
    @IBOutlet weak var imgAvatarClient: UIImageView!
    @IBOutlet weak var lbNameClient: UILabel!
    @IBOutlet weak var lbRestText: UILabel!
    @IBOutlet weak var lbDepositHistory: UILabel!
    @IBOutlet weak var lbPaidHistory: UILabel!
    @IBOutlet weak var lbDateDropOff: UILabel!
    
    var type: ContractCarOrderType = .listRequest
    override func awakeFromNib() {
        super.awakeFromNib()
        visualize()
    }
}
extension CarContractView {
    private func visualize() {
        let viewBG = HeaderCornerView(with: 7)
        viewStatus.backgroundColor = .clear
        viewBG.containerColor = .white
        viewStatus.insertSubview(viewBG, at: 0)
        viewBG >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        let viewBG2 = BottomCornerView(with: 7)
        viewTotalPrice.backgroundColor = .clear
        viewBG2.containerColor = .white
        viewTotalPrice.insertSubview(viewBG2, at: 0)
        viewBG2 >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
    }
    func bindData(item: OrderContract) {
        if let timeStart = item.createdAt, let code = item.order_code {
            let dTime = Double(timeStart / 1000)
            let dateStart = Date(timeIntervalSince1970: dTime)
            let dateStartStr = dateStart.string(from: "HH:mm dd/MM/yyyy")
            lbTripID.text = "\(dateStartStr) • \(code)"
        }
        
        lbStatus.text = item.order_status?.statusText
         lbStatus.textColor = item.order_status?.statusColor
         lbStatus.backgroundColor = item.order_status?.statusColor.withAlphaComponent(0.15)
        
//        switch self.type {
//        case .history, .listRequest:
//            lbStatus.text = item.order_status?.statusText
//            lbStatus.textColor = item.order_status?.statusColor
//            lbStatus.backgroundColor = item.order_status?.statusColor.withAlphaComponent(0.15)
//        default:
//            lbStatus.text = ""
//        }
        
        lblbDestinationHistory.text = item.dropoff?.name
        lbSubDestinationHistory.text = item.dropoff?.address
        lbPickUp.text = item.pickup?.name
        lbSubPickUp.text = item.pickup?.address
        lbDestination.text = item.dropoff?.name
        lbSubDestination.text = item.dropoff?.address
        if let strTimeStart = item.pickup_time {
            let dTime = Double(strTimeStart / 1000)
            let dateStart = Date(timeIntervalSince1970: dTime)
            let dateStartStr = dateStart.string(from: "dd/MM/yyyy")
            lbDateStart.text = dateStartStr
            let hoursStart = dateStart.string(from: "HH:mm")
            lbTimeStart.text = hoursStart
        }
        
        if let strTimeEnd = item.dropoff_time {
            let dTime = Double(strTimeEnd / 1000)
            let dateStart = Date(timeIntervalSince1970: dTime)
            let dateStartStr = dateStart.string(from: "dd/MM/yyyy")
            lbDateEnd.text = dateStartStr
            let hoursStart = dateStart.string(from: "HH:mm")
            lbTimeEnd.text = hoursStart
            lbDateDropOff.text = "Ngày về"
        } else {
            lbTimeEnd.text = ""
            lbDateEnd.text = ""
            lbDateDropOff.text = ""
        }
        
        if let count = item.num_of_people {
            lbGuest.text = String(count)
        }
        if let options = ConfigRentalCarManager.shared.defaultOption {
            lbStandard.text = options.vehicle_ranks?.first(where: {$0.key == item.vehicle_rank})?.value
            lbService.text = options.vehicle_seats?.first(where: {$0.key == item.vehicle_seat})?.value
        }
        
        if let note = item.note {
            self.lbNote.text = note
        } else {
            self.vNote.isHidden = true
        }
        let total = item.cost?.total ?? 0
        let deposit = item.cost?.deposit ?? 0
        lbTotalPrice.text = total.currency
        
        lbPricePaid.text = deposit.currency
        let resPrice = max(total - deposit, 0)
        lbRestPrice.text = resPrice.currency
        
        if self.type == .DRIVER_FINISHED {
            lbPriceTotal.text = resPrice.currency
        } else {
            lbPriceTotal.text = total.currency
        }
        
        
        lbDepositHistory.text = deposit.currency
        lbPaidHistory.text = resPrice.currency
        
        
        if let otherPhone = item.other_phone, let name = item.other_name, let email = item.other_email {
            lbNumberPhoneClient.text = otherPhone
            lbEmailClient.text = email
            lbNameClient.text = name
            lbFullNameClient.text = name
        } else {
            lbNumberPhoneClient.text = item.user?.phone
            lbEmailClient.text = item.user?.email
            lbNameClient.text = item.user?.name
            lbFullNameClient.text = item.user?.name
        }
        
        if let current = item.user?.avatar_url {
            imgAvatarClient.contentMode = .scaleAspectFill
            imgAvatarClient.setImage(from: current, placeholder: UIImage(named: "avatar-holder"), size: CGSize(width: Config.wAvatar , height: Config.wAvatar))
        }
        self.layoutIfNeeded()
        
    }
    func updateUI(type: ContractCarOrderType) {
        self.type = type
        let views = [viewRestPrice, viewBill, viewInforUser, viewAvatar, viewLocation, viewButton, viewLocation, lbStatus, viewLocation, vHistoryDeposit, vHistoryPaid, vLineDeposit]
        
        switch type {
        case .seeMore:
            let viewsSeeMore = [viewBill, viewInforUser, viewAvatar, viewLocation, viewRestPrice, stackViewButton]
            viewsSeeMore.forEach { (v) in
                v?.isHidden = true
            }
            viewLineTime.isHidden = true
            hViewButton.constant = 50
        case .explain:
            let viewsSeeMore = [viewBill, viewInforUser, viewAvatar, viewLocation, viewRestPrice, stackViewButton]
            viewsSeeMore.forEach { (v) in
                v?.isHidden = false
            }
            viewLineTime.isHidden = false
        case .history:
            views.forEach { (v) in
                v?.isHidden = true
            }
            let viewsHistory = [vHistoryDeposit, vHistoryPaid, vLineDeposit, viewLocation, lbStatus, viewLineTime]
            viewsHistory.forEach { (v) in
                v?.isHidden = false
            }
            vLineDeposit.isHidden = true
            viewDestination.isHidden = true
            lbRestText.text = "Tổng tiền"
        case .listRequest:
            views.forEach { (v) in
                v?.isHidden = true
            }
            
            let viewsListRequest = [lbStatus, viewLocation, viewLineTime]
            viewsListRequest.forEach { (v) in
                v?.isHidden = false
            }
            
            viewLineLocation.isHidden = true
            viewDestination.isHidden = true
            lbRestText.text = "Tổng tiền"
        case .CREATED, .DRIVER_STARTED:
            views.forEach { (v) in
                v?.isHidden = false
            }
            let vDeposit = [vHistoryDeposit, vHistoryPaid, vLineDeposit, viewInforUser, viewTotalPrice, viewDestination]
            vDeposit.forEach { (v) in
                v?.isHidden = true
            }
            viewLineTime.isHidden = false
            lbRestText.text = "Số còn lại"
            self.updateUIButton()
        case .DRIVER_ACCEPTED:
            views.forEach { (v) in
                v?.isHidden = false
            }
            let vDeposit = [vHistoryDeposit, vHistoryPaid, vLineDeposit, viewInforUser, viewAvatar, viewTotalPrice, viewDestination]
            vDeposit.forEach { (v) in
                v?.isHidden = true
            }
            viewLineTime.isHidden = false
            viewInforUser.isHidden = false
            self.updateUIButton()
        case .DRIVER_FINISHED:
            views.forEach { (v) in
                v?.isHidden = false
            }
            let vDeposit = [vHistoryDeposit, vHistoryPaid, vLineDeposit, viewDestination, viewButton, viewInforUser, viewAvatar, vLineBill]
            vDeposit.forEach { (v) in
                v?.isHidden = true
            }
            
            viewLineTime.isHidden = false
            viewRestPrice.isHidden = true
            
            let viewBG2 = BottomCornerView(with: 7)
            viewAvatar.backgroundColor = .clear
            viewBG2.containerColor = .white
            viewAvatar.insertSubview(viewBG2, at: 0)
            viewBG2 >>> {
                $0.snp.makeConstraints({ (make) in
                    make.edges.equalToSuperview()
                })
            }

        }
    }
    private func updateUIButton() {
        let viewBG2 = BottomCornerView(with: 7)
        viewButton.backgroundColor = .clear
        viewBG2.containerColor = .white
        viewButton.insertSubview(viewBG2, at: 0)
        viewBG2 >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        self.btChat.setTitle("  Chat với Khách", for: .normal)
        self.btChat.setTitleColor(#colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1), for: .normal)
        self.btChat.backgroundColor = .white
        self.btChat.setImage(UIImage(named: "ic_chat_client"), for: .normal)
        self.btCancel.setTitle("  Gọi khách", for: .normal)
        self.btCancel.setTitleColor(#colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1), for: .normal)
        self.btCancel.backgroundColor = .white
        self.btCancel.setImage(UIImage(named: "ic_call_client"), for: .normal)
    }
}
