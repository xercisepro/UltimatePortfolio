//
//  Binding-OnChange.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 10/11/20.
//

import SwiftUI

extension Binding{
    func onChange(_ handler: @escaping () -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler()
            }
        )
    }
}
