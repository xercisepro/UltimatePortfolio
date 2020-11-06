//
//  ContentView.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 4/11/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
        
            ProjectView(showClosedProjects: false)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Open")
                }
        
            ProjectView(showClosedProjects: true)
                .tabItem {
                    Image(systemName: "checkmark")
                    Text("Closed")
                }
        }
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
