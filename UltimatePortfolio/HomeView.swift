//
//  HomeView.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 4/11/20.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataController: DataController
    
    var body: some View{
        NavigationView{
            VStack{
                Button("Add Data"){
                    dataController.deleteAll()
                    try? dataController.createSampleData()
                }
            }
            .navigationTitle("Home")
        }
    }
}

struct HomeView_Preview: PreviewProvider {
    static var previews: some View{
        HomeView()
    }
}
