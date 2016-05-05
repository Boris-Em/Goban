//
//  SGFParser.swift
//  GobanSampleProject
//
//  Created by John on 5/4/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import Foundation


class SGFParserC {
    typealias Token = Character
    
    struct SGFCollection { let games: [SGFGameTree] }
    struct SGFGameTree { let sequence: SGFSequence }
    struct SGFSequence { let nodes: [SGFNode] }
    struct SGFNode { let properties: [SGFProperty] }
    struct SGFProperty { let identifier: SGFPropIdent; let values: [SGFPropValue] }
    struct SGFPropIdent { let name: [SGFUcLetter] }
    typealias SGFUcLetter = Character
    struct SGFPropValue { let value: SGFCValueType }
    
    let noVariationSample = "(;FF[4]GM[1]SZ[19];B[aa];W[bb];B[cc];W[dd];B[ad];W[bd])"

    
    let valueTypeParser = SGFCValueTypeParser()
    

    func parseCollection() -> Parser<Character, SGFCollection> {
        return { SGFCollection(games: $0) } </> oneOrMore(parseGameTree())
    }

    func parseGameTree() -> Parser<Character, SGFGameTree> {
        return { SGFGameTree(sequence: $0) } </> (parseIsCharacter("(") *> parseSequence() <* parseIsCharacter(")"))
    }

    func parseSequence() -> Parser<Character, SGFSequence> {
        return { SGFSequence(nodes: $0) } </> oneOrMore(parseNode())
    }
    
    func parseNode() -> Parser<Character, SGFNode> {
        return { SGFNode(properties: $0) } </> (parseIsCharacter(";") *> zeroOrMore(parseProperty()))
    }

    func parseProperty() -> Parser<Character, SGFProperty> {
        return curry { SGFProperty(identifier: $0, values: $1) } </> parsePropertyIdent() <*> oneOrMore(parsePropertyValue())
    }

    func parsePropertyIdent() -> Parser<Character, SGFPropIdent> {
        return { SGFPropIdent(name: $0) } </> oneOrMore(parseCharacterFromSet(NSCharacterSet.uppercaseLetterCharacterSet()))
    }
    
    func parsePropertyValue() -> Parser<Character,SGFPropValue> {
        return { SGFPropValue(value: $0) } </> (parseIsCharacter("[") *> valueTypeParser.parseCValue() <* parseIsCharacter("]"))
    }


}

