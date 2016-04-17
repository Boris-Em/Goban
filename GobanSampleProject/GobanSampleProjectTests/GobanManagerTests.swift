//
//  GobanManagerTests.swift
//  GobanSampleProject
//
//  Created by Bobo on 4/16/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import XCTest
@testable import GobanSampleProject

class GobanManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    let initialNumberOfSublayers = 2
    
    func testAddNewStoneAtGobanPoint() {
        let gobanView = GobanView(size: GobanSize(width: 19, height: 19), frame: CGRectZero)
        gobanView.reload()
        let gobanManager = GobanManager(gobanView: gobanView)
        
        // Stone outside of goban
        var gobanPoint = GobanPoint(x: 0, y: 0)
        gobanManager.addNewStoneAtGobanPoint(gobanPoint)
        XCTAssertEqual(gobanManager.stoneHistory.count, 0)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers)
        
        // Stone outside of goban
        gobanPoint = GobanPoint(x: 20, y: 20)
        gobanManager.addNewStoneAtGobanPoint(gobanPoint)
        XCTAssertEqual(gobanManager.stoneHistory.count, 0)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers)
        
        // Correct test -  First stone is black
        gobanPoint = GobanPoint(x: 2, y: 7)
        gobanManager.addNewStoneAtGobanPoint(gobanPoint)
        XCTAssertEqual(gobanManager.stoneHistory.count, 1)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers + gobanManager.stoneHistory.count)
        
        var lastStone = gobanManager.stoneHistory.last
        XCTAssertEqual(lastStone?.stoneColor, .Black)
        
        // Stone already exists at goban point
        gobanPoint = GobanPoint(x: 2, y: 7)
        gobanManager.addNewStoneAtGobanPoint(gobanPoint)
        XCTAssertEqual(gobanManager.stoneHistory.count, 1)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers + gobanManager.stoneHistory.count)
        
        lastStone = gobanManager.stoneHistory.last
        XCTAssertEqual(lastStone?.stoneColor, .Black)
        
        // Correct test - Second stone is white
        gobanPoint = GobanPoint(x: 3, y: 7)
        gobanManager.addNewStoneAtGobanPoint(gobanPoint)
        XCTAssertEqual(gobanManager.stoneHistory.count, 2)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers + gobanManager.stoneHistory.count)
        
        lastStone = gobanManager.stoneHistory.last
        XCTAssertEqual(lastStone?.stoneColor, .White)
        
        // Correct test - Third stone is black
        gobanPoint = GobanPoint(x: 19, y: 19)
        gobanManager.addNewStoneAtGobanPoint(gobanPoint)
        XCTAssertEqual(gobanManager.stoneHistory.count, 3)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers + gobanManager.stoneHistory.count)
        
        lastStone = gobanManager.stoneHistory.last
        XCTAssertEqual(lastStone?.stoneColor, .Black)
        
        // Stone outside of goban
        gobanPoint = GobanPoint(x: 20, y: 19)
        gobanManager.addNewStoneAtGobanPoint(gobanPoint)
        XCTAssertEqual(gobanManager.stoneHistory.count, 3)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers + gobanManager.stoneHistory.count)
        
        lastStone = gobanManager.stoneHistory.last
        XCTAssertEqual(lastStone?.stoneColor, .Black)
    }
    
    func testAddTemporaryStoneAtGobanPoint() {
        let gobanView = GobanView(size: GobanSize(width: 19, height: 19), frame: CGRectZero)
        gobanView.reload()
        let gobanManager = GobanManager(gobanView: gobanView)
        
        // Adding a temporary stone shouldn't increase the stone history count
        let gobanPoint = GobanPoint(x: 0, y: 0)
        gobanManager.addTemporaryStoneAtGobanPoint(gobanPoint)
        
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers)
        XCTAssertEqual(gobanManager.stoneHistory.count, 0)
    }
    
    func testRemoveStone() {
        let gobanView = GobanView(size: GobanSize(width: 19, height: 19), frame: CGRectZero)
        gobanView.reload()
        let gobanManager = GobanManager(gobanView: gobanView)
        
        // Add new stone and remove it from GobanView and stone history
        var gobanPoint = GobanPoint(x: 2, y: 7)
        gobanManager.addNewStoneAtGobanPoint(gobanPoint)
        XCTAssertEqual(gobanManager.stoneHistory.count, 1)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers + gobanManager.stoneHistory.count)
        var lastStone = gobanManager.stoneHistory.last
        gobanManager.removeStone(lastStone!, removeFromHistory: true, animated: false)
        XCTAssertEqual(gobanManager.stoneHistory.count, 0)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers + gobanManager.stoneHistory.count)

        // Add new stone and remove it from only from stone history
        gobanPoint = GobanPoint(x: 2, y: 7)
        gobanManager.addNewStoneAtGobanPoint(gobanPoint)
        XCTAssertEqual(gobanManager.stoneHistory.count, 1)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers + gobanManager.stoneHistory.count)
        lastStone = gobanManager.stoneHistory.last
        gobanManager.removeStone(lastStone!, removeFromHistory: false, animated: false)
        XCTAssertEqual(gobanManager.stoneHistory.count, 1)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers)
        
        // Remove all stones
        gobanManager.removeAllStonesAnimated(false)
        XCTAssertEqual(gobanManager.stoneHistory.count, 0)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers)
        
        // Add two stones and remove the first one from GoabanView and stone history 
        gobanPoint = GobanPoint(x: 2, y: 7)
        gobanManager.addNewStoneAtGobanPoint(gobanPoint)
        XCTAssertEqual(gobanManager.stoneHistory.count, 1)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers + gobanManager.stoneHistory.count)
        
        gobanPoint = GobanPoint(x: 4, y: 10)
        gobanManager.addNewStoneAtGobanPoint(gobanPoint)
        XCTAssertEqual(gobanManager.stoneHistory.count, 2)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers + gobanManager.stoneHistory.count)
        
        let firstStone = gobanManager.stoneHistory.first
        gobanManager.removeStone(firstStone!, removeFromHistory: true, animated: false)
        XCTAssertEqual(gobanManager.stoneHistory.count, 1)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers + gobanManager.stoneHistory.count)
        
        // Remove all stones
        gobanManager.removeAllStonesAnimated(false)
        XCTAssertEqual(gobanManager.stoneHistory.count, 0)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers)
        
        // Try removing stone that is not on the board
        gobanPoint = GobanPoint(x: 2, y: 7)
        gobanManager.addNewStoneAtGobanPoint(gobanPoint)
        XCTAssertEqual(gobanManager.stoneHistory.count, 1)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers + gobanManager.stoneHistory.count)
        let nonExistingStone = StoneModel(stoneColor: .Black, disabled: true, layer: CAShapeLayer(), gobanPoint: GobanPoint(x: 2, y: 7))
        gobanManager.removeStone(nonExistingStone, removeFromHistory: true, animated: false)
        XCTAssertEqual(gobanManager.stoneHistory.count, 1)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers + gobanManager.stoneHistory.count)
    }
    
    func testRemoveStoneAtGobanPoint() {
        let gobanView = GobanView(size: GobanSize(width: 19, height: 19), frame: CGRectZero)
        gobanView.reload()
        let gobanManager = GobanManager(gobanView: gobanView)
        
        // Add new stone and remove it from GobanView and stone history
        var gobanPoint = GobanPoint(x: 2, y: 7)
        gobanManager.addNewStoneAtGobanPoint(gobanPoint)
        XCTAssertEqual(gobanManager.stoneHistory.count, 1)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers + gobanManager.stoneHistory.count)
        gobanManager.removeStoneAtGobanPoint(gobanPoint, removeFromHistory: true, animated: false)
        XCTAssertEqual(gobanManager.stoneHistory.count, 0)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers + gobanManager.stoneHistory.count)
        
        // Add new stone and remove it from only from stone history
        gobanPoint = GobanPoint(x: 2, y: 7)
        gobanManager.addNewStoneAtGobanPoint(gobanPoint)
        XCTAssertEqual(gobanManager.stoneHistory.count, 1)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers + gobanManager.stoneHistory.count)
        gobanManager.removeStoneAtGobanPoint(gobanPoint, removeFromHistory: false, animated: false)
        XCTAssertEqual(gobanManager.stoneHistory.count, 1)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers)
        
        // Remove all stones
        gobanManager.removeAllStonesAnimated(false)
        XCTAssertEqual(gobanManager.stoneHistory.count, 0)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers)
        
        // Add two stones and remove the first one from GoabanView and stone history
        gobanPoint = GobanPoint(x: 2, y: 7)
        gobanManager.addNewStoneAtGobanPoint(gobanPoint)
        XCTAssertEqual(gobanManager.stoneHistory.count, 1)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers + gobanManager.stoneHistory.count)
        
        gobanPoint = GobanPoint(x: 4, y: 10)
        gobanManager.addNewStoneAtGobanPoint(gobanPoint)
        XCTAssertEqual(gobanManager.stoneHistory.count, 2)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers + gobanManager.stoneHistory.count)
        
        gobanManager.removeStoneAtGobanPoint(gobanPoint, removeFromHistory: true, animated: false)
        XCTAssertEqual(gobanManager.stoneHistory.count, 1)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers + gobanManager.stoneHistory.count)
        
        // Remove all stones
        gobanManager.removeAllStonesAnimated(false)
        XCTAssertEqual(gobanManager.stoneHistory.count, 0)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers)
        
        // Try removing stone that doesn't exist
        gobanPoint = GobanPoint(x: 2, y: 7)
        gobanManager.addNewStoneAtGobanPoint(gobanPoint)
        XCTAssertEqual(gobanManager.stoneHistory.count, 1)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers + gobanManager.stoneHistory.count)
        
        gobanPoint = GobanPoint(x: 3, y: 14)
        gobanManager.removeStoneAtGobanPoint(gobanPoint, removeFromHistory: true, animated: false)
        XCTAssertEqual(gobanManager.stoneHistory.count, 1)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers + gobanManager.stoneHistory.count)
    }
    
    func testRemoveLastStoneAnimated() {
        let gobanView = GobanView(size: GobanSize(width: 19, height: 19), frame: CGRectZero)
        gobanView.reload()
        let gobanManager = GobanManager(gobanView: gobanView)
        
        // Add new stone and remove it from GobanView and stone history
        let gobanPoint = GobanPoint(x: 2, y: 7)
        gobanManager.addNewStoneAtGobanPoint(gobanPoint)
        XCTAssertEqual(gobanManager.stoneHistory.count, 1)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers + gobanManager.stoneHistory.count)
        gobanManager.removeLastStoneAnimated(false)
        XCTAssertEqual(gobanManager.stoneHistory.count, 0)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers + gobanManager.stoneHistory.count)
    }
    
    func testRemoveAllStonesAnimated() {
        let gobanView = GobanView(size: GobanSize(width: 19, height: 19), frame: CGRectZero)
        gobanView.reload()
        let gobanManager = GobanManager(gobanView: gobanView)
        
        // Add two stones and remove them all
        var gobanPoint = GobanPoint(x: 2, y: 2)
        gobanManager.addNewStoneAtGobanPoint(gobanPoint)
        gobanPoint = GobanPoint(x: 5, y: 10)
        gobanManager.addNewStoneAtGobanPoint(gobanPoint)
        XCTAssertEqual(gobanManager.stoneHistory.count, 2)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers + gobanManager.stoneHistory.count)

        gobanManager.removeAllStonesAnimated(false)
        XCTAssertEqual(gobanManager.stoneHistory.count, 0)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers)
    }
    
    func testStoneAtGobanPoint() {
        let gobanView = GobanView(size: GobanSize(width: 19, height: 19), frame: CGRectZero)
        gobanView.reload()
        let gobanManager = GobanManager(gobanView: gobanView)
        
        // Add stone and retrieve it
        var gobanPoint = GobanPoint(x: 2, y: 2)
        gobanManager.addNewStoneAtGobanPoint(gobanPoint)
        XCTAssertEqual(gobanManager.stoneHistory.count, 1)
        XCTAssertEqual(gobanView.layer.sublayers?.count, initialNumberOfSublayers + gobanManager.stoneHistory.count)
        
        let stone = gobanManager.stoneAtGobanPoint(gobanPoint)
        XCTAssertEqual(stone?.stoneColor, .Black)
        XCTAssertFalse(stone!.disabled)
        XCTAssertNotNil(stone?.layer)
        XCTAssertEqual(stone?.gobanPoint, gobanPoint)
        XCTAssertNotNil(stone?.hashValue)
        
        // Try retrieving stone that doesn't exists
        gobanPoint = GobanPoint(x: 5, y: 10)
        XCTAssertNil(gobanManager.stoneAtGobanPoint(gobanPoint))
    }
}
