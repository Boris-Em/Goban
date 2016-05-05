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
    
    struct SGFCollection: CustomStringConvertible {
        let games: [SGFGameTree]
        var description: String { return "Collection: \(games.map{$0.description}.joinWithSeparator("\n"))" }
    }
    struct SGFGameTree: CustomStringConvertible {
        let sequence: SGFSequence
        var description: String { return "GameTree: \(sequence.description)" }
    }
    struct SGFSequence: CustomStringConvertible {
        let nodes: [SGFNode]
        var description: String { return "Sequence: \(nodes.map{$0.description}.joinWithSeparator("\n"))" }
    }
    struct SGFNode: CustomStringConvertible {
        let properties: [SGFProperty]
        var description: String { return "Node: \(properties.map{$0.description}.joinWithSeparator(""))" }
    }
    struct SGFProperty: CustomStringConvertible {
        let identifier: SGFPropIdent;
        let values: [SGFPropValue]
        var description: String { return "\(identifier)\(values.map{"[\($0)]"}.joinWithSeparator(""))" }
    }
    struct SGFPropIdent: CustomStringConvertible {
        let name: [SGFUcLetter]
        var description: String { return String(name) }
    }
    typealias SGFUcLetter = Character
    
    struct SGFPropValue: CustomStringConvertible {
        let value: SGFCValueType
        var description: String { return "\(value)" }
    }
    
    
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

