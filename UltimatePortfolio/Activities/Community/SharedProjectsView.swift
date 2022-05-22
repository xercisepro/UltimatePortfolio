//
//  SharedProjectsView.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 8/5/22.
//

import CloudKit
import SwiftUI

struct SharedProjectsView: View {
    static let tag: String? = "Community"

    @State private var projects = [SharedProject]()
    @State private var loadState = LoadState.inactive
    var body: some View {
        NavigationView {
            Group {
                switch loadState {
                case .inactive, .loading:
                    ProgressView()
                case .noResults:
                    Text("No Results")
                case .success:
                    List(projects) { project in
                        NavigationLink(destination: SharedItemsView(project: project)) {
                            VStack(alignment: .leading) {
                                Text(project.title)
                                    .font(.headline)
                                Text(project.owner)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Shared Projects")
        }
        .onAppear(perform: fetchSharedProjects)
    }

    /// Function to fetch shared pprojects from iCloud and load them into memory
    func fetchSharedProjects() {

        guard loadState == .inactive else { return }
        loadState = .loading

        // Set up request to cloudkit
        let pred = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        let query = CKQuery(recordType: "Project", predicate: pred)
        query.sortDescriptors = [sort]

        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["title", "detail", "owner", "closed"]
        operation.resultsLimit = 50

        // Decode data returned
        operation.recordMatchedBlock = { (_, result) in
            switch result {
            case let .success(record):
                let id = record.recordID.recordName
                let title = record["title"] as? String ?? "No title"
                let detail = record["detail"] as? String ?? ""
                let owner = record["owner"] as? String ?? "No owner"
                let closed = record["closed"] as? Bool ?? false

                let sharedProject = SharedProject(id: id, title: title, detail: detail, owner: owner, closed: closed)
                projects.append(sharedProject)
                loadState = .success
            case let .failure(error):
                print("error: \(error)")
            }
        }

        // Cursors are based on data being fetched in batches and
        // may need to be recursively called again
        // Cursor isn't considered here.
        operation.queryResultBlock = { result in
            switch result {
            case .success:
                if projects.isEmpty {
                    loadState = .noResults
                }
            case let .failure(error):
                print("error: \(error)")
            }
        }

        // Final dispatch request to iCloud
        CKContainer.default().publicCloudDatabase.add(operation)
    }
}

struct SharedProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        SharedProjectsView()
    }
}
