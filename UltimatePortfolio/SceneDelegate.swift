//
//  SceneDelegate.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 7/3/22.
//

import UIKit
import SwiftUI

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    /*
     Implementation of AppDelegates and swfit Delegates are required
     in order to implement Quick Actions. These aren't supported
     by SwiftUI as yet and hence the need to bridge to UIKit
     */

    @Environment(\.openURL) var openURL

    // Fucntion that is called when the appl is first booted
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions) {
            if let shortcutItem = connectionOptions.shortcutItem {
                guard let url = URL(string: shortcutItem.type) else {
                    return
                }
                openURL(url)
            }
    }

    // This function is only called if the app is already running but not from a cold start
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        guard let url = URL(string: shortcutItem.type) else {
            completionHandler(false)
            return
        }
        openURL(url, completion: completionHandler)
    }
}
