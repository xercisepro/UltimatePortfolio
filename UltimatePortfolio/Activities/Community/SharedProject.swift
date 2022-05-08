//
//  SharedProject.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 8/5/22.
//

import Foundation

struct SharedProject: Identifiable {
    let id: String
    let title: String
    let detail: String
    let owner: String
    let closed: Bool

    static let example = SharedProject(
        id: "1",
        title: "Example Title",
        detail: "Example Description",
        owner: "Xercise Pro",
        closed: false
    )
}
