//
//  Sequence-Sorting.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 19/11/20.
//

import SwiftUI

extension Sequence {
    /*sorted(by:) method rethrows, which means if areInIncreasingOrder is passed a throwing function
     then this sorted(by:) method also becomes a throwing function. On the other hand,
     if areInIncreasingOrder is not a throwing function then this
     sorted(by:) method also is not – this is the power of rethrows
     */
    // Removes the reliance on Comparable
    func sorted<Value>(
        by keyPath: KeyPath<Element, Value>,
        using areInIncreasingOrder: (Value, Value) throws -> Bool
    ) rethrows -> [Element] {
        try self.sorted {
            try areInIncreasingOrder($0[keyPath: keyPath], $1[keyPath: keyPath])
        }
    }
    func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>) -> [Element] {
        self.sorted(by: keyPath, using: <)
    }
}
