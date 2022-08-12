//
//  HomeViewModel.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 3/2/22.
//

import Foundation
import CoreData

extension HomeView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        private let projectsController: NSFetchedResultsController<Project>
        private let itemsController: NSFetchedResultsController<Item>

        @Published var upNext = ArraySlice<Item>()
        @Published var moreToExplore = ArraySlice<Item>()

        @Published var projects = [Project]()
        @Published var items = [Item]()
        @Published var selectedItem: Item?

        var dataController: DataController

        init(dataController: DataController) {
            self.dataController = dataController

            // Construct a fetch request to show open projects.
            let projectRequest: NSFetchRequest<Project> = Project.fetchRequest()
            projectRequest.predicate = NSPredicate(format: "closed = false")
            projectRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Project.title, ascending: true)]

            projectsController = NSFetchedResultsController(
                fetchRequest: projectRequest,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            let itemRequest = dataController.fetchRequestForTopItems(count: 10)

            itemsController = NSFetchedResultsController(
                fetchRequest: itemRequest,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            super.init()

            projectsController.delegate = self
            itemsController.delegate = self

            do {
                try projectsController.performFetch()
                try itemsController.performFetch()
                projects = projectsController.fetchedObjects ?? []
                items = itemsController.fetchedObjects ?? []
                upNext = items.prefix(3)
                moreToExplore = items.dropFirst(3)
            } catch {
                print("Failed te fetch initial data.")
            }
        }

        /// Function to aid it the creation of records and then the publishing of the fact
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

            items = itemsController.fetchedObjects ?? []

            upNext = items.prefix(3)
            moreToExplore = items.dropFirst(3)

            projects = projectsController.fetchedObjects ?? []
        }

        func addSampleData() {
            dataController.deleteAll()
            try? dataController.createSampleData()
        }

        func selectItem(with identifier: String) {
            selectedItem = dataController.item(with: identifier)
        }
    }
}
