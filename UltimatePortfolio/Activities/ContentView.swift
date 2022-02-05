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
        .onContinueUserActivity(CSSearchableItemActionType, perform: moveToHome)
    }

    func moveToHome(_ input: Any) {
        selectedView = HomeView.tag
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
