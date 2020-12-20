//
//  HomeView.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 4/11/20.
//

import SwiftUI
import CoreData

struct HomeView: View {
    
    static let tag: String? = "Home"
    let items: FetchRequest<Item>
    var projectRows: [GridItem]{
        [GridItem(.fixed(100))]
    }
    
    @EnvironmentObject var dataController: DataController
    
    @FetchRequest(entity: Project.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Project.title, ascending: true)], predicate: NSPredicate(format: "closed = false")) var projects: FetchedResults<Project>
    
    //Custom Initialiser to get the items for display as we are limiting the amount requested and hence composing the request
    
    init() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "completed = false")
        
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Item.priority, ascending: false)
        ]
        
        request.fetchLimit = 10
        
        items = FetchRequest(fetchRequest: request)
    }
    
    var body: some View{
        NavigationView{
            
            //For testing
            /*VStack{
                Button("Add Data"){
                    dataController.deleteAll()
                    try? dataController.createSampleData()
                }
            }*/
            
            ScrollView{
                VStack(alignment: .leading){
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: projectRows){
                            ForEach(projects, content: ProjectSummaryView.init)
                        }
                        .padding([.horizontal, .top])
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    VStack(alignment: .leading) {
                        ItemListView(title: "Up next", items: items.wrappedValue.prefix(3))
                        ItemListView(title: "More to explore", items: items.wrappedValue.dropFirst(3))
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color.systemGroupedBackground.ignoresSafeArea())
            .navigationTitle("Home")
        }
    }
}

struct HomeView_Preview: PreviewProvider {
    static var previews: some View{
        HomeView()
    }
}
