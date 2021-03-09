//
//  PerformanceTests.swift
//  UltimatePortfolioTests
//
//  Created by Andrew CP Markham on 17/2/21.
//

import XCTest
@testable import UltimatePortfolio

class PerformanceTests: BaseTestCase {
    func testAwardCalculationPerformance() throws {
        // Create a significant amount of test data
        for _ in 1...100 {
            try dataController.createSampleData()
        }

        // Simulate lots of awards to check
        // Make one big single array
        let awards = Array(repeating: Award.allAwards, count: 25).joined()
        XCTAssertEqual(awards.count, 500, "This checks the awards count is constant. Change this if you add awards." )

        measure {
            _ = awards.filter(dataController.hasEarned)
        }
    }

}
