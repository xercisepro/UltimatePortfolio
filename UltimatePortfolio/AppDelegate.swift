//
//  AppDelegate.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 7/3/22.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    /*
     Implementation of AppDelegates and swfit Delegates are required
     in order to implement Quick Actions. These aren't supported
     by SwiftUI as yet and hence the need to bridge to UIKit
     */

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(name: "Default", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = SceneDelegate.self
        return sceneConfiguration
    }
}
