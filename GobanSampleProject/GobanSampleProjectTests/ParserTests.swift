//
//  ParserTests.swift
//  GobanSampleProject
//
//  Created by JohnGrif on 5/5/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import XCTest

class XCParserTestBase: XCTestCase {
    
    func testParseString<Result>(parser: Parser<Character, Result>, _ testString: String) -> [(Result, ArraySlice<Character>)] {
        return Array(parser.parse(testString.slice))
    }
    
    func firstResult<Result>(results: [(Result, ArraySlice<Character>)]) -> Result {
        return results.first!.0
    }
    
    func XCTAssertOnlyResult<Result: Equatable>(results: [(Result, ArraySlice<Character>)], equals testResult: Result) {
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first!.0, testResult)
    }
    
    func XCTAssertFirstResult<Result: Equatable>(results: [(Result, ArraySlice<Character>)], equals testResult: Result) {
        XCTAssertEqual(results.first!.0, testResult)
    }
    
    func XCTAssertOnlyResult<Result: Equatable>(results: [(Result, ArraySlice<Character>)], equals testResult: Result, remainder: String) {
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first!.0, testResult)
        XCTAssertEqual(results.first!.1, remainder.slice)
    }
    
    func XCTAssertEmptyResult<Result>(result: [(Result, ArraySlice<Character>)]) {
        XCTAssertEqual(result.count, 0)
    }
    
}
