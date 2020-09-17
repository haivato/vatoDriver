//
//  TODriverNearbyTVC.swift
//  Vato
//
//  Created by khoi tran on 2/18/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import FwiCoreRX
import FwiCore
import RxSwift


protocol TODriverNearByDisplay {
    var driverInfo: TODriverInfoDisplay? { get }
    var isInGroup: Bool? { get }
    var isInvited: Bool? { get }
}

class TODriverNearbyTVC: UITableViewCell, UpdateDisplayProtocol {

    @IBOutlet weak var lblIndex: UILabel!
    
    private lazy var driverInfoView: TODriverInfoView = TODriverInfoView.loadXib()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        visualize()
        setupRX()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func visualize() {
        driverInfoView >>> contentView >>> {
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(16)
                make.right.equalToSuperview()
                make.left.equalTo(40)
                make.bottom.equalTo(-16)
            }
        }
        contentView.addSeperator(with: .init(top: 0, left: 100, bottom: 0, right: 0), position: .bottom)        
    }
    
    func setupRX() {
        
    }
    
    func updateIndex(index: Int) {
        self.lblIndex.text = "\(index)."
    }
    
    
    func setupDisplay(item: TODriverInfoModel?) {
        guard let item = item else { return }
        driverInfoView.setupDisplay(item: item)
//        imvTeam.isHidden = !( item.isInGroup ?? false )
    }
}
