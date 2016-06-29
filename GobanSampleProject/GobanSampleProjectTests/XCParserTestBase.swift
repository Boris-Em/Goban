//
//  ParserTests.swift
//  GobanSampleProject
//
//  Created by JohnGrif on 5/5/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import XCTest

class XCParserTestBase: XCTestCase {
    
    func testParseString<Result>(parser: CharacterParser<Result>, _ testString: String) -> [(Result, ArraySlice<Character>)] {
        return Array(parser.parse(testString.slice))
    }

    func testParseStringResultsOnly<Result>(parser: CharacterParser<Result>, _ testString: String) -> [Result] {
        return dropRemainders(testParseString(parser, testString))
    }

    func dropRemainders<Result>(results: [(Result, ArraySlice<Character>)]) -> [Result] {
        return results.map { $0.0 }
    }
    
    func firstResult<Result>(results: [(Result, ArraySlice<Character>)]) -> Result {
        return dropRemainders(results).first!
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
    
    func XCTAssertResultsContains<Result>(results: [(Result, ArraySlice<Character>)], satisfying satisfies: (Result) -> Bool) {
        let resultsOnly: [Result] = dropRemainders(results)
        XCTAssert(resultsOnly.contains(satisfies))
    }

    func XCTAssertResultsContains<Result: Equatable>(results: [(Result, ArraySlice<Character>)], result: Result) {
        let resultsOnly: [Result] = dropRemainders(results)
        XCTAssert(resultsOnly.contains { $0 == result } )
    }

}
