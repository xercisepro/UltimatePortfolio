//
//  SKProduct-LocalizedPrice.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 28/2/22.
//

import StoreKit

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
