//
//  DataController.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 4/11/20.
//

import CoreData
import SwiftUI
import CoreSpotlight
import WidgetKit

/// An environment singleton responsible for managing our Core Data stack, including handling saving,
/// counting fetch requests, tracking awards, and dealing with sample data.
class DataController: ObservableObject {
    /// The lone Cloudkit contrainer used to store all our data.
    let container: NSPersistentContainer

    static let sharedMemoryKey = "group.com.xercisepro.ultimateportfolio"
    static let sharedMemoryStore = "main.sqlite"

    /// The user defaults suite where we're saving user data
    /// Implemented through initialiser like this so there is no hidden dependency
    /// which would implact testing
    let defaults: UserDefaults

    /// Loads  and saved wherer our premium unlock has been purchased
    var fullVersionUnlocked: Bool {
        get {
            defaults.bool(forKey: "fullVersionUnlocked")
        }

        set {
            defaults.set(newValue, forKey: "fullVersionUnlocked")
        }
    }
    /// Initializes a data controller, either in memory (for temporary use such as testing and previewing
    /// or on permanent storage (for use in regular app runs.)
    ///
    /// Defaults to permanent storage.
    /// - Parameter inMemory: Whether to store this data in temporary memory or not.
    init(inMemory: Bool = false, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)
        if inMemory {
            // For testing and previewing purposes, we create a
            // temporary, in-memory database by writing to /dev/null (deadzone)
            // so our data is destroyed after the app finishes running.
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            let groupID = DataController.sharedMemoryKey

            if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) {
                container.persistentStoreDescriptions.first?.url =
                    url.appendingPathComponent(DataController.sharedMemoryStore)
            }
        }
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }

            // merge all changes that happen across all devices
            self.container.viewContext.automaticallyMergesChangesFromParent = true

            #if DEBUG
            if CommandLine.arguments.contains("enable-testing") {
                self.deleteAll()
                // Turn off animations for UITesting to ensure tests are performed as fast as possible
                UIView.setAnimationsEnabled(false)
            }
            #endif
        })
    }
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        let viewContext = dataController.container.viewContext
        do {
            try dataController.createSampleData()
        } catch { fatalError("Fatal error creating preview: \(error.localizedDescription)")}
        return dataController
    }()
    /// Creates and loads central model file at Build time
    /// Required as unit testing using BaseTestCase creates its own instance of a DataController
    /// which in conjunction with the instance created by the main app confuses the app
    /// as there are > 1 instance of each entitiy
    /// XCODE 12.4
    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("Failed to locate model file url.")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to locate model file")
        }
        return managedObjectModel
    }()
    /// Creates example projects and items to make manual testing easier
    /// - Throws: An NSError sent from calling save() on the NSManagedObjectContext.
    func createSampleData() throws {
        // current live data
        let viewContext = container.viewContext
        for projectCounter in 1...5 {
            let project = Project(context: viewContext)
            project.title = "Project \(projectCounter)"
            project.items = []
            project.creationDate = Date()
            project.closed = Bool.random()
            for itemCounter in 1...10 {
                let item = Item(context: viewContext)
                item.title = "Item \(itemCounter)"
                item.creationDate = Date()
                item.completed = Bool.random()
                item.project = project
                item.priority = Int16.random(in: 1...3)
            }
        }
        try viewContext.save()// write to perminent storage
    }
    /// Saves our Core Data context iff there are changes. This silently ignores
    /// any errors caused by saving. but this should be fine because all our attributes are optional.
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    func update(_ item: Item) {
        /// Function to set the item into Spotlight and then save to CoreData
        let itemID = item.objectID.uriRepresentation().absoluteString
        let projectID = item.project?.objectID.uriRepresentation().absoluteString

        let attributeSet = CSSearchableItemAttributeSet( contentType: .text)
        attributeSet.title = item.title
        attributeSet.contentDescription = item.detail

        let searchableItem = CSSearchableItem(
            uniqueIdentifier: itemID,
            domainIdentifier: projectID,
            attributeSet: attributeSet
        )

        CSSearchableIndex.default().indexSearchableItems([searchableItem])

        save()
    }

    func item(with uniqueIdentifier: String) -> Item? {
        guard let url = URL(string: uniqueIdentifier) else {
            return nil
        }

        guard let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url) else {
            return nil
        }

        return try? container.viewContext.existingObject(with: id) as? Item
    }

    func delete(_ object: Project) {
        let id = object.objectID.uriRepresentation().absoluteString
        CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [id])
        container.viewContext.delete(object)
    }

    func delete(_ object: Item) {
        let id = object.objectID.uriRepresentation().absoluteString
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [id])
        container.viewContext.delete(object)
    }

    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        /// Delete request that updates the view context of the deleted data
        let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest1.resultType = .resultTypeObjectIDs

        if let delete = try? container.viewContext.execute(batchDeleteRequest1) as? NSBatchDeleteResult {
                let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }

    func deleteAll() {
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
        delete(fetchRequest1)

        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Project.fetchRequest()
        delete(fetchRequest2)
    }

    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }
}

extension DataController {
    /// Functionality  for adding projects has been refactored here so that it is available for quick action
    /// usage in sceneDelegare

    @discardableResult func addProject() -> Bool {
        let canCreate = fullVersionUnlocked || count(for: Project.fetchRequest()) < 3
        if canCreate {
            let project = Project(context: container.viewContext)
            project.closed = false
            project.creationDate = Date()
            save()
            return true
        } else {
            return false
        }
    }
}

extension DataController {

    // Functionality required for widget to get the highest priority item

    func fetchRequestForTopItems(count: Int) -> NSFetchRequest<Item> {
        // Construct a fetch request to show the 10 highest priority
        // incomplete items for the open projects
        let itemRequest: NSFetchRequest<Item> = Item.fetchRequest()

        let completedPredicate = NSPredicate(format: "completed = false")
        let openPredicate = NSPredicate(format: "project.closed = false")
        itemRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [completedPredicate, openPredicate])
        itemRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Item.priority, ascending: false)]
        itemRequest.fetchLimit = count

        return itemRequest
    }

    func results<T: NSManagedObject>(for fetchRequest: NSFetchRequest<T>) -> [T] {
        return (try? container.viewContext.fetch(fetchRequest)) ?? []
    }
}
