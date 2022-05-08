//
//  SharedItemsView.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 8/5/22.
//

import CloudKit
import SwiftUI

struct SharedItemsView: View {
    let project: SharedProject

    @State private var items = [SharedItem]()
    @State private var itemsLoadState = LoadState.inactive

    var body: some View {
        List {
            Section {
                switch itemsLoadState {
                case .inactive, .loading:
                    ProgressView()
                case .noResults:
                    Text("No results")
                case .success:
                    ForEach(items) { item in
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.headline)

                            //  Check required as empty text view that offsets the layout in a strange way
                            if item.detail.isEmpty == false {
                                Text(item.detail)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(project.title)
        .onAppear(perform: fetchSharedItems)
    }

    func fetchSharedItems() {
        guard itemsLoadState == .inactive else { return }
        itemsLoadState = .loading

        // Set up request to cloudkit
        let recordID = CKRecord.ID(recordName: project.id)
        let reference = CKRecord.Reference(recordID: recordID, action: .none)
        let pred = NSPredicate(format: "project == %@", reference)
        let sort = NSSortDescriptor(key: "title", ascending: true)
        let query = CKQuery(recordType: "Item", predicate: pred)
        query.sortDescriptors = [sort]

        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["title", "detail", "completed"]
        operation.resultsLimit = 50

        // Decode data returned
        operation.recordMatchedBlock = { (_, result) in
            switch result {
            case let .success(record):
                let id = record.recordID.recordName
                let title = record["title"] as? String ?? "No title"
                let detail = record["detail"] as? String ?? ""
                let completed = record["completed"] as? Bool ?? false

                let sharedItem = SharedItem(id: id, title: title, detail: detail, completed: completed )
                items.append(sharedItem)
                itemsLoadState = .success
            case let .failure(error):
                print("error; \(error)")
            }
        }

        // Cursors are based on data being fetched in batches and
        // may need to be recursively called again
        // Cursor isn't considered here.
        operation.queryResultBlock = { result in
            switch result {
            case .success:
                if items.isEmpty {
                    itemsLoadState = .noResults
                }
            case let .failure(error):
                print("error; \(error)")
            }
        }

        // Final dispatch request to iCloud
        CKContainer.default().publicCloudDatabase.add(operation)
    }
}

struct SharedItemsView_Previews: PreviewProvider {
    static var previews: some View {
        SharedItemsView(project: SharedProject.example)
    }
}
