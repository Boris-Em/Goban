//
//  FunctionalParserTests.swift
//  GobanSampleProject
//
//  Created by John on 5/3/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import XCTest

class FunctionalParserTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // helpers
    
    func testParseString<Result>(parser: Parser<Character, Result>, _ testString: String) -> [(Result, ArraySlice<Character>)] {
        return Array(parser.parse(testString.slice))
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

    // tests
    
    func testCombineSequences() {
        let seqA = AnySequence([1,2,3])
        let seqB = AnySequence([4,5,6])
        let combinedTest = [1,2,3,4,5,6]
        
        let combined = seqA + seqB
        
        XCTAssertEqual(Array(combined), combinedTest)
    }

    func testCombineSequencesSecondPass() {
        let seqA = AnySequence([1,2,3])
        let seqB = AnySequence([4,5,6])
        let combinedTest = [1,2,3,4,5,6]
        
        let _ = seqA + seqB
        let combined2 = seqA + seqB
        
        XCTAssertEqual(Array(combined2), combinedTest)
    }
    
    func testParseSatisfying() {
        let charA: Character = "a"
        let parseA = parseSatisfying { $0 == charA }
        
        let result = testParseString(parseA, "abc")
        
        XCTAssertOnlyResult(result, equals: charA, remainder: "bc")
    }
    
    func testParseIsTokenSuccess() {
        let charA: Character = "a"
        
        let result = testParseString(parseIsToken(charA), "abc")
        
        XCTAssertOnlyResult(result, equals: charA)
    }

    func testParseIsTokenFailure() {
        let charA: Character = "a"
        
        let result = testParseString(parseIsToken(charA), "b")
        
        XCTAssertEmptyResult(result)
    }
    
    func testChooseOperator() {
        let chooseParser = parseIsCharacter("a") <|> parseIsCharacter("b")
        
        XCTAssertOnlyResult(testParseString(chooseParser, "abc"), equals: "a", remainder: "bc")
        XCTAssertOnlyResult(testParseString(chooseParser, "bcd"), equals: "b", remainder: "cd")
        XCTAssertEmptyResult(testParseString(chooseParser, "cde"))
    }
    
    func testSequence() {
        let sequenceParser = sequence(parseIsCharacter("a"), parseIsCharacter("b"))
        
        let result: [((Character,Character), ArraySlice<Character>)] = testParseString(sequenceParser, "abc")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first!.0.0, "a")
        XCTAssertEqual(result.first!.0.1, "b")
        XCTAssertEqual(result.first!.1, "c".slice)
    }

    func testSequenceFailure() {
        let sequenceParser = sequence(parseIsCharacter("a"), parseIsCharacter("b"))
        
        let result: [((Character,Character), ArraySlice<Character>)] = testParseString(sequenceParser, "acd")
        XCTAssertEmptyResult(result)
    }
    
    func testCombinatorOperator() {
        let toInteger2 = { (a:Character) -> Character -> Int in
            return { b in
                let combinedString = String(a) + String(b)
                return Int(combinedString)!
            }
        }
        
        let combinatorparser = pure(toInteger2) <*> parseIsCharacter("3") <*> parseIsCharacter("3")
        
        XCTAssertOnlyResult(testParseString(combinatorparser, "33"), equals: 33, remainder: "")
    }

    func testCombineWithCurryChoice() {
        let aOrB = parseIsCharacter("a") <|> parseIsCharacter("b")
        let parser = pure(curry { String([$0,$1,$2]) }) <*> aOrB <*> aOrB <*> parseIsCharacter("c")
        
        XCTAssertOnlyResult(testParseString(parser, "abc"), equals: "abc", remainder: "")
        XCTAssertOnlyResult(testParseString(parser, "bbc"), equals: "bbc", remainder: "")
    }

    func testCombineWithCurryChoiceFailure() {
        let aOrB = parseIsCharacter("a") <|> parseIsCharacter("b")
        let parser = pure(curry { String([$0,$1,$2]) }) <*> aOrB <*> aOrB <*> parseIsCharacter("c")
        
        XCTAssertEmptyResult(testParseString(parser, "cbc"))
    }
    
    let isDecimalDigit = isCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet())
    
    func testIsCharacterFromSet() {
        XCTAssertOnlyResult(testParseString(isDecimalDigit, "3"), equals: "3")
    }

    func testIsCharacterFromSetFailure() {
        XCTAssertEmptyResult(testParseString(isDecimalDigit, "a"))
    }
    
    func testZeroOrMore_Zero() {
        let zeroOrMoreDecimalDigits = zeroOrMore(isDecimalDigit)
        
        let result = testParseString(zeroOrMoreDecimalDigits, "abc")
        XCTAssertEqual(result.first!.0,[])
    }

    func testZeroOrMore_More() {
        let zeroOrMoreDecimalDigits = zeroOrMore(isDecimalDigit)
        let result = testParseString(zeroOrMoreDecimalDigits, "1234")
        XCTAssertEqual(result.first!.0,["1","2","3","4"])
    }
    
    func testOneOrMore_More() {
        let result = testParseString(oneOrMore(isDecimalDigit), "1234")
        XCTAssertEqual(result.first!.0,["1","2","3","4"])
    }

    func testOneOrMore_Zero_Fails() {
        let result = testParseString(oneOrMore(isDecimalDigit), "abcd")
        XCTAssertEmptyResult(result)
    }

    func testIntFromChars_OneOrMore() {
        let results = testParseString(pure(intFromChars) <*> oneOrMore(isDecimalDigit), "1234")
        XCTAssertFirstResult(results, equals:1234)
    }

    func testPureCombinatorOperator() {
        let results = testParseString(intFromChars </> oneOrMore(isDecimalDigit), "1234")
        XCTAssertFirstResult(results, equals:1234)
    }
    
    func testParseMultiplication() {
        let number = intFromChars </> oneOrMore(isDecimalDigit)
        let multiplicationParser = curry(*) </> number <* parseIsCharacter("*") <*> number
        
        XCTAssertFirstResult(testParseString(multiplicationParser, "3*15"), equals: 45)
    }


}
