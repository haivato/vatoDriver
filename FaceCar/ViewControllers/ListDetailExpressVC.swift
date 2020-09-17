//
//  ListDetailExpressVC.swift
//  FC
//
//  Created by MacbookPro on 11/5/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

class ListDetailExpressVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ListDetailExpressCell", bundle: nil), forCellReuseIdentifier: "cell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListDetailExpressCell
        cell.lbCount.text = String(indexPath.row + 1)
        cell.vLineAbove.isHidden = indexPath.row == 0
        switch indexPath.row {
        case 1:
            cell.icExpress.image = UIImage(named: "ic_cancel")
            cell.viewStatusTrip.backgroundColor = #colorLiteral(red: 0.9843137255, green: 0.8784313725, blue: 0.9568627451, alpha: 1)
            cell.icTripStatus.image = UIImage(named: "ic_trip_invalid")
            cell.lbTripStatus.text = "Thất bại"
            cell.lbTripStatus.textColor = #colorLiteral(red: 0.8823529412, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
            cell.lbNameClient.text = "Nguyên Trần Phan Kiếm Tiền...."
        case 2:
            cell.icExpress.image = UIImage(named: "")
            cell.icExpress.backgroundColor = #colorLiteral(red: 0.7529411765, green: 0.7764705882, blue: 0.8, alpha: 1)
            cell.viewStatusTrip.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.icTripStatus.image = UIImage(named: "ic_trip_pending")
            cell.lbTripStatus.text = "Chưa giao"
            cell.lbTripStatus.textColor = #colorLiteral(red: 0.9607843137, green: 0.6509803922, blue: 0.1764705882, alpha: 1)
        default:
            break
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 16))
        viewHeader.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        return viewHeader
    }
}
