//
//  SGF.ValueTypeParserTests.swift
//  GobanSampleProject
//
//  Created by JohnGrif on 5/5/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import XCTest

class SGFValueTypeParserTests: XCParserTestBase {
    var valueParser: SGFValueTypeParser!
    
    override func setUp() {
        super.setUp()

        valueParser = SGFValueTypeParser()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParseDigits() {
        let results = testParseString(valueParser.parseDigits, "123")
        XCTAssertEqual(results.first!.0, ["1","2","3"])
    }
    
    func testParseNumber() {
        let results = testParseString(valueParser.parseNumber(), "123abc")
        guard case SGFP.ValueType.Number(123) = firstResult(results) else {
            return  XCTAssertTrue(false)
        }
    }

    func testParseColor() {
        for color in ["B","W"] {
            let results = testParseString(valueParser.parseColor(), color)
            guard case SGFP.ValueType.Color(color) = firstResult(results) else {
                return  XCTAssertTrue(false)
            }
        }
    }

    func testParseNonColor() {
        let results = testParseString(valueParser.parseColor(), "X")
        XCTAssertEmptyResult(results)
    }

    func testParseReal() {
        let results = testParseString(valueParser.parseReal(), "123.456")
        guard case SGFP.ValueType.Real(123.456) = firstResult(results) else {
            return  XCTAssertTrue(false)
        }
    }
    
    func testParseSimpleText() {
        let newLineText = "New\nLine"
        let results = testParseString(valueParser.parseSimpleText(), newLineText)
        guard case SGFP.ValueType.SimpleText(let text) = firstResult(results) where text == newLineText else {
            return  XCTAssertTrue(false)
        }
    }
    
    func testParseCValue() {
        let values = ["1234", "12.34", "1", "B", "W", "The quick brown", "New\nLine"]
        for v in values {
            let results = testParseString(valueParser.parseCValue(), v)
            XCTAssert(results.count != 0)
        }
    }
    

}
