//  File name   : CCChatWithVatoVC.swift
//
//  Author      : Phan Hai
//  Created date: 31/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import RxCocoa

protocol CCChatWithVatoPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func moveBackOrderContract()
}

final class CCChatWithVatoVC: UIViewController, CCChatWithVatoPresentable, CCChatWithVatoViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: CCChatWithVatoPresentableListener?
    @IBOutlet weak var btSend: UIButton!
    @IBOutlet weak var tfTyping: UITextField!
    @IBOutlet weak var tableView: UITableView!
    private let viewCarContract: CarContractView = CarContractView.loadXib()
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        setupRX()
    }
    private let disposeBag = DisposeBag()

    /// Class's private properties.
}

// MARK: View's event handlers
extension CCChatWithVatoVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension CCChatWithVatoVC {
}

// MARK: Class's private methods
private extension CCChatWithVatoVC {
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
            self.listener?.moveBackOrderContract()
        }.disposed(by: disposeBag)
        title = "Chat với Vato"
        
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 1000
                tableView.delegate = self
                tableView.register(CCChatWithVatoCell.nib, forCellReuseIdentifier: CCChatWithVatoCell.identifier)
        self.viewCarContract.updateUI(type: .seeMore)
    }
    private func setupRX() {
    }
}
extension CCChatWithVatoVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v: UIView = UIView()
        v.addSubview(self.viewCarContract)
        self.viewCarContract.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview().inset(10)
            make.top.equalToSuperview()
        }
        return v
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

