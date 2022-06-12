//
//  Project-CoreDataHelpers.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 6/11/20.
//

import SwiftUI
import CloudKit

extension Project {
    static let colors = [
        "Pink",
        "Purple",
        "Red", "Orange",
        "Gold", "Green", "Teal",
        "Light Blue",
        "Dark Blue",
        "Midnight",
        "Dark Gray",
        "Gray"
    ]
    var projectTitle: String {
        title ?? NSLocalizedString("New Project", comment: "Create a new project")
    }
    var projectDetail: String {
        detail ?? ""
    }
    var projectColor: String {
        color ?? "Light Blue"
    }
    var projectItems: [Item] {
        items?.allObjects as?  [Item] ?? []
    }
    var projectItemsDefaultSorted: [Item] {
        projectItems.sorted { first, second in
            // put completed at bottom
            if first.completed == false {
                if second.completed == true {
                    return true
                }
            } else if first.completed == true {
                if second.completed == false {
                    return false
                }
            }
            // Put higher priority at the top
            if first.priority > second.priority {
                return true
            } else if first.priority < second.priority {
                return false
            }
            // else sort by date
            return first.itemCreationDate < second.itemCreationDate
        }
    }
    var label: LocalizedStringKey {
        // swiftlint:disable:next line_length
        LocalizedStringKey("\(projectTitle), \(projectItems.count) items, \(completionAmount * 100, specifier: "%g")% complete.")
    }
    var completionAmount: Double {
        let originalItems = items?.allObjects as? [Item] ?? []
        guard originalItems.isEmpty == false else {return 0}
        let completedItems = originalItems.filter(\.completed)
        return Double(completedItems.count) / Double(originalItems.count)
    }
    static var example: Project {
        let controller = DataController.preview
        let viewContext = controller.container.viewContext
        let project = Project(context: viewContext)
        project.title = "Example Project"
        project.detail = "This is an example project"
        project.closed = true
        project.creationDate = Date()
        return project
    }

    func prepareCloudRecords(owner: String) -> [CKRecord] {
        /// Setup data and data strucutre for upload to cloudkit
        let parentName = objectID.uriRepresentation().absoluteString
        let parentID = CKRecord.ID(recordName: parentName)
        // Equivalent of NSManagedObject
        let parent = CKRecord(recordType: "Project", recordID: parentID)
        parent["title"] = projectTitle
        parent["detail"] = projectDetail
        parent["owner"] = owner
        parent["closed"] = closed

        var records = projectItemsDefaultSorted.map { item -> CKRecord in
            let childName = item.objectID.uriRepresentation().absoluteString
            let childID = CKRecord.ID(recordName: childName)
            let child = CKRecord(recordType: "Item", recordID: childID)
            child["title"] = item.itemTitle
            child["detail"] = item.itemDetail
            child["completed"] = item.completed
            // Link each item to the project and set a cascading delete
            child["project"] =  CKRecord.Reference(recordID: parentID, action: .deleteSelf)
            return child
        }

        records.append(parent)
        return records
    }

    func checkCloudStatus(_ completion: @escaping (Bool) -> Void) {
        // fetch(withRecordID:) although looking like a better candidate function
        // has a lower priority in icloud and hence not optimal performance wise

        let name = objectID.uriRepresentation().absoluteString
        let id = CKRecord.ID(recordName: name)
        let operation = CKFetchRecordsOperation(recordIDs: [id])
        operation.desiredKeys = ["recordID"]

//      Network Failure Check Code
//        operation.fetchRecordsResultBlock = { result in
//            switch result {
//            case .success:
//                print( "Network Success")
//
//            case .failure:
//                print("Network Failure")
//            }
//        }

        operation.perRecordResultBlock = { record, result in
            switch result {
            case .success:
                print("Record is in iCloud:\(record)")
                completion(true)
            case .failure:
                // No record returned or System Failure with iCloud ie network
                print("Record is not in iCloud")
                completion(false)
            }
        }

        // Code for < IOS 15
//        operation.fetchRecordsCompletionBlock = { records, _ in
//            if let records = records {
//                completion(records.count == 1)
//            } else {
//                completion(false)
//            }
//        }

        CKContainer.default().publicCloudDatabase.add(operation)
    }
}
