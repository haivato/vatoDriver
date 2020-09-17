//
//  TODriverInfoView.swift
//  Vato
//
//  Created by khoi tran on 2/18/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import Kingfisher

protocol TODriverInfoDisplay: ImageDisplayProtocol {
    var fullname: String? { get }
    var serviceId: Int? { get }
    var vehiclePlate: String? { get }
    var carType: String? { get }
    var phone: String? { get }
    var status: TODriverStatus? { get }
    var coordinate: CLLocationCoordinate2D { get }
    var avatar: String? { get }
}

class TODriverInfoView: UIView, UpdateDisplayProtocol {
    @IBOutlet weak var lblDriverName: UILabel?
    @IBOutlet weak var lblBlateNumber: UILabel?
    @IBOutlet weak var imvAvatar: UIImageView?
    @IBOutlet weak var stvCarInfo: UIStackView?
    @IBOutlet weak var carTypeLabel: UILabel!

    func setupDisplay(item: TODriverInfoDisplay?) {
        guard let item = item else { return }
        lblDriverName?.text = item.fullname
        lblBlateNumber?.text = item.vehiclePlate
        self.carTypeLabel.text = item.carType
        imvAvatar?.image = UIImage(named: "avatar-placeholder")
        if let avatarUrl = item.avatar,
            let url = URL(string: avatarUrl) {
            imvAvatar?.kf.setImage(with: url)
        }
        
    }
}
