//
//  SGFParserCombinatorTests.swift
//  GobanSampleProject
//
//  Created by JohnGrif on 5/5/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import XCTest

class SGFParserCombinatorTests: XCParserTestBase {
    let parser = SGFParserCombinator()

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
        XCTAssertResultsContains(results, satisfying: { $0.name == "W" } )
    }

    func testParsePropertyValueNumber() {
        let results = testParseString(parser.parsePropertyValueChars(), "[7]")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first!.0.valueString, "7" )
    }

    func testParsePropertyValueMove() {
        let results = testParseString(parser.parsePropertyValueChars(), "[bd]")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first!.0.valueString, "bd" )
    }

    func testParsePropertyValueEscapedBracket() {
        let results = testParseString(parser.parsePropertyValueChars(), "[[bd\\]\\\\]")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first!.0.valueString, "[bd\\]\\\\" )
    }
    
    func testParseProperty() {
        let results = testParseString(parser.parseProperty(), "W[bd]")
        XCTAssertResultsContains(results, satisfying: { $0.identifier.name == "W" } )
    }

    func testParseEmptyProperty() {
        let results = testParseString(parser.parseProperty(), "W[]")
        XCTAssertResultsContains(results, satisfying: { $0.identifier.name == "W" } )
    }

    func testParseNode() {
        let results = testParseString(parser.parseNode(), ";W[bd]")
        XCTAssert(results.count != 0) // empty node & point, move, stone are the same
    }

    func testParseNodeMultipleProperties() {
        let results = testParseString(parser.parseNode(), ";FF[4]GM[1]SZ[19]")
        XCTAssertEqual(results.count, 1) // empty node & point, move, stone are the same
    }
    
    func testParseSequence() {
        let results = testParseString(parser.parseSequence(), ";W[bd]")
        XCTAssertEqual(results.count, 1) // empty node & point, move, stone are the same
    }

    func testParseSequenceMultipleNodes() {
        let results = testParseString(parser.parseSequence(), ";W[bd];B[ad]")
        XCTAssertEqual(results.count, 1)
    }

    func testParseGameTree() {
        let results = testParseString(parser.parseGameTree(), "(;W[bd];B[ad])")
        XCTAssertEqual(results.count, 1)
    }

    func testParseCollection() {
        let results = testParseString(parser.parseGameTree(), "(;W[bd])")
        XCTAssertEqual(results.count, 1)
    }

    func testParseMultipleGames() {
        let results = testParseString(parser.parseCollection(), "(;W[bd])(;W[bd])")
        XCTAssertEqual(results.count, 1)
    }

    func testSequenceWithGame() {
        let results = testParseString(parser.parseCollection(), "(;FF[4] (;B[pd]) )")
        XCTAssertEqual(results.count, 1)
    }

    
    func testParseNoVariationSample() {
        let noVariationSample = "(;FF[4]GM[1]SZ[19];B[aa];W[bb];B[cc];W[dd];B[ad];W[bd])"
        let results = testParseString(parser.parseGameTree(), noVariationSample)
        XCTAssertEqual(results.count, 1)
    }
    
}
