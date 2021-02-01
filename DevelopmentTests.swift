//
//  DevelopmentTests.swift
//  UltimatePortfolioTests
//
//  Created by Andrew CP Markham on 1/2/21.
//
import CoreData
import XCTest
@testable import UltimatePortfolio
class DevelopmentTests: BaseTestCase {

    func testSampleDataCreationWorks() throws {
        try dataController.createSampleData()
        // swiftlint:disable:next line_length
        XCTAssertEqual(dataController.count(for: Project.fetchRequest()), 5, "There should be 5 sample projects but \(dataController.count(for: Project.fetchRequest())) where given.")
        // swiftlint:disable:next line_length
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), 50, "There should be 50 sample items but \(dataController.count(for: Item.fetchRequest())) where given.")
    }
    func testDeleteAllClearsEverything() throws {
        try dataController.createSampleData()
        dataController.deleteAll()
        // swiftlint:disable:next line_length
        XCTAssertEqual(dataController.count(for: Project.fetchRequest()), 0, "deleteAll() should result in 0 projects but gave \(dataController.count(for: Project.fetchRequest()))")
        // swiftlint:disable:next line_length
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), 0, "deleteAll() should result in 0 items but gave \(dataController.count(for: Item.fetchRequest()))")
    }
    func testExampleProjectIsClosed() {
        let project = Project.example
        XCTAssertTrue(project.closed, "The example project should be closed.")
    }
    func testExampleItemIsHighPriority() {
        let item = Item.example
        XCTAssertEqual(item.priority, 3, "The example item should be high priority.")
    }
}
