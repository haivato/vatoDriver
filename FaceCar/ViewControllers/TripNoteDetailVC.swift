//  File name   : TripNoteDetailVC.swift
//
//  Author      : Dung Vu
//  Created date: 4/7/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import FwiCore
import RxSwift
import RxCocoa

@objcMembers
final class TripNoteDetailVC: UITableViewController {
    /// Class's public properties.
    var booking: FCBooking?
    @IBOutlet var lblPrice : UILabel?
    @IBOutlet var lblSupplyDescription : UILabel?
    @IBOutlet var lblNote: UILabel?
    private lazy var disposeBag = DisposeBag()
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.item {
        case 0:
            guard booking?.info?.supplyInfo != nil else {
                return 0
            }
            return UITableView.automaticDimension
        default:
            return UITableView.automaticDimension
        }
    }
    /// Class's private properties.
    
    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        return nil
    }

    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat { return 0.1 }

    override func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat { return 0.1 }

    override func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? { return nil }
}
// MARK: View's event handlers
extension TripNoteDetailVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's private methods
private extension TripNoteDetailVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        title = "Chi tiết đơn hàng"
        let buttonLeft = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        buttonLeft.setImage(UIImage(named: "ic_arrow_navi_left"), for: .normal)
        buttonLeft.contentEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: buttonLeft)
        navigationItem.leftBarButtonItem = leftBarButton
        buttonLeft.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        let supply = booking?.info?.supplyInfo
        lblPrice?.text = "Giá ước tính - \((supply?.estimatedPrice ?? 0).currency)"
        lblSupplyDescription?.text = supply?.productDescription
        
        lblNote?.text = booking?.info?.note
    }

}



