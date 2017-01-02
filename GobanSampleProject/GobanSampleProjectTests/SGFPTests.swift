//
//  SGFPTests.swift
//  GobanSampleProject
//
//  Created by Bobo on 1/2/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import XCTest

class SGFPTests: XCParserTestBase {
    
    typealias SGFPC = SGFParserCombinator
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testNodeForPath() {
        let testString = contentsOfFileWithName("Variations-Tests.sgf")!
        let results = testParseString(SGFPC.collectionParser(), testString)
        XCTAssertEqual(1, results.count)
        
        let game: SGFP.GameTree? = results.first?.0.games.first
        XCTAssertNotNil(game)
        
        var node = game?.node(forPath: [0])
        XCTAssertEqual(node?.properties.first?.identifier, "B")
        XCTAssertEqual(node?.properties.first?.values.first?.asString, "aa")
        
        node = game?.node(forPath: [1])
        XCTAssertEqual(node?.properties.first?.identifier, "W")
        XCTAssertEqual(node?.properties.first?.values.first?.asString, "bb")
        
        node = game?.node(forPath: [0,0])
        XCTAssertEqual(node?.properties.first?.identifier, "B")
        XCTAssertEqual(node?.properties.first?.values.first?.asString, "cc")

        node = game?.node(forPath: [1,0])
        XCTAssertEqual(node?.properties.first?.identifier, "B")
        XCTAssertEqual(node?.properties.first?.values.first?.asString, "hh")

        node = game?.node(forPath: [2,0])
        XCTAssertEqual(node?.properties.first?.identifier, "B")
        XCTAssertEqual(node?.properties.first?.values.first?.asString, "gg")
        
        node = game?.node(forPath: [0,1])
        XCTAssertEqual(node?.properties.first?.identifier, "W")
        XCTAssertEqual(node?.properties.first?.values.first?.asString, "dd")
        
        node = game?.node(forPath: [1,1])
        XCTAssertEqual(node?.properties.first?.identifier, "W")
        XCTAssertEqual(node?.properties.first?.values.first?.asString, "hg")

        node = game?.node(forPath: [2,1])
        XCTAssertEqual(node?.properties.first?.identifier, "W")
        XCTAssertEqual(node?.properties.first?.values.first?.asString, "gh")
        
        node = game?.node(forPath: [0,2])
        XCTAssertEqual(node?.properties.first?.identifier, "B")
        XCTAssertEqual(node?.properties.first?.values.first?.asString, "ad")

        node = game?.node(forPath: [2,2])
        XCTAssertEqual(node?.properties.first?.identifier, "B")
        XCTAssertEqual(node?.properties.first?.values.first?.asString, "hh")

        node = game?.node(forPath: [0,3])
        XCTAssertEqual(node?.properties.first?.identifier, "W")
        XCTAssertEqual(node?.properties.first?.values.first?.asString, "bd")

        node = game?.node(forPath: [2,0,0])
        XCTAssertEqual(node?.properties.first?.identifier, "W")
        XCTAssertEqual(node?.properties.first?.values.first?.asString, "hg")
        
        node = game?.node(forPath: [2,1,0])
        XCTAssertEqual(node?.properties.first?.identifier, "W")
        XCTAssertEqual(node?.properties.first?.values.first?.asString, "kl")
        
        node = game?.node(forPath: [2,0,1])
        XCTAssertEqual(node?.properties.first?.identifier, "B")
        XCTAssertEqual(node?.properties.first?.values.first?.asString, "kk")
        
        node = game?.node(forPath: [2])
        XCTAssertNil(node)
        
        node = game?.node(forPath: [3,0])
        XCTAssertNil(node)
        
        node = game?.node(forPath: [1,2])
        XCTAssertNil(node)
        
        node = game?.node(forPath: [])
        XCTAssertNil(node)
    }
    
}
