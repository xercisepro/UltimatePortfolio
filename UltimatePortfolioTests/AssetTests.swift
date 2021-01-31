//
//  AssetTests.swift
//  UltimatePortfolioTests
//
//  Created by Andrew CP Markham on 20/1/21.
//

import XCTest
@testable import UltimatePortfolio

class AssetTests: XCTestCase {

    func testColorExists() {
        for color in Project.colors {
            XCTAssertNotNil(UIColor(named: color), "Failed to load color '\(color)' from asset catalog")
        }
    }
    func testJSONLoadCorrectly() {
        XCTAssertTrue(Award.allAwards.isEmpty == false, "Failed to load awards from JSON.")
    }

}
