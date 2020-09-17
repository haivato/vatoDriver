//  File name   : RegisterServiceVC.swift
//
//  Author      : MacbookPro
//  Created date: 4/27/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxCocoa
import RxSwift

protocol RegisterServicePresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func moveBack()
    func selectCar(itemCar: CarInfo)
    var listCarObs: Observable<[CarInfo]> { get }
}

final class RegisterServiceVC: UIViewController, RegisterServicePresentable, RegisterServiceViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: RegisterServicePresentableListener?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    private let disposeBag = DisposeBag()
    @IBOutlet weak var tableView: UITableView!
    private var listCar: [CarInfo] = []
    private let maxCellDisPlay = 5
    @IBOutlet weak var heightTableView: NSLayoutConstraint!
    /// Class's private properties.
}

// MARK: View's event handlers
extension RegisterServiceVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension RegisterServiceVC {
}

// MARK: Class's private methods
private extension RegisterServiceVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RegisterServiceCell.nib, forCellReuseIdentifier: RegisterServiceCell.identifier)
        if #available(iOS 11.0, *) {
            tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 10
        
        UIView.animate(withDuration: 0, animations: {
            self.tableView.layoutIfNeeded()
        }) { (complete) in
            var heightOfTableView: CGFloat = 0.0
            let cells = self.tableView.visibleCells
            let count = min(cells.count, self.maxCellDisPlay)
            for (index, element) in cells.enumerated() {
                if index < count {
                    heightOfTableView += element.frame.height
                }
            }
            self.heightTableView.constant = heightOfTableView + 61
            self.view.isHidden = false
            self.view.layoutIfNeeded()
        }
    }
    private func setupRX() {
        self.listener?.listCarObs.bind(onNext: weakify { (listCar, wSelf) in
            wSelf.listCar = listCar
            if listCar.count <= wSelf.maxCellDisPlay {
                wSelf.tableView.isScrollEnabled = false
            } else {
                wSelf.tableView.isScrollEnabled = true
            }
            wSelf.tableView.reloadData()
        }).disposed(by: disposeBag)
    }
}
extension RegisterServiceVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 61
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v: UIView = UIView()
        
        let btBack: UIButton = UIButton(type: .custom)
        btBack.setImage(UIImage(named: "ic_close_header_black"), for: .normal)
        
        v.addSubview(btBack)
        btBack.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(56)
        }
        
        let lbTitle: UILabel = UILabel(frame: .zero)
        lbTitle.text = Text.selectCarInGara.localizedText
        lbTitle.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        lbTitle.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        v.addSubview(lbTitle)
        lbTitle.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        btBack.rx.tap.bind { _ in
            self.listener?.moveBack()
        }.disposed(by: disposeBag)
        
        return v
    }
}
extension RegisterServiceVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listCar.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RegisterServiceCell.identifier) as! RegisterServiceCell
        cell.updateUI(model: self.listCar[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.listener?.selectCar(itemCar: self.listCar[indexPath.row] )
    }
}
 
