//
//  DataController-Awards.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 26/3/22.
//

import CoreData

// Extension created for the sole purpose of separating out code base
// required for widget extension

extension DataController {
    func hasEarned(award: Award) -> Bool {
        /* fetchRequest is composed as the synthesised fetchRequest() as part of the managedObject subclass
         Xcode has generated will cause issues later with Unit Testing (CoreData will get
         confused where it should find the entity description*/
        switch award.criterion {
        case "items":
            // returns true id they added a certain number of items
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
        case "complete":
            // returns true if they completed a certain number of items
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            fetchRequest.predicate = NSPredicate(format: "completed = true")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
        case "chat":
            // returns true if they have posted a certain number of chat messages
            return UserDefaults.standard.integer(forKey: "chatCount") >= award.value
        default:
            // an unknown award criterion, this should never be allowed
            return false
        }
    }
}
