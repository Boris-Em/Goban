//
//  SGFParserCombinatorTests.swift
//  GobanSampleProject
//
//  Created by JohnGrif on 5/5/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import XCTest

class SGFParserCombinatorTests: XCParserTestBase {
    typealias SGFPC = SGFParserCombinator

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParsePropertyValueNumber() {
        let results = testParseString(SGFPC.propValueAsStringParser(), "[7]")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first!.0.asString, "7" )
    }

    func testParsePropertyValueMove() {
        let results = testParseString(SGFPC.propValueAsStringParser(), "[bd]")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first!.0.asString, "bd" )
    }

    func testParsePropertyValueEscapedBracket() {
        let results = testParseString(SGFPC.propValueAsStringParser(), "[[bd\\]\\\\]")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first!.0.asString, "[bd\\]\\\\" )
    }
    
    func testParseProperty() {
        let results = testParseString(SGFPC.propertyParser(), "W[bd]")
        XCTAssertResultsContains(results, satisfying: { $0.identifier == "W" } )
    }

    func testParseEmptyProperty() {
        let results = testParseString(SGFPC.propertyParser(), "W[]")
        XCTAssertResultsContains(results, satisfying: { $0.identifier == "W" } )
    }

    func testParseNode() {
        let results = testParseString(SGFPC.nodeParser(), ";W[bd]")
        XCTAssert(results.count != 0) // empty node & point, move, stone are the same
    }

    func testParseNodeMultipleProperties() {
        let results = testParseString(SGFPC.nodeParser(), ";FF[4]GM[1]SZ[19]")
        XCTAssertEqual(results.count, 1) // empty node & point, move, stone are the same
    }
    
    func testParseSequence() {
        let results = testParseString(SGFPC.sequenceParser(), ";W[bd]")
        XCTAssertEqual(results.count, 1) // empty node & point, move, stone are the same
    }

    func testParseSequenceMultipleNodes() {
        let results = testParseString(SGFPC.sequenceParser(), ";W[bd];B[ad]")
        XCTAssertEqual(results.count, 1)
    }

    func testParseGameTree() {
        let results = testParseString(SGFPC.gameTreeParser(), "(;W[bd];B[ad])")
        XCTAssertEqual(results.count, 1)
    }

    func testParseCollection() {
        let results = testParseString(SGFPC.gameTreeParser(), "(;W[bd])")
        XCTAssertEqual(results.count, 1)
    }

    func testParseMultipleGames() {
        let results = testParseString(SGFPC.collectionParser(), "(;W[bd])(;W[bd])")
        XCTAssertEqual(results.count, 1)
    }

    func testSequenceWithGame() {
        let results = testParseString(SGFPC.collectionParser(), "(;FF[4] (;B[pd]) )")
        XCTAssertEqual(results.count, 1)
    }

    func testParseNoVariationSample() {
        let noVariationSample = "(;FF[4]GM[1]SZ[19];B[aa];W[bb];B[cc];W[dd];B[ad];W[bd])"
        let results = testParseString(SGFPC.gameTreeParser(), noVariationSample)
        XCTAssertEqual(results.count, 1)
    }
    
    func testParsePoint() {
        let pointSample="ep"
        let results = testParseString(SGFPValueTypeParser.goPointParser(), pointSample)
        XCTAssertEqual(results.count, 1)
    }

    func testParseCompressedPoints() {
        let pointSample="pn:pq"
        let results = testParseString(SGFPValueTypeParser.goCompressedPointsParser(), pointSample)
        XCTAssertEqual(results.count, 1)
    }

    func testParsePointsListWithCompressedPoints() {
        let pointListSample=";AE[ep][fp][kn][lo][lq][pn:qr]"

        let results = testParseString(SGFPC.nodeParser(), pointListSample)
        XCTAssertEqual(results.count, 1)
        
        let node = results.first!.0 as SGFP.Node
        XCTAssertEqual(node.properties.count, 1)
        
        let property = node.properties.first!
        XCTAssertEqual(property.identifier, "AE")
        XCTAssertEqual(property.values.count, 6)
        
        let (upperLeftCol, upperLeftRow, lowerRightCol, lowerRightRow) = property.values.last!.toCompresedPoints()!
        XCTAssertEqual(upperLeftCol, "p")
        XCTAssertEqual(upperLeftRow, "n")
        XCTAssertEqual(lowerRightCol, "q")
        XCTAssertEqual(lowerRightRow, "r")
    }
}
