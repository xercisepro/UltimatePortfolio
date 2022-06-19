//
//  ProjectsViewModel.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 20/3/21.
//

import Foundation
import CoreData
import SwiftUI

extension ProjectView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {

        var sortOrder = Item.SortOrder.optimised
        let dataController: DataController
        let showClosedProjects: Bool
        private let projectsController: NSFetchedResultsController<Project>
        @Published var projects = [Project]()
        // Published created an observer pattern source
        @Published var showingUnlockView = false
        @Published var selectedItem: Item?

        init(dataController: DataController, showClosedProjects: Bool) {
            self.dataController = dataController
            self.showClosedProjects = showClosedProjects

            let request: NSFetchRequest<Project> = Project.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.creationDate, ascending: false)]
            request.predicate = NSPredicate(format: "closed = %d", showClosedProjects)
            projectsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            super.init()
            projectsController.delegate = self

            do {
                try projectsController.performFetch()
                projects = projectsController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch projects")
            }
        }
        func addProject() {
            if dataController.addProject() == false {
                showingUnlockView.toggle()
            }
        }

        func addItem(to project: Project) {
            /// Adds an item to the project and stores the instance in coredata
            let item = Item(context: dataController.container.viewContext)
            // The first two defaults are required to keep coredata happy and ensure
            // the item shows immediately upon creation.
            item.priority = 2
            item.completed = false
            item.project = project
            item.creationDate = Date()
            dataController.save()
        }

        func delete(_ offsets: IndexSet, from project: Project) {
            let allItems = items(for: project)
            for offset in offsets {
                let item = allItems[offset]
                dataController.delete(item)
            }
            dataController.save()
        }

        func delete(_ item: Item) {
            /// Funciton to delete an item that is used in MacOS where swipe isn't enable.
            dataController.delete(item)
            dataController.save()
        }

        func items(for project: Project) -> [Item] {
            switch sortOrder {
            case .title:
                return project.projectItems.sorted(by: \Item.itemTitle )
            case .creationDate:
                return project.projectItems.sorted(by: \Item.itemCreationDate )
            default:
                return project.projectItemsDefaultSorted
            }
        }

        // Function to aid it the creation of records and then the publishing of the fact
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newProjects = controller.fetchedObjects as? [Project] {
                projects = newProjects
            }
        }

    }
}
