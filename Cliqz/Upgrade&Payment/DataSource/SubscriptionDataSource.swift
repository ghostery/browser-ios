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

class SubscriptionDataSoruce {
    weak var delegate: SubscriptionDataSourceDelegate!
    
    var subscriptionInfos = [SubscriptionCellInfo]()
    
    init(delegate: SubscriptionDataSourceDelegate) {
        self.delegate = delegate
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
}
