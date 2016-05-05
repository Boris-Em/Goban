//
//  SGFCValueTypeParserTests.swift
//  GobanSampleProject
//
//  Created by JohnGrif on 5/5/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import XCTest

class SGFCValueTypeParserTests: XCParserTestBase {
    var valueParser: SGFCValueTypeParser!
    
    override func setUp() {
        super.setUp()

        valueParser = SGFCValueTypeParser()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParseDigits() {
        let results = testParseString(valueParser.parseDigits, "123")
        XCTAssertEqual(results.first!.0, ["1","2","3"])
    }

    func testParseUcLetter() {
        let results = testParseString(valueParser.parseUcLetter, "ABc")
        XCTAssertFirstResult(results, equals: "A")
    }

    
    func testParseNumber() {
        let results = testParseString(valueParser.parseNumber(), "123abc")
        guard case SGFCValueType.Number(123) = firstResult(results) else {
            return  XCTAssertTrue(false)
        }
    }

    func testParseColor() {
        for color in ["B","W"] {
            let results = testParseString(valueParser.parseColor(), color)
            guard case SGFCValueType.Color(color) = firstResult(results) else {
                return  XCTAssertTrue(false)
            }
        }
    }

    func testParseNonColor() {
        let results = testParseString(valueParser.parseColor(), "X")
        XCTAssertEmptyResult(results)
    }

    func testParseCValue() {
        let values = ["1234", "12.34", "1", "B", "W"]
        for v in values {
            let results = testParseString(valueParser.parseCValue(), v)
            XCTAssert(results.count != 0)
        }
    }
}
