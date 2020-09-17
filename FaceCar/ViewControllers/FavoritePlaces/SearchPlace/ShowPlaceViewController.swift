//
//  ShowPlaceViewController.swift
//  Vato
//
//  Created by vato. on 7/18/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import VatoNetwork
import SVProgressHUD

class ShowPlaceViewController: UIViewController {
    var didSelect: ((MapModel.Place) -> Void)?
    var didSelectDetail: ((MapModel.PlaceDetail) -> Void)?
    
    
    // MARK: - property
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var disposeBag = DisposeBag()
    
    
    var viewModel: ShowPlaceVM!
    
    private var listData = [MapModel.Place]()
    private let listDataSubject = ReplaySubject<[MapModel.Place]>.create(bufferSize: 1)
    
    convenience init(viewModel: ShowPlaceVM) {
        self.init()
        self.viewModel = viewModel
    }
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setRX()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Private method
    
    func setupView() {
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 50
        self.tableView.estimatedSectionHeaderHeight = 50
        self.tableView.separatorStyle = .none
        let backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        self.view.backgroundColor = UIColor.clear
        self.tableView.backgroundColor = backgroundColor
        self.tableView.tableFooterView = UIView()
        self.tableView.keyboardDismissMode = .onDrag
        
        self.tableView.register(UINib(nibName: "PlaceTableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "PlaceTableHeaderView")
    }
    
    private var disposeSearch: Disposable?
    func setRX(){

        self.listDataSubject
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] (values) in
            if values.count > 0 {
                self?.view.isHidden = false
            } else {
                self?.view.isHidden = true
            }
        }).disposed(by: disposeBag)
        
        self.listDataSubject
            .bind(to: tableView.rx.items) { (tableView, row, element) in
                let identifier = "FavoritePlaceTableViewCell"
                var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? FavoritePlaceTableViewCell
                if cell == nil {
                    cell = FavoritePlaceTableViewCell.newCell(reuseIdentifier: identifier)
                }
                cell?.displayDataMapPlaceModel(model: element)
                return cell!
                
            }.disposed(by: disposeBag)
        
        self.listDataSubject.subscribe(onNext: { [weak self] values in
            self?.listData = values
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }).disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected.bind { [weak self] indexPath in
            guard let self = self else { return }
            let model = self.listData[indexPath.row]
            LoadingManager.instance.show()
            self.viewModel.getDetailLocation(place: model, completion: {[weak self] (newModel) in
                guard let self = self else { return }
                self.didSelect?(newModel)
                LoadingManager.instance.dismiss()
            })
            }.disposed(by: disposeBag)
    }
    
    func searchWithKeywork(keyword: String?)  {
        if let keyword = keyword {
            self.disposeSearch?.dispose()
            let observable = self.viewModel.findSuggestionGoogle(by: keyword)
            self.disposeSearch = observable.subscribe(onNext: { [weak self] values in
                self?.listDataSubject.onNext(values)
            })
        }
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
}
