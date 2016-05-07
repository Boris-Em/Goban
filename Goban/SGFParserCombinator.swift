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
        return { SGFP.Collection(games: $0) } </> greedy(oneOrMore(parseGameTree()))
    }

    func parseGameTree() -> Parser<Character, SGFP.GameTree> {
        return { SGFP.GameTree(sequence: $0) } </> pack(parseSequence(), start: "(", end: ")")
    }

    func parseSequence() -> Parser<Character, SGFP.Sequence> {
        return { SGFP.Sequence(nodes: $0) } </> greedy(oneOrMore(parseNode()))
    }
    
    func parseNode() -> Parser<Character, SGFP.Node> {
        return { SGFP.Node(properties: $0) } </> (parseCharacter(";") *> greedy(zeroOrMore(parseProperty())))
    }

    func parseProperty() -> Parser<Character, SGFP.Property> {
        return curry { SGFP.Property(identifier: $0, values: $1) } </> parsePropertyIdent() <*> greedy(oneOrMore(parsePropertyValueChars()))
    }

    func parsePropertyIdent() -> Parser<Character, SGFP.PropIdent> {
        return { SGFP.PropIdent(name: $0) } </> parseGreedyCharactersFromSet(NSCharacterSet.uppercaseLetterCharacterSet())
    }
    
    func parsePropertyValueChars() -> Parser<Character, SGFP.PropValue> {
        // parse the whole value as text for now, to keep the variations smaller
        let anythingButBracket = NSCharacterSet(charactersInString: "]").invertedSet
        return { SGFP.PropValue(valueChars: $0) } </> (parseCharacter("[") *> parseGreedyCharactersFromSet(anythingButBracket) <* parseCharacter("]"))
    }
    
}

