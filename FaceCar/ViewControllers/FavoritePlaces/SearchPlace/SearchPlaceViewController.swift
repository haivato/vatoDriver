//
//  SearchPlaceViewController.swift
//  Vato
//
//  Created by vato. on 7/18/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD
import VatoNetwork
import FwiCoreRX

class SearchPlaceViewController: UIViewController {
    var didSelect: ((MapModel.Place) -> Void)?
    var didSelectDetail: ((MapModel.PlaceDetail) -> Void)?
    
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var textField: UITextField!
    
    private var searchPlaceVC: ShowPlaceViewController!
    
    private lazy var disposeBag = DisposeBag()
    
    var viewModel: SearchPlaceVM!
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setRX()
        
        searchPlaceVC = ShowPlaceViewController(viewModel: self.viewModel.generateShowPlaceVM())
        self.addChild(searchPlaceVC)
        self.viewContent.addSubview(searchPlaceVC.view)
        searchPlaceVC.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        searchPlaceVC.didSelect = self.didSelect
        searchPlaceVC.view.isHidden = true
        
        self.textField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    
    convenience init(viewModel: SearchPlaceVM) {
        self.init()
        self.viewModel = viewModel
    }

    // MARK: - Private method
    private func setupNavigationBar() {
        self.title = Text.favoritePlace.localizedText
        
        // left button
        var imageLeftButton = UIImage(named: "back-white")
        imageLeftButton = imageLeftButton?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeftButton, style: UIBarButtonItem.Style.plain, target: self, action: nil)
        
        // right button
        var imageRightButton = UIImage(named: "iconHeaderMap")
        imageRightButton = imageRightButton?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: imageRightButton, style: UIBarButtonItem.Style.plain, target: self, action: nil)
    }
    
    func setRX(){
        self.navigationItem.leftBarButtonItem?.rx.tap
            .subscribe(){[weak self] event in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
            } .disposed(by: disposeBag)
        
        self.navigationItem.rightBarButtonItem?.rx.tap
            .subscribe(){[weak self] event in
                guard let self = self else { return }
                let vc = PinLocationViewController()
                vc.didSelect = {[weak self] model in
                    guard let self = self else { return }
                    self.didSelectDetail?(model)
                    self.popToViewUpdate()
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        self.textField.rx.text
            .filter { [weak self] _ in
                self?.textField.isFirstResponder == true
            }.debounce(RxTimeInterval.milliseconds(3), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] keyword in
                guard let self = self else { return }
                self.searchPlaceVC.searchWithKeywork(keyword: keyword)
            })
            .disposed(by: disposeBag)

        self.view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
    }
    
    func popToViewUpdate() {
        var previousVC: UIViewController? = self.navigationController?.viewControllers.first
        self.navigationController?.viewControllers.forEach({ (vc) in
            if vc == self,
                let previousVC = previousVC {
                
                self.navigationController?.popToViewController(previousVC, animated: true)
                return
            }
            previousVC = vc
        })
    }
    
    func getData() -> Observable<[PlaceModel]> {
        let router = SessionManager.shared.firebaseToken().map {
            VatoAPIRouter.getFavPlaceList(authToken: $0, isDriver: true)
        }
        LoadingManager.instance.show()
        return router.flatMap {
            Requester.responseDTO(decodeTo: OptionalMessageDTO<[PlaceModel]>.self, using: $0)
            }.observeOn(MainScheduler.instance)
            .map {[weak self] r in
                guard let self = self else { return [] }
                if let e = r.response.error {
                    throw e
                } else {
                    // tksu warning
                    // let list = r.response.data.orNil(default: [])
                    var list = [PlaceModel]()
                    if let data = r.response.data {
                        list = data
                        self.viewModel.listModelFavorite = list
                        LoadingManager.instance.dismiss()
                    }
                    return list
                }
            }.catchError { (e) in
                printDebug(e)
                LoadingManager.instance.dismiss()
                throw e
        }
    }

}

extension SearchPlaceViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.getNumberSection()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getNumberRow(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "FavoritePlaceTableViewCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? FavoritePlaceTableViewCell
        if cell == nil {
            cell = FavoritePlaceTableViewCell.newCell(reuseIdentifier: identifier)
        }
        if let model = self.viewModel.getModel(at: indexPath) {
            cell?.displayData(model: model)
        }
        return cell!
    }
    
}

extension SearchPlaceViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.viewModel.getNumberRow(section: section) > 0 {
            return 40
        }
         return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return " "
    }
    
    // MARK - tableview delegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.viewModel.getNumberRow(section: section) == 0 {
            return nil
        }
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PlaceTableHeaderView") as! PlaceTableHeaderView
        headerView.displayWithText(text: self.viewModel.getHeaderText(section: section))
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

}
