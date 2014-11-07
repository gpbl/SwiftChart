//
//  GPLineChartTests.swift
//  GPLineChartTests
//
//  Created by Giampaolo Bellavite on 06/11/14.
//
//

import UIKit
import XCTest

class GPLineChartTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSegmentLine() {
        
        let line: Array<(x: Float, y: Float)> = [
            (x: 1, y: -1), (x: 2, y: 0.0), (x: 3, y: 1)
        ]
        
        let segments = GPLineChart.segmentLine(line)
        XCTAssert(segments.count == 2)
        XCTAssert(segments[0][1].x == 2)
        
    }
    
}
