//
//  SharedItemsView.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 8/5/22.
//

import CloudKit
import SwiftUI
import CryptoKit

struct SharedItemsView: View {
    let project: SharedProject

    @State private var items = [SharedItem]()
    @State private var itemsLoadState = LoadState.inactive

    // Chat Variables
    @State private var messages = [ChatMessage]()
    @AppStorage("username") var username: String?
    @State private var showingSighIn = false
    @State private var newChatText = ""
    @State private var messagesLoadState = LoadState.inactive
    @State private var cloudError: CloudError?

    // Chat Message display Footer
    @ViewBuilder var messagesFooter: some View {
        if username == nil {
            Button("Sign in to comment", action: signIn)
                .frame(maxWidth: .infinity)
        } else {
            VStack {
                TextField("Enter your message", text: $newChatText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textCase(nil)
                Button(action: sendChatMessage) {
                    Text("Send")
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .contentShape(Capsule())
                }
            }
        }
    }

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

            // Chat section
            Section(
                header: Text("Chat about this project"),
                footer: messagesFooter
            ) {
                if messagesLoadState == .success {
                    ForEach(messages) { message in
                        Text("\(Text(message.from).bold()): \(message.text)")
                            .multilineTextAlignment(.leading)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(project.title)
        .onAppear {
            fetchSharedItems()
            fetchChatMessages()
        }
        .alert(item: $cloudError) { error in
            Alert(
                title: Text("There was an error"),
                message: Text(error.message)
            )
        }
        .sheet(isPresented: $showingSighIn, content: SignInView.init)
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

        // Request and Decode data returned
        // Cursors are based on data being fetched in batches and
        // may need to be recursively called again
        // Cursor isn't considered here.
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
                cloudError = CloudError(error: error)
            }
        }

        // Netork Response
        operation.queryResultBlock = { result in
            switch result {
            case .success:
                if items.isEmpty {
                    itemsLoadState = .noResults
                }
            case let .failure(error):
                cloudError = CloudError(error: error)
            }
        }

        // Final dispatch request to iCloud
        CKContainer.default().publicCloudDatabase.add(operation)
    }

    func signIn() {
        /// Triggers the presentation of the signin sheet
        showingSighIn = true
    }

    func sendChatMessage() {
        /// Grabs the chat message data and sends it to iCloud for storage and resets the UI applicable to the outcome
        let text = newChatText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.count > 2 else { return }
        guard let username = username else {
            return
        }

        // more code to come
        let message = CKRecord(recordType: "Message")
        message["from"] = username
        message["text"] = text

        let projectID = CKRecord.ID(recordName: project.id)
        message["project"] = CKRecord.Reference(recordID: projectID, action: .deleteSelf)

        // Take a copy of the chat and remove it from the UI so that it can't be modified
        // during dispatch process

        let backupChatText = newChatText
        newChatText = ""

        // send the new chat off the icloud
        CKContainer.default().publicCloudDatabase.save(message) { record, error in
            if let error = error {
                cloudError = CloudError(error: error)
                newChatText = backupChatText
            } else if let record = record {
                let message = ChatMessage(from: record)
                messages.append(message)
            }
        }

    }

    func fetchChatMessages() {
        /// Fetch chat messages for project from iCloud
        guard messagesLoadState == .inactive else {return}
        messagesLoadState = .loading

        let recordID = CKRecord.ID(recordName: project.id)
        let reference = CKRecord.Reference(recordID: recordID, action: .none)
        let pred = NSPredicate(format: "project == %@", reference)
        let sort = NSSortDescriptor(key: "creationDate", ascending: true)
        let query = CKQuery(recordType: "Message", predicate: pred)
        query.sortDescriptors = [sort]

        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["from", "text"]

        // Data Request Response
        operation.recordMatchedBlock = { (_, result) in

            switch result {
            case let .success(record):
                let message = ChatMessage(from: record)
                messages.append(message)
                messagesLoadState = .success
            case let .failure(error):
                cloudError = CloudError(error: error)
            }
        }

        // Network Response
        operation.queryResultBlock = { result in
            switch result {
            case .success:
                if messages.isEmpty {
                    messagesLoadState = .noResults
                }
            case let .failure(error):
                cloudError = CloudError(error: error)
            }

        }

        CKContainer.default().publicCloudDatabase.add(operation)
    }
}

struct SharedItemsView_Previews: PreviewProvider {
    static var previews: some View {
        SharedItemsView(project: SharedProject.example)
    }
}
