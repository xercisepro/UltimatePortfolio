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
            let project = Project(context: dataController.container.viewContext)
            project.closed = false
            project.creationDate = Date()
            dataController.save()

        }

        func addItem(to project: Project) {
            let item = Item(context: dataController.container.viewContext)
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
