//
//  PlatformAdjustments.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 15/6/2022.
//

import SwiftUI

typealias ImageButtonStyle = BorderlessButtonStyle
typealias MacOnlySpacer = EmptyView

struct StackNavigationView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        NavigationView(content: content)
            .navigationViewStyle(.stack)
    }
}

extension Notification.Name {
    static let willResignActive = UIApplication.willResignActiveNotification
}

extension Section where Parent: View, Content: View, Footer: View {
    // Workaround collapsing progress view
    func disableCollapsing() -> some View {
        self
    }
}

extension View {
    /// Fucntion to short circuit OnDeleteComand that doesnt exist on IOS
    func onDeleteCommand(perform action: (() -> Void)?) -> some View {
        self
    }

    /// Inert function coinciding with Mac OS need for padding in form view
    func macOnlyPadding() -> some View {
        self
    }
}
