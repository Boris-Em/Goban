//
//  SGFParserCTests.swift
//  GobanSampleProject
//
//  Created by JohnGrif on 5/5/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import XCTest

class SGFParserCTests: XCParserTestBase {
    let noVariationSample = "(;FF[4]GM[1]SZ[19];B[aa];W[bb];B[cc];W[dd];B[ad];W[bd])"
    let parser = SGFParserC()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testParsePropertyIdent() {
        let results = testParseString(parser.parsePropertyIdent(), "W")
        XCTAssert(results.count == 1)
    }

    func testParsePropertyValueNumber() {
        let results = testParseString(parser.parsePropertyValue(), "[7]")
        XCTAssert(results.count == 1)
    }

    func testParsePropertyValueMove() {
        let results = testParseString(parser.parsePropertyValue(), "[bd]")
        XCTAssert(results.count == 3) // point, move, stone are the same
    }

    func testParseProperty() {
        let results = testParseString(parser.parseProperty(), "W[bd]")
        XCTAssert(results.count == 3) // point, move, stone are the same
    }

    func testParseNode() {
        let results = testParseString(parser.parseNode(), ";W[bd]")
        XCTAssert(results.count == 4) // empty node & point, move, stone are the same
    }

    func testParseNodeMultipleProperties() {
        let results = testParseString(parser.parseNode(), ";FF[4]GM[1]SZ[19]")
        XCTAssert(results.count == 6) // empty node & point, move, stone are the same
    }
    
    func testParseSequence() {
        let results = testParseString(parser.parseSequence(), ";W[bd]")
        XCTAssert(results.count == 4) // empty node & point, move, stone are the same
    }

    func testParseSequenceMultipleNodes() {
        let results = testParseString(parser.parseSequence(), ";W[bd];B[ad]")
        XCTAssert(results.count == 16)
    }

    func testParseGameTree() {
        let results = testParseString(parser.parseGameTree(), "(;W[bd];B[ad])")
        XCTAssert(results.count == 9)
    }

    func testParseCollection() {
        let results = testParseString(parser.parseGameTree(), "(;W[bd])")
        XCTAssert(results.count == 3)
    }

    func testParseMultipleGames() {
        let results = testParseString(parser.parseGameTree(), "(;W[bd])(;W[bd])")
        XCTAssert(results.count == 3)
    }
    
}
