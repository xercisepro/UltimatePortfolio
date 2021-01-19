//
//  Item-CoreDataHelpers.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 6/11/20.
//

import Foundation

// Used to support optional values
extension Item {
    var itemTitle: String {
        title ?? NSLocalizedString("New Item", comment: "Create a new item")
    }
    var itemDetail: String {
        detail ?? ""
    }
    var itemCreationDate: Date {
        creationDate ?? Date()
    }
    static var example: Item {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        let item = Item(context: viewContext)
        item.title = "Example Item"
        item.detail = "This is an example item"
        item.priority = 3
        item.creationDate = Date()
        return item
    }
}
extension Item {
    enum SortOrder {
        case optimised, title, creationDate
    }
}
