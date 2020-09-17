//  File name   : BuyPointBuilder.swift
//
//  Author      : admin
//  Created date: 5/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol BuyPointDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    
//    var mutablePaymentStream: MutablePaymentStream { get }
}

final class BuyPointComponent: Component<BuyPointDependency> {
    /// Class's public properties.
    let BuyPointVC: BuyPointVC
    
    /// Class's constructor.
    init(dependency: BuyPointDependency, BuyPointVC: BuyPointVC) {
        self.BuyPointVC = BuyPointVC
        super.init(dependency: dependency)
    }
    
    var mutableTopUpStream: MutableTopUpStream {
        return shared { TopUpStreamImpl() }
    }
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol BuyPointBuildable: Buildable {
    func build(withListener listener: BuyPointListener, allList: [Any], balance: DriverBalance?, indexSelect: IndexPath?) -> BuyPointRouting
}

final class BuyPointBuilder: Builder<BuyPointDependency>, BuyPointBuildable {
    
    /// Class's constructor.
    override init(dependency: BuyPointDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: BuyPointBuildable's members
    func build(withListener listener: BuyPointListener, allList: [Any], balance: DriverBalance?, indexSelect: IndexPath?) -> BuyPointRouting {
        guard let vc = UIStoryboard(name: "WalletPointVC", bundle: nil).instantiateViewController(withIdentifier: "buyPoint") as? BuyPointVC else { fatalError("Please Implement") }
        
        let component = BuyPointComponent(dependency: dependency, BuyPointVC: vc)
        
        let interactor = BuyPointInteractor(presenter: component.BuyPointVC, list: allList, balance: balance, indexSelect: indexSelect)
        
        interactor.listener = listener
        
        // todo: Create builder modules builders and inject into router here.
        let wtWithDrawCfBuilder = WTWithDrawConfirmBuilder(dependency: component)

        return BuyPointRouter(interactor: interactor,
                              viewController: component.BuyPointVC,
                              wtWithDrawConfirm: wtWithDrawCfBuilder)
    }
}
