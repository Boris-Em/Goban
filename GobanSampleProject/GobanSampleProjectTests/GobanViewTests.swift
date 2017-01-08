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
        var goban = GobanView(size: GobanSize(width: 19, height: 19), frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 200.0))

        var gobanPoint = goban.closestGobanPointFromPoint(CGPoint.zero)
        var expectedGobanPoint = GobanPoint(x: 1, y: 1)
        XCTAssertEqual(gobanPoint?.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint?.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPoint(x: 50.0, y: 50.0))
        expectedGobanPoint = GobanPoint(x: 5, y: 5)
        XCTAssertEqual(gobanPoint?.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint?.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPoint(x: 100.0, y: 100.0))
        expectedGobanPoint = GobanPoint(x: 10, y: 10)
        XCTAssertEqual(gobanPoint?.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint?.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPoint(x: 200.0, y: 200.0))
        XCTAssertNil(gobanPoint)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPoint(x: 120.0, y: 40.0))
        expectedGobanPoint = GobanPoint(x: 12, y: 4)
        XCTAssertEqual(gobanPoint?.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint?.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPoint(x: 300.0, y: 300.0))
        XCTAssertNil(gobanPoint)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPoint(x: -1.0, y: -1.0))
        XCTAssertNil(gobanPoint)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPoint(x: -100.0, y: -100.0))
        XCTAssertNil(gobanPoint)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPoint(x: -100.0, y: 500.0))
        XCTAssertNil(gobanPoint)
        
        goban = GobanView(size: GobanSize(width: 50, height: 20), frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 200.0))
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPoint.zero)
        expectedGobanPoint = GobanPoint(x: 1, y: 1)
        XCTAssertEqual(gobanPoint?.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint?.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPoint(x: 50.0, y: 50.0))
        expectedGobanPoint = GobanPoint(x: 26, y: 5)
        XCTAssertEqual(gobanPoint?.x, expectedGobanPoint.x)
        XCTAssertEqual(gobanPoint?.y, expectedGobanPoint.y)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPoint(x: 100.0, y: 100.0))
        XCTAssertNil(gobanPoint)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPoint(x: 200.0, y: 200.0))
        XCTAssertNil(gobanPoint)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPoint(x: 120.0, y: 40.0))
        XCTAssertNil(gobanPoint)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPoint(x: 300.0, y: 300.0))
        XCTAssertNil(gobanPoint)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPoint(x: -1.0, y: -1.0))
        XCTAssertNil(gobanPoint)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPoint(x: -100.0, y: -100.0))
        XCTAssertNil(gobanPoint)
        
        gobanPoint = goban.closestGobanPointFromPoint(CGPoint(x: -100.0, y: 500.0))
        XCTAssertNil(gobanPoint)
    }
    
    func testSetStone() {
        let goban = GobanView(size: GobanSize(width: 19, height: 19), frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 200.0))
        goban.reload()
        
        let initialNumberOfSublayers = 2

        let stone = Stone(stoneColor: .black, disabled: false)
        var gobanPoint = GobanPoint(x: 0, y: 0)
        _ = goban.setStone(stone, atGobanPoint: gobanPoint, isUserInitiated: false, completion: nil)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers)
        
        gobanPoint = GobanPoint(x: 20, y: 20)
        _ = goban.setStone(stone, atGobanPoint: gobanPoint, isUserInitiated: false, completion: nil)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers)
        
        gobanPoint = GobanPoint(x: 1, y: 1)
        _ = goban.setStone(stone, atGobanPoint: gobanPoint, isUserInitiated: false, completion: nil)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers + 1)
        
        gobanPoint = GobanPoint(x: 19, y: 19)
        _ = goban.setStone(stone, atGobanPoint: gobanPoint, isUserInitiated: false, completion: nil)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers + 2)
        
        gobanPoint = GobanPoint(x: 5, y: 2)
        _ = goban.setStone(stone, atGobanPoint: gobanPoint, isUserInitiated: false, completion: nil)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers + 3)
        
        gobanPoint = GobanPoint(x: 2, y: 15)
        _ = goban.setStone(stone, atGobanPoint: gobanPoint, isUserInitiated: false, completion: nil)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers + 4)
        
        gobanPoint = GobanPoint(x: 7, y: 7)
        _ = goban.setStone(stone, atGobanPoint: gobanPoint, isUserInitiated: false, completion: nil)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers + 5)
        
        goban.reload()
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers)

        gobanPoint = GobanPoint(x: 0, y: 15)
        _ = goban.setStone(stone, atGobanPoint: gobanPoint, isUserInitiated: false, completion: nil)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers)
        
        gobanPoint = GobanPoint(x: 15, y: 0)
        _ = goban.setStone(stone, atGobanPoint: gobanPoint, isUserInitiated: false, completion: nil)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers)
        
        gobanPoint = GobanPoint(x: 1, y: 19)
        _ = goban.setStone(stone, atGobanPoint: gobanPoint, isUserInitiated: false, completion: nil)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers + 1)

        gobanPoint = GobanPoint(x: 7, y: 12)
        _ = goban.setStone(stone, atGobanPoint: gobanPoint, isUserInitiated: false, completion: nil)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers + 2)

        gobanPoint = GobanPoint(x: 19, y: 10)
        _ = goban.setStone(stone, atGobanPoint: gobanPoint, isUserInitiated: false, completion: nil)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers + 3)
        
        gobanPoint = GobanPoint(x: -100, y: 200)
        _ = goban.setStone(stone, atGobanPoint: gobanPoint, isUserInitiated: false, completion: nil)
        XCTAssertEqual(goban.layer.sublayers?.count, initialNumberOfSublayers + 3)
    }
    
    func testInitWithSGFString() {
        var testSGFString: String = ""
        XCTAssertNil(GobanPoint(SGFString: testSGFString))
        
        testSGFString = "  "
        XCTAssertNil(GobanPoint(SGFString: testSGFString))
        
        testSGFString = "abc"
        XCTAssertNil(GobanPoint(SGFString: testSGFString))
        
        testSGFString = "12"
        XCTAssertNil(GobanPoint(SGFString: testSGFString))
        
        testSGFString = "aa"
        var point = GobanPoint(SGFString: testSGFString)
        XCTAssert(point?.x == 1)
        XCTAssert(point?.y == 1)
        
        testSGFString = "mm"
        point = GobanPoint(SGFString: testSGFString)
        XCTAssert(point?.x == 13)
        XCTAssert(point?.y == 13)
        
        testSGFString = "bf"
        point = GobanPoint(SGFString: testSGFString)
        XCTAssert(point?.x == 2)
        XCTAssert(point?.y == 6)
    }
    
    func testPointsFromCompressPoints() {
        var compressPoints = (Character("a"), Character("c"), Character("b"), Character("d"))
        var points = GobanPoint.pointsFromCompressPoints(compressPoints)
        var expectedPoints: Set<GobanPoint> = Set([(1, 3), (1, 4), (2, 3), (2, 4)].map({GobanPoint(x: $0.0, y: $0.1)}))
        XCTAssert(points! == expectedPoints, "")
        
        compressPoints = (Character("a"), Character("c"), Character("i"), Character("c"))
        points = GobanPoint.pointsFromCompressPoints(compressPoints)
        expectedPoints = Set((1...9).map{GobanPoint(x: $0, y: 3)})
        XCTAssert(points! == expectedPoints, "")
    }
}
