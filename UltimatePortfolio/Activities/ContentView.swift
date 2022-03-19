//
//  ContentView.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 4/11/20.
//

import SwiftUI
import CoreSpotlight

struct ContentView: View {
    @SceneStorage("selectedView") var selectedView: String?// Optional String so make sure the property is too
    // additonally for this make sure you are supporting scenes by using @SceneStorage instead of @appStorage
    @EnvironmentObject var dataController: DataController

    // shortcut activity magic key
    private let newProjectActivity = "com.xercisepro.newProject"

    var body: some View {
        TabView(selection: $selectedView) {
            HomeView(dataController: dataController)
                .tag(HomeView.tag)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            ProjectView(dataController: dataController, showClosedProjects: false)
                .tag(ProjectView.openTag)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Open")
                }
            ProjectView(dataController: dataController, showClosedProjects: true)
                .tag(ProjectView.closedTag)
                .tabItem {
                    Image(systemName: "checkmark")
                    Text("Closed")
                }
            AwardsView()
                .tag(AwardsView.tag)
                .tabItem {
                    Image(systemName: "rosette")
                    Text("Awards")
                }
        }
        .onContinueUserActivity(CSSearchableItemActionType, perform: moveToHome) // spotlight activity
        .onContinueUserActivity(newProjectActivity, perform: createProject) // shortcut activity
        .userActivity(newProjectActivity, { activity in
            activity.isEligibleForPrediction = true // this allows the OS prompt this based on user behaviour
            activity.title = "New Project"
        })

        .onOpenURL(perform: openURL)
    }

    func moveToHome(_ input: Any) {
        selectedView = HomeView.tag
    }

    func openURL(_ url: URL) {
        selectedView = ProjectView.openTag
        dataController.addProject()
    }

    func createProject(_ userActivity: NSUserActivity) {
        // Function that is called by the OS shortcut feature for the app
        selectedView = ProjectView.openTag
        dataController.addProject()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
