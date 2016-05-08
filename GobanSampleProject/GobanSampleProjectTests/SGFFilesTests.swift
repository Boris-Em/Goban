//
//  SGFFilesTests.swift
//  GobanSampleProject
//
//  Created by John on 5/7/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import XCTest

class SGFFilesTests: XCParserTestBase {
    func contentsOfFileWithName(name: String) -> String?  {
        let bundle = NSBundle(forClass: self.dynamicType)
        guard let path = bundle.pathForResource(name, ofType: nil) else {
            return nil
        }
        return try! String(contentsOfFile: path)
    }
    var parser: SGFParserCombinator!
    
    override func setUp() {
        super.setUp()
        
        parser = SGFParserCombinator()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testHeader() {
        let testString = "(;GM[1])"
        let results = testParseString(parser.parseCollection(), testString)
        XCTAssertEqual(1, results.count)
    }

    func testLeeSodolHeader() {
        let testString = contentsOfFileWithName("LeeSedolHeader.sgf")!
        let results = testParseString(parser.parseCollection(), testString)
        XCTAssertEqual(1, results.count)
    }
    
    func testLeeSedol() {
        let testString = contentsOfFileWithName("Lee-Sedol-vs-AlphaGo-20160309.sgf")!
        let results = testParseString(parser.parseCollection(), testString)
        XCTAssertEqual(1, results.count)
    }

    func testFF4ExampleSimplifiedFile() {
        let testString = contentsOfFileWithName("ff4_ex_simplified.sgf")!
        let results = testParseString(parser.parseCollection(), testString)
        XCTAssertEqual(1, results.count)
    }

    func testFF4ExampleFile() {
        let testString = contentsOfFileWithName("ff4_ex.sgf")!
        let results = testParseString(parser.parseCollection(), testString)
        XCTAssertEqual(1, results.count)
    }

}
