//  File name   : LocationPickerVC.swift
//
//  Author      : khoi tran
//  Created date: 11/13/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import FwiCore
import FwiCoreRX
import RxCocoa
import VatoNetwork

protocol LocationPickerPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func moveBack()
    func moveToPin()
    func searchLocation(keyword: String)
    func getListFavorite()
    func didSelectModel(indexPath: IndexPath)
    func didSelectFavoriteModel(model: PlaceModel)
    func didSelectAddFavorite(item: AddressProtocol)
    var listDataObservable: Observable<[AddressProtocol]>  { get }
    var listFavoriteObservable: Observable<[PlaceModel]>  { get }
    var placeModelObservable: Observable<AddressProtocol>  { get }
    var searchType: SearchType { get }
    var eLoadingObser: Observable<(Bool,Double)> { get }
    var typeLocationPicker: LocationPickerDisplayType {get}
}

final class LocationPickerVC: UIViewController, LocationPickerPresentable, LocationPickerViewControllable, DisposableProtocol {
    private struct Config {
        static let fontCellFavoritePlace = UIFont.systemFont(ofSize: 13.0, weight: .regular)
        static let heightCellFavoritePlace: CGFloat = 40.0
        static let heightFavoriteLocationView: CGFloat = 0
    }
    
    /// Class's public properties.
    weak var listener: LocationPickerPresentableListener?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        self.listener?.getListFavorite()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        self.navigationController?.setNavigationBarHidden(true, animated: true)

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchTextField?.resignFirstResponder()
//        self.navigationController?.setNavigationBarHidden(false, animated: true)

    }

    /// Class's private properties.
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var locationTypeImageView: UIImageView!
    @IBOutlet weak var locationTableView: UITableView!
    @IBOutlet weak var favouriteLocationView: UIView!
    @IBOutlet weak var heightFavoriteLocationViewContraint: NSLayoutConstraint!
    @IBOutlet weak var favouriteLocationCollectionView: UICollectionView!
    @IBOutlet weak var mapLabel: UILabel!
    @IBOutlet weak var headerView: UIView!

    
    
    @IBOutlet weak var headerViewTopConstraint: NSLayoutConstraint!
    
    lazy var disposeBag = DisposeBag()
    var listFavoriteSource = [PlaceModel]()

    
}

// MARK: View's event handlers
extension LocationPickerVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func showError(msg: String) {
        AlertVC.showError(for: self, message: msg)
    }
}

// MARK: Class's public methods
extension LocationPickerVC {
}

// MARK: Class's private methods
private extension LocationPickerVC {
    private func localize() {
        // todo: Localize view's here.
        mapLabel.text = Text.map.localizedText
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        self.setupNavigationBar()
        
        var edgeSafe = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11, *) {
            edgeSafe = UIApplication.shared.keyWindow?.edgeSafe ?? UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        } else {
            headerViewTopConstraint.constant = edgeSafe.top
        }
        
        self.searchTextField.placeholder = Text.enterTheSearchAddress.localizedText
        self.searchTextField.becomeFirstResponder()
        self.searchTextField.clearButtonMode = .whileEditing
        self.locationTableView.register(SearchLocationNewCell.nib, forCellReuseIdentifier: SearchLocationNewCell.identifier)
        self.locationTableView.backgroundColor = .white
        self.locationTableView.tableFooterView = UIView()
        self.locationTableView.estimatedRowHeight = 62
        self.locationTableView.rowHeight = UITableView.automaticDimension
        
        favouriteLocationCollectionView.register(HomeSuggestionCVC.self, forCellWithReuseIdentifier: HomeSuggestionCVC.identifier)
        self.favouriteLocationCollectionView.delegate = self
        
        guard let type = listener?.searchType else {
            return
        }
        
        switch type {
        case .express(let origin):
            self.searchTextField.placeholder = type.string()
            self.locationTypeImageView.image = origin ? UIImage(named: "ic_origin") : UIImage(named: "ic_destination_new")
            
        case .booking(_, let placeHolder, let icon):
           self.searchTextField.placeholder = placeHolder
           self.locationTypeImageView.image = icon
        default:
            break
        }
        if let typeLocationPicker = self.listener?.typeLocationPicker {
            switch typeLocationPicker {
            case .full:
                self.heightFavoriteLocationViewContraint.constant = Config.heightFavoriteLocationView
            case .updatePlaceMode:
                self.heightFavoriteLocationViewContraint.constant = 0
            }
        }
    }
    
    func setupRX() {
        listener?.eLoadingObser.bind(onNext: { (item) in
            item.0 ? LoadingManager.instance.show() : LoadingManager.instance.dismiss()
        }).disposed(by: disposeBag)
        
        self.backButton.rx.tap.bind { [weak self] in
            guard let me = self else { return }
            me.listener?.moveBack()
        }.disposed(by: disposeBag)
        
        self.mapButton.rx.tap.bind { [weak self] in
            guard let me = self else { return }
            me.listener?.moveToPin()
        }.disposed(by: disposeBag)
        
        self.searchTextField.rx.text
            .debounce(RxTimeInterval.milliseconds(30), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (keyWord) in
                self?.listener?.searchLocation(keyword: keyWord ?? "")
            })
            .disposed(by: disposeBag)
        
        self.listener?.listDataObservable.bind(to: locationTableView.rx.items(cellIdentifier: SearchLocationNewCell.identifier, cellType: SearchLocationNewCell.self)) {[weak self] (row, element, cell) in
            if row == 0 {
                cell.backgroundColor = UIColor(red: 0, green: 97/255, blue: 61/255, alpha: 0.1)
            } else {
                cell.backgroundColor = .white
            }
            cell.updateData(model: element, typeLocationPicker: self?.listener?.typeLocationPicker ?? .full)
            guard let wSelf = self else { return }
            cell.addButton.rx.tap
                .takeUntil(cell.rx.methodInvoked(#selector(UITableViewCell.prepareForReuse)))
                .subscribe(onNext: { _ in
                    guard let wSelf = self else { return }
                    wSelf.listener?.didSelectAddFavorite(item: element)
                }).disposed(by: wSelf.disposeBag)
        
        }.disposed(by: disposeBag)
        
        self.locationTableView.rx.itemSelected.bind {[weak self](indexPath) in
            self?.listener?.didSelectModel(indexPath: indexPath)
            }.disposed(by: disposeBag)
        
        self.listener?.listFavoriteObservable.bind(to: self.favouriteLocationCollectionView.rx.items) { (collectionView, row, element) in
            let indexPath = IndexPath(row: row, section: 0)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeSuggestionCVC.identifier, for: indexPath) as! HomeSuggestionCVC
            cell.configure(with: element, fontTitle: Config.fontCellFavoritePlace)
            return cell
            }.disposed(by: disposeBag)
        
        self.listener?.listFavoriteObservable.subscribe(onNext: {[weak self] (listData) in
            self?.listFavoriteSource = listData
        }).disposed(by: disposeBag)
        
        let showEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).map { KeyboardInfo($0) }
        let hideEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).map { KeyboardInfo($0) }
        
        Observable.merge([showEvent, hideEvent]).filterNil().bind { [weak self] in
            let h = $0.height
            UIView.animate(withDuration: $0.duration) {
                self?.favouriteLocationView.snp.updateConstraints({ (make) in
                    make.bottom.equalTo(-h)
                })
            }
            }.disposed(by: disposeBag)
        
        self.listener?.placeModelObservable.observeOn(MainScheduler.asyncInstance).bind(onNext: { [weak self] (model) in
            guard let me = self else { return }
            
            guard let type = me.listener?.searchType else { return }
            switch type {
            case .express(let o) where !o:
                break
            case .none:
                break
            default:
                me.searchTextField.text = model.name
                me.searchTextField.sendActions(for: .valueChanged)
            }
            
        }).disposed(by: disposeBag)
    }
    
    private func setupNavigationBar() {
        if #available(iOS 13.0, *) {
            UIApplication.setStatusBar(using: .darkContent)
        } else {
            UIApplication.setStatusBar(using: .default)
        }
        view.backgroundColor = .white
    }
}


extension LocationPickerVC: UICollectionViewDelegateFlowLayout {
    // MARK: UICollectionViewDelegateFlowLayout's members
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var _item: PlaceModel?
        if indexPath.row < self.listFavoriteSource.count {
            _item = self.listFavoriteSource[indexPath.row]
        }
        guard let item = _item else  { return CGSize.zero }
        
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Config.fontCellFavoritePlace
        ]
        let string = NSAttributedString(string: item.name ?? "", attributes: attributes)
        
        // Calculate dynamic width
        var expectedSize = string.size()
        expectedSize.width = ceil(expectedSize.width + 64.0)
        
        let width35 = UIScreen.main.bounds.size.width * 3 / 5
        let width = expectedSize.width >= width35 ? width35 : expectedSize.width
        
        return CGSize(width: width , height: Config.heightCellFavoritePlace)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if indexPath.row < self.listFavoriteSource.count {
            let model = self.listFavoriteSource[indexPath.row]
            self.listener?.didSelectFavoriteModel(model: model)
        }
    }
}

