//
//  PlatformAdjustments.swift
//  UltimatePortfolioMac
//
//  Created by Andrew CP Markham on 15/6/2022.
//

import SwiftUI

typealias InsetGroupedListStyle = SidebarListStyle
typealias ImageButtonStyle = BorderlessButtonStyle
typealias MacOnlySpacer = Spacer

struct StackNavigationView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0, content: content)
    }
}

extension Notification.Name {
    static let willResignActive = NSApplication.willResignActiveNotification
}

extension Section where Parent: View, Content: View, Footer: View {
    // Workaround collapsing progress view
    func disableCollapsing() -> some View {
        self.collapsible(false)
    }
}

extension View {
    /// Function to add padding sytle on mac OS
    func macOnlyPadding() -> some View {
        self.padding()
    }
}
