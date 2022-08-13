//
//  HomeView.swift
//  UltimatePortfolioMac
//
//  Created by Andrew CP Markham on 13/8/2022.
//

import SwiftUI
import CoreData
import CoreSpotlight

struct HomeView: View {

    static let tag: String? = "Home"

    @StateObject var viewModel: ViewModel

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            List {
                ItemListView(title: "Up next", items: $viewModel.upNext)
                ItemListView(title: "More to explore", items: $viewModel.moreToExplore)
            }
            .listStyle(.sidebar)
            .navigationTitle("Home")
            .toolbar {
                Button("Add Data", action: viewModel.addSampleData)
            }
        }
    }
}

struct HomeViewPreview: PreviewProvider {
    static var previews: some View {
        HomeView(dataController: .preview)
    }
}
