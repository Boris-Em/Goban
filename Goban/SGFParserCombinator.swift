//
//  SGFParser.swift
//  GobanSampleProject
//
//  Created by John on 5/4/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import Foundation


class SGFParserCombinator {
    
    func parseCollection() -> Parser<Character, SGFP.Collection> {
        return { SGFP.Collection(games: $0) } </> oneOrMore(parseGameTree())
    }

    func parseGameTree() -> Parser<Character, SGFP.GameTree> {
        return { SGFP.GameTree(sequence: $0) } </> (parseCharacter("(") *> parseSequence() <* parseCharacter(")"))
    }

    func parseSequence() -> Parser<Character, SGFP.Sequence> {
        return { SGFP.Sequence(nodes: $0) } </> oneOrMore(parseNode())
    }
    
    func parseNode() -> Parser<Character, SGFP.Node> {
        return { SGFP.Node(properties: $0) } </> (parseCharacter(";") *> zeroOrMore(parseProperty()))
    }

    func parseProperty() -> Parser<Character, SGFP.Property> {
        return curry { SGFP.Property(identifier: $0, values: $1) } </> parsePropertyIdent() <*> oneOrMore(parsePropertyValue())
    }

    func parsePropertyIdent() -> Parser<Character, SGFP.PropIdent> {
        return { SGFP.PropIdent(name: $0) } </> oneOrMore(parseCharacterFromSet(NSCharacterSet.uppercaseLetterCharacterSet()))
    }
    
    let valueTypeParser = SGFValueTypeParser()
    func parsePropertyValue() -> Parser<Character,SGFP.PropValue> {
        return { SGFP.PropValue(value: $0) } </> (parseCharacter("[") *> valueTypeParser.parseCValue() <* parseCharacter("]"))
    }
    
    
}

