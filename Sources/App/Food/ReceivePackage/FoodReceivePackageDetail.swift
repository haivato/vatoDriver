//  File name   : FoodReceivePackageDetail.swift
//
//  Author      : vato.
//  Created date: 2/17/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import SnapKit
import Eureka
import RxSwift

enum FoodReceivePackageCellType: String, CaseIterable {
    case image = "Image"
    case note = "note"
}

protocol FoodReceivePackageDetailListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var imagesObser: Observable<[UIImage]> { get }
}

final class FoodReceivePackageDetail: FormViewController
{
    var listener: FoodReceivePackagePresentableListener? {
        didSet {
            setupRX()
        }
    }
    
    private struct Config {
    }
    
    /// Class's public properties.
//    weak var listener: FoodReceivePackagePresentableListener?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
    private let headerView: FoodHeaderViewDetail = FoodHeaderViewDetail.loadXib()
    private let imageView: FoodViewImage = FoodViewImage.loadXib()
    private lazy var disposeBag = DisposeBag()
}

// MARK: View's event handlers
extension FoodReceivePackageDetail {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension FoodReceivePackageDetail {
}

// MARK: Class's private methods
private extension FoodReceivePackageDetail {
    private func localize() {
        // todo: Localize view's here.
    }

    private func visualize() {
        tableView.separatorStyle = .none
        tableView.separatorColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 0.7)
        tableView.backgroundColor = .white
        
        self.imageView.clipsToBounds = true
    }
    
    func loadData(booking: FCBookInfo?) {
        guard let booking = booking else { return }
        UIView.performWithoutAnimation {
            self.form.removeAll()
        }
        let section = Section() { (s) in
            s.tag = "InfoPackage"
            // header
            var header = HeaderFooterView<UIView>(.callback {
                let v: UIView = UIView()
                
                v.addSubview(self.imageView)
                self.imageView.snp.makeConstraints { (make) in
                    make.left.top.right.equalToSuperview()
                    make.height.equalTo(130)
                }
                self.imageView.update(title: Text.imageFoodBill.localizedText)
                self.imageView.reloadData(_images: [])
                self.imageView.didSelectAdd = { [weak self] in
                    #if targetEnvironment(simulator)
                        self?.listener?.didSelectAction(action: .openPhoto)
                    #else
                        self?.listener?.didSelectAction(action: .openCamera)
                    #endif
                }
                self.imageView.didSelectClear = { [weak self] indexPath in self?.listener?.removePhoto(index: indexPath.row) }
                
                v.addSubview(self.headerView)
                self.headerView.snp.makeConstraints { (make) in
                    make.left.bottom.right.equalToSuperview()
                    make.top.equalTo(self.imageView.snp.bottom)
                }
                
                self.headerView.lbCode.text = "Mã đơn: \(booking.tripCode ?? "")"
                let str = booking.embeddedPayload
                let model = FoodOderModel.decodeFromString(string: str)
                self.headerView.lbTotal.text = model?.merchantFinalPrice?.currency
                self.headerView.lbPromotion.text = (0 - (model?.discountPromtion ?? 0)).currency
                if Int(model?.discountShippingFee ?? 0) > 0 {
                    self.headerView.lbTextPromotionShip.text = "\(Text.promotionShip.localizedText)"
                    self.headerView.lbPromotionShip.text = (0 - (model?.discountShippingFee ?? 0)).currency
                }
                self.headerView.qrCodeImage.image = Utils.generateQRCode(from: booking.tripId)
                return v
                })
            switch booking.payment {
            case PaymentMethodCash:
                self.headerView.hviewNotMoney.constant = 0
                if self.listener?.type == .actionReceivePackage {
                    header.height = { 260 }
                } else {
                    self.imageView.snp.updateConstraints { (make) in
                        make.height.equalTo(0)
                    }
                    header.height = { 130 }
                }
                self.headerView.lbTotal.textColor = #colorLiteral(red: 0.9176470588, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
            default:
                if self.listener?.type == .actionReceivePackage {
                    header.height = { 344 }
                    
                } else {
                    self.imageView.snp.updateConstraints { (make) in
                        make.height.equalTo(0)
                    }
                    header.height = { 214 }
                }
                self.headerView.lbPaid.text = " Đã thanh toán  "
                self.headerView.vLineTotal.isHidden = false
            }
            
            s.header = header
        }
        section <<< FoodListItemCellEureka() { cell in
            cell.cell.display(booking: booking)
            
        }
        
        if booking.note != "" {
            section <<< FoodNoteCellEureka() { (row) in
                row.cell.display(text: booking.note)
            }
        }
        
        
        UIView.performWithoutAnimation {
            self.form += [section]
        }
    }
    
    func showActionSheetPhoto() {
        let optionMenuController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let addAction = UIAlertAction(title: "Mở Camera", style: .default, handler:{ [weak self] (_) in
            self?.listener?.didSelectAction(action: .openCamera)
        })
        let saveAction = UIAlertAction(title: "Chọn Hình từ Photo", style: .default, handler:{ [weak self] (_) in
            self?.listener?.didSelectAction(action: .openPhoto)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenuController.addAction(addAction)
        optionMenuController.addAction(saveAction)
        optionMenuController.addAction(cancelAction)
        
        self.present(optionMenuController, animated: true, completion: nil)
    }
    
    func setupRX() {
        listener?.bookInfo.bind(onNext: { [weak self] (booking) in
            self?.loadData(booking: booking)
        }).disposed(by: disposeBag)
        
        listener?.imagesObser.bind(onNext: { [weak self] (images) in
            self?.imageView.reloadData(_images: images)
        }).disposed(by: disposeBag)
    }

}

