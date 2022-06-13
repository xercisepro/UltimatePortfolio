//
//  UltimatePortfolioApp.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 4/11/20.
//

import SwiftUI

@main
struct UltimatePortfolioApp: App {
    @StateObject var dataController: DataController
    @StateObject var unlockManager: UnlockManager

    // A wrapper to enable appDelegate/sceneDelegate functionality when needed
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        let dataController = DataController()
        let unlockManager = UnlockManager(dataController: dataController)

        _dataController = StateObject(wrappedValue: dataController)
        _unlockManager = StateObject(wrappedValue: unlockManager)

        // Hardcoded user for test environment
        #if targetEnvironment(simulator)
        // Force a specific username because SignIn with Apple doesn't work in the simulator
        UserDefaults.standard.set("XercisePro", forKey: "username")
        #endif
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
                .environmentObject(unlockManager)
                // Automatically save when we detect that we are
                // no longer the foreground app. Use this rather than
                // scene phase so we can port to macOS, where scene
                // phase won't detect our app losing focus.
                .onReceive(
                    NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification),
                    perform: save
                )
                .onAppear(perform: dataController.appLaunched)
        }
    }
    func save(_ note: Notification) {
        dataController.save()
    }
}
