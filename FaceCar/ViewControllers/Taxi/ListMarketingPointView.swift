//
//  ListMarketingPointView.swift
//  FC
//
//  Created by vato. on 2/19/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

@objc
protocol ListMarketingPointViewProtocol: NSObjectProtocol {
    func showTOOrderDriver()
    func playSoundUpdateQueue()
    func notifyVibrateDevice()
}

/*
 TAXI_ENQUEUE_REQUEST xin vào đội
 TAXI_DEQUEUE_REQUEST xin ra khỏi đội
 TAX_QUEUE_CHANGED thay đổi thứ tự
 TAXI_ENQUEUE_INVITATION có lời mời
 */

struct MarketingPointAction {
    var type: MarketingPointButtonType
    var model: TaxiOperationDisplay?
}

extension MarketingPointAction: PickupLocationProtocol {
    var address: TOPickupLocation.Address? {
        return model?.address
    }
    
    var pickupId: Int? {
        return model?.id
    }
}

@objcMembers
final class ListMarketingPointView: UIView {
    private struct Config { }
    
    internal lazy var disposeBag: DisposeBag = DisposeBag()
    var collectionView: UICollectionView?
    let viewJoined = TaxiRequestSuccess.loadXib()
    weak var listener: ListMarketingPointViewProtocol?
    var parentController: UIViewController?
    var isOnline: Bool = false
    @objc var requestOnline: (() -> Void)?
    private var currentQueue: TaxiQUEUEType?
    
    @VariableReplay(wrappedValue: []) private var models: [TaxiOperationDisplay]
    @Published private var action: MarketingPointAction
    private var isLoading = false
    private var listStationRemoved: [Int] = []
    private var disposeVibrate: Disposable?
    
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let tagCellLayout = UICollectionViewFlowLayout()
        tagCellLayout.minimumLineSpacing = 12
        tagCellLayout.minimumInteritemSpacing = 0
        tagCellLayout.scrollDirection = .horizontal
        tagCellLayout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 0)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: tagCellLayout)
        
        collectionView?.register(MarketingPointCollectionViewCell.nib, forCellWithReuseIdentifier: "MarketingPointCollectionViewCell")
        collectionView?.register(RequestFailCollectionViewCell.nib, forCellWithReuseIdentifier: "RequestFailCollectionViewCell")
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        visualize()
        setupRX()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func visualize() {
        collectionView?.backgroundColor = .clear
        collectionView?.clipsToBounds = false
        collectionView?.showsHorizontalScrollIndicator = false
        self.backgroundColor = UIColor.clear
        
        guard let collectionView = collectionView  else { return }
        collectionView >>> self >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        viewJoined >>> self >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
    }
    
    func setupRX() {
        TOManageCommunication.shared.event.bind { [weak self] (datas) in
            // filer station user remove in local
            self?.models = datas.filter { (m) -> Bool in
                guard let stationId = m.id else { return true }
                let isExistInListRemove = self?.listStationRemoved.contains { $0 == stationId } ?? false
                return !isExistInListRemove
            }
        }.disposed(by: disposeBag)
        
        TOManageCommunication
            .shared
            .event
            .debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] (_) in
                mainAsync { (_) in
                    self?.collectionView?.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                    }(())
        }.disposed(by: disposeBag)
        
        TOManageCommunication.shared.registrations.bind { [weak self] (datas) in
            // process pending list => obserble time pending
            let pendings = datas.filter { $0.type == TaxiModelDisplayType.watingResponse }
            pendings.forEach { m in
                guard let id = m.id,
                    let stationId = m.stationId,
                    let expired_at = m.expired_at else { return }
                let request = TOPickupRequest(id: id, expired_at: expired_at, station_id: stationId)
                TOManageCommunication.shared.add(request: request)
            }
            
            self?.collectionView?.reloadData()
        }.disposed(by: disposeBag)
        
        // add timer pending for event reject
        TOManageCommunication.shared.listInvitation.bind { (datas) in
            // process expire invited list
            datas.forEach { m in
                guard let id = m.id,
                    let stationId = m.pickupStationId,
                    let expired_at = m.expired_at else { return }
                let request = TOPickupRequest(id: id, expired_at: expired_at, station_id: stationId)
                TOManageCommunication.shared.addExpireEvent(request: request)
            }
        }.disposed(by: disposeBag)
        
        $models.asObservable().bind { [weak self] (datas) in
            if let model = datas.first(where: { $0.type == TaxiModelDisplayType.approve }) {
                self?.viewJoined.display(item: model)
                self?.collectionView?.isHidden = true
                self?.viewJoined.isHidden = false
            } else {
                self?.collectionView?.isHidden = false
                self?.viewJoined.isHidden = true
                self?.collectionView?.reloadData()
            }
        }.disposed(by: disposeBag)
        
        $action.asObserver().bind { [weak self] (action) in
            switch action.type {
            case .listDriver:
                self?.listener?.showTOOrderDriver()
            case .pending:
                print("pending")
                break
            case .agree:
                guard let id = action.model?.id else { return }
                TOManageCommunication.shared.driverActionInvitation(invitationId: id, action: .approve)
                break
            case .reject:
                guard let id = action.model?.id else { return }
                TOManageCommunication.shared.driverActionInvitation(invitationId: id, action: .reject)
                break
            case .request:
                TOManageCommunication.shared.requestJoinGroup(pickup: action)
                break
            case .clear:
                let isExistInListRemove = self?.listStationRemoved.contains { $0 == action.model?.stationId } ?? false
                if !isExistInListRemove {
                    self?.listStationRemoved.addOptional(action.model?.stationId)
                }
                self?.models.removeAll(where: { $0.id == action.model?.id })
                self?.collectionView?.reloadData()
                print("clear")
                break
            }
        }.disposed(by: disposeBag)
        
        TOManageCommunication.shared.eLoadingObser.bind(onNext: { (value) in
            value.0 ? LoadingManager.instance.show() : LoadingManager.instance.dismiss()
        }).disposed(by: disposeBag)
        
        TOManageCommunication.shared.error.bind(onNext: { [weak self] (e) in
            guard let vc = self?.parentController else { return }
            AlertVC.showError(for: vc, error: e)
        }).disposed(by: disposeBag)
        
        TOManageCommunication.shared
            .changeQueue
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.asyncInstance)
            .bind(onNext: { [weak self] (queue) in
                self?.disposeVibrate?.dispose()
                if self?.currentQueue != nil,
                    queue == .ready,
                    self?.currentQueue != queue {
                    TOManageCommunication.shared.stop()
                    self?.listener?.playSoundUpdateQueue()
                } else {
                    self?.vibrateToDriverQueueChange()
                }
                self?.currentQueue = queue
            }).disposed(by: disposeBag)
    }
    
    private func vibrateToDriverQueueChange() {
        disposeVibrate = Observable<Int>.interval(.milliseconds(400), scheduler: MainScheduler.asyncInstance).startWith(-1).take(3).bind { [weak self](_) in
            self?.listener?.notifyVibrateDevice()
        }
    }
}

extension ListMarketingPointView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = models[safe: indexPath.row]
        
        if model?.type == .reject {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RequestFailCollectionViewCell", for: indexPath) as? RequestFailCollectionViewCell else {
                fatalError("Error")
            }
            cell.didSelectButton = { [weak self] (type, m) in
                self?.action = MarketingPointAction(type: type, model: m)
            }
            cell.setupDisplay(item: model)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MarketingPointCollectionViewCell", for: indexPath) as? MarketingPointCollectionViewCell else {
                fatalError("Error")
            }
            cell.didSelectButton = { [weak self] (type, m) in
                guard let wSelf = self else {
                    return
                }
                if wSelf.isOnline {
                    wSelf.action = MarketingPointAction(type: type, model: m)
                } else {
                    wSelf.requestOnline?()
                }
                
            }
            cell.setupDisplay(item: model)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.size.width - 80
        return CGSize(width:width, height: collectionView.frame.size.height)
    }
}


extension ListMarketingPointView {
}

