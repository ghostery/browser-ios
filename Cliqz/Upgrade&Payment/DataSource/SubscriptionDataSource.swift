//
//  SubscriptionDataSource.swift
//  Client
//
//  Created by Pavel Kirakosyan on 27.05.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation
import StoreKit

protocol SubscriptionDataSourceDelegate: class {
    func retrieveStandartProducts(completion:@escaping ([LumenSubscriptionProduct]) -> Void)
    func retrievePromoProducts(completion:@escaping ([LumenSubscriptionProduct]) -> Void)
}

let kSubscriptionCellHeight: CGFloat = 150.0

class SubscriptionDataSource {
    
    weak var delegate: SubscriptionDataSourceDelegate!
    
    var subscriptionInfos = [SubscriptionCellInfo]()
    
    init(delegate: SubscriptionDataSourceDelegate) {
        self.delegate = delegate
    }
    
    func fetchProducts(completion: ((Bool) -> Void)? = nil) {
        assert(false, "Derived classes must override this method")
        completion?(false)
    }
    
    func subscriptionsCount() -> Int {
        return self.subscriptionInfos.count
    }
    
    func subscriptionHeight(indexPath: IndexPath) -> CGFloat {
        let subscription = self.subscriptionInfos[indexPath.row]
        return subscription.height
    }
    
    func subscriptionInfo(indexPath: IndexPath) -> SubscriptionCellInfo? {
        return self.subscriptionInfos[indexPath.row]
    }
    
    func telemeterySignals(product: LumenSubscriptionProduct? = nil) -> [String:String] {
        assert(false, "Derived classes must override this method")
        return [:]
    }
    
    func getConditionText() -> String {
        assert(false, "Derived classes must override this method")
        return ""
    }
    
    func getHeaderText() -> String? {
        return nil
    }
}
