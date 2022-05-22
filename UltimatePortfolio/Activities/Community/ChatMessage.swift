//
//  ChatMessage.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 21/5/22.
//

import CloudKit

struct ChatMessage: Identifiable {
    /// Datatype used for chat messages that are incorporated in projects
    /// stored publicly in the cloud

    let id: String
    let from: String
    let text: String
    let date: Date
}

extension ChatMessage {
    // Applied seperately to ensure default memberwise initialiser is maintained
    init(from record: CKRecord) {
        id = record.recordID.recordName
        from = record["from"] as? String ?? "No author"
        text = record["text"] as? String ?? "No text"
        date = record.creationDate ?? Date()
    }
}
