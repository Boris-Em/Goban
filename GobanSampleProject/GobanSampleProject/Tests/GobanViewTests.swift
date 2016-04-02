//
//  GobanViewTests.swift
//  GobanSampleProject
//
//  Created by Bobo on 3/20/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import XCTest
@testable import GobanSampleProject

class GobanViewTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testClosestGobanPointFromPoint() {
        var goban = GobanView(size: GobanSize(width: 19, height: 19), frame: CGRectMake(0.0, 0.0, 200.0, 200.0))

        var gobanPoint = goban.closestGobanPointFromPoint(CGPointZero)
        var expectedGobanPoint = GobanPoint(x: 1, y: 1)
        XCTAssertEqual(gobanPoint.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(50.0, 50.0))
        expectedGobanPoint = GobanPoint(x: 5, y: 5)
        XCTAssertEqual(gobanPoint.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(100.0, 100.0))
        expectedGobanPoint = GobanPoint(x: 10, y: 10)
        XCTAssertEqual(gobanPoint.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(200.0, 200.0))
        expectedGobanPoint = GobanPoint(x: 19, y: 19)
        XCTAssertEqual(gobanPoint.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(120.0, 40.0))
        expectedGobanPoint = GobanPoint(x: 12, y: 4)
        XCTAssertEqual(gobanPoint.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(300.0, 300.0))
        expectedGobanPoint = GobanPoint(x: 19, y: 19)
        XCTAssertEqual(gobanPoint.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(-1.0, -1.0))
        expectedGobanPoint = GobanPoint(x: 1, y: 1)
        XCTAssertEqual(gobanPoint.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(-100.0, -100.0))
        expectedGobanPoint = GobanPoint(x: 1, y: 1)
        XCTAssertEqual(gobanPoint.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(-100.0, 500.0))
        expectedGobanPoint = GobanPoint(x: 1, y: 19)
        XCTAssertEqual(gobanPoint.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint.y, expectedGobanPoint.y)
        
        goban = GobanView(size: GobanSize(width: 50, height: 20), frame: CGRectMake(0.0, 0.0, 100.0, 200.0))
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointZero)
        expectedGobanPoint = GobanPoint(x: 1, y: 1)
        XCTAssertEqual(gobanPoint.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(50.0, 50.0))
        expectedGobanPoint = GobanPoint(x: 26, y: 5)
        XCTAssertEqual(gobanPoint.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(100.0, 100.0))
        expectedGobanPoint = GobanPoint(x: 50, y: 11)
        XCTAssertEqual(gobanPoint.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(200.0, 200.0))
        expectedGobanPoint = GobanPoint(x: 50, y: 20)
        XCTAssertEqual(gobanPoint.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(120.0, 40.0))
        expectedGobanPoint = GobanPoint(x: 50, y: 4)
        XCTAssertEqual(gobanPoint.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(300.0, 300.0))
        expectedGobanPoint = GobanPoint(x: 50, y: 20)
        XCTAssertEqual(gobanPoint.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(-1.0, -1.0))
        expectedGobanPoint = GobanPoint(x: 1, y: 1)
        XCTAssertEqual(gobanPoint.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(-100.0, -100.0))
        expectedGobanPoint = GobanPoint(x: 1, y: 1)
        XCTAssertEqual(gobanPoint.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(-100.0, 500.0))
        expectedGobanPoint = GobanPoint(x: 1, y: 20)
        XCTAssertEqual(gobanPoint.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint.y, expectedGobanPoint.y)
    }
}
