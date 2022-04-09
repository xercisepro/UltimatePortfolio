//
//  DataController-AppReview.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 26/3/22.
//

import StoreKit

// Extension created for the sole purpose of separating out code base
// required for widget extension

extension DataController {
    /// Functionality for app review request to user
    func appLaunched () {
        guard count(for: Project.fetchRequest()) >= 5 else { return }
        let allScenes = UIApplication.shared.connectedScenes
        let scene = allScenes.first { $0.activationState == .foregroundActive }

        if let windowScene = scene as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
