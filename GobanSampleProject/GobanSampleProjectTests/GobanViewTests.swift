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
        XCTAssertEqual(gobanPoint?.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint?.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(50.0, 50.0))
        expectedGobanPoint = GobanPoint(x: 5, y: 5)
        XCTAssertEqual(gobanPoint?.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint?.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(100.0, 100.0))
        expectedGobanPoint = GobanPoint(x: 10, y: 10)
        XCTAssertEqual(gobanPoint?.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint?.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(200.0, 200.0))
        XCTAssertNil(gobanPoint)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(120.0, 40.0))
        expectedGobanPoint = GobanPoint(x: 12, y: 4)
        XCTAssertEqual(gobanPoint?.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint?.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(300.0, 300.0))
        XCTAssertNil(gobanPoint)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(-1.0, -1.0))
        XCTAssertNil(gobanPoint)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(-100.0, -100.0))
        XCTAssertNil(gobanPoint)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(-100.0, 500.0))
        XCTAssertNil(gobanPoint)
        
        goban = GobanView(size: GobanSize(width: 50, height: 20), frame: CGRectMake(0.0, 0.0, 100.0, 200.0))
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointZero)
        expectedGobanPoint = GobanPoint(x: 1, y: 1)
        XCTAssertEqual(gobanPoint?.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint?.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(50.0, 50.0))
        expectedGobanPoint = GobanPoint(x: 26, y: 5)
        XCTAssertEqual(gobanPoint?.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint?.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(100.0, 100.0))
        XCTAssertNil(gobanPoint)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(200.0, 200.0))
        XCTAssertNil(gobanPoint)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(120.0, 40.0))
        XCTAssertNil(gobanPoint)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(300.0, 300.0))
        XCTAssertNil(gobanPoint)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(-1.0, -1.0))
        XCTAssertNil(gobanPoint)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(-100.0, -100.0))
        XCTAssertNil(gobanPoint)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPointMake(-100.0, 500.0))
        XCTAssertNil(gobanPoint)
    }
    
    func testSetStone() {
        let goban = GobanView(size: GobanSize(width: 19, height: 19), frame: CGRectMake(0.0, 0.0, 200.0, 200.0))
        goban.reload()
        
        let initialNumberOfSublayers = 2

        let stone = Stone(stoneColor: .Black, disabled: false)
        var gobanPoint = GobanPoint(x: 0, y: 0)
        goban.setStone(stone, atGobanPoint: gobanPoint)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers)
        
        gobanPoint = GobanPoint(x: 20, y: 20)
        goban.setStone(stone, atGobanPoint: gobanPoint)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers)
        
        gobanPoint = GobanPoint(x: 1, y: 1)
        goban.setStone(stone, atGobanPoint: gobanPoint)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers + 1)
        
        gobanPoint = GobanPoint(x: 19, y: 19)
        goban.setStone(stone, atGobanPoint: gobanPoint)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers + 2)
        
        gobanPoint = GobanPoint(x: 5, y: 2)
        goban.setStone(stone, atGobanPoint: gobanPoint)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers + 3)
        
        gobanPoint = GobanPoint(x: 2, y: 15)
        goban.setStone(stone, atGobanPoint: gobanPoint)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers + 4)
        
        gobanPoint = GobanPoint(x: 7, y: 7)
        goban.setStone(stone, atGobanPoint: gobanPoint)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers + 5)
        
        goban.reload()
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers)

        gobanPoint = GobanPoint(x: 0, y: 15)
        goban.setStone(stone, atGobanPoint: gobanPoint)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers)
        
        gobanPoint = GobanPoint(x: 15, y: 0)
        goban.setStone(stone, atGobanPoint: gobanPoint)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers)
        
        gobanPoint = GobanPoint(x: 1, y: 19)
        goban.setStone(stone, atGobanPoint: gobanPoint)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers + 1)

        gobanPoint = GobanPoint(x: 7, y: 12)
        goban.setStone(stone, atGobanPoint: gobanPoint)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers + 2)

        gobanPoint = GobanPoint(x: 19, y: 10)
        goban.setStone(stone, atGobanPoint: gobanPoint)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers + 3)
        
        gobanPoint = GobanPoint(x: -100, y: 200)
        goban.setStone(stone, atGobanPoint: gobanPoint)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers + 3)
    }
}
