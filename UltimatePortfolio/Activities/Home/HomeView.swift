//
//  HomeView.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 4/11/20.
//

import SwiftUI
import CoreData
import CoreSpotlight

struct HomeView: View {
    static let tag: String? = "Home"
    var projectRows: [GridItem] {
        [GridItem(.fixed(100))]
    }

    @StateObject var viewModel: ViewModel

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                if let item = viewModel.selectedItem {
                    NavigationLink(
                        destination: EditItemView(item: item),
                        tag: item,
                        selection: $viewModel.selectedItem,
                        label: EmptyView.init
                    ).id(item)
                }

                VStack(alignment: .leading) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: projectRows) {
                            ForEach(viewModel.projects, content: ProjectSummaryView.init)
                        }
                        .padding([.horizontal, .top])
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    VStack(alignment: .leading) {
                        ItemListView(title: "Up next", items: viewModel.upNext)
                        ItemListView(title: "More to explore", items: viewModel.moreToExplore)
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color.systemGroupedBackground.ignoresSafeArea())
            .navigationTitle("Home")
            // For testing
            .toolbar {
                Button("Add Data", action: viewModel.addSampleData)
            }
            // For loading an item that was selected in spotlight
            .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem)
        }
    }

    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as?
            String {
            viewModel.selectItem(with: uniqueIdentifier)
        }
    }
}

struct HomeViewPreview: PreviewProvider {
    static var previews: some View {
        HomeView(dataController: .preview)
    }
}
