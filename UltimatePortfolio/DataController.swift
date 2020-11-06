//
//  DataController.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 4/11/20.
//

import CoreData
import SwiftUI

class DataController: ObservableObject {
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false){
        container = NSPersistentCloudKitContainer(name: "Main")
        
        if inMemory{
            //written to a deadzone
            //this is a database in RAM only
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: {
            storeDescription, error in
            if let error = error{
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        })
    }
    
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        let viewContext = dataController.container.viewContext
        
        do {
            try dataController.createSampleData()
        }catch {
            fatalError("Fatal error creating preview: \(error.localizedDescription)")
        }
        
        return dataController
    }()
    
    func createSampleData() throws{
        
        //current live data
        let viewContext = container.viewContext
        
        for i in 1...5{
            let project = Project(context: viewContext)
            project.title = "Project \(i)"
            project.items = []
            project.creationDate = Date()
            project.closed = Bool.random()
            
            for j in 1...10{
                let item = Item(context: viewContext)
                item.title = "Item \(j)"
                item.creationDate = Date()
                item.completed = Bool.random()
                item.project = project
                item.priority = Int16.random(in: 1...3)
            }
        }
        try viewContext.save()//write to perminent storage
    }
    
    func save() {
        if container.viewContext.hasChanges{
            try? container.viewContext.save()
        }
    }
    
    func delete(_ object: NSManagedObject) {
        container.viewContext.delete(object)
    }
    
    func deleteAll() {
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
        let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        _ = try? container.viewContext.execute(batchDeleteRequest1)
        
        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Project.fetchRequest()
        let batchDeleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
        _ = try? container.viewContext.execute(batchDeleteRequest2)
    }
}
