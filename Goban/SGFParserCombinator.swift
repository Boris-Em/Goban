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
        return { SGFP.Collection(games: $0) } </>
            just(greedy(oneOrMore(eatWS() *> parseGameTree())) <* eatWS())
    }

    func parseGameTree() -> Parser<Character, SGFP.GameTree> {
        return { SGFP.GameTree(sequence: $0) } </>
            pack(parseSequence() <* eatWS(), start: "(", end: ")")
    }

    func parseSequence() -> Parser<Character, SGFP.Sequence> {
        return curry { SGFP.Sequence(nodes: $0, games:$1) } </>
            greedy(oneOrMore(eatWS() *> parseNode())) <*>
            zeroOrMore(eatWS() *> lazy { self.parseGameTree() })
    }
    
    func parseNode() -> Parser<Character, SGFP.Node> {
        return { SGFP.Node(properties: $0) } </>
            (parseCharacter(";") *> greedy(zeroOrMore(eatWS() *> parseProperty())))
    }

    func parseProperty() -> Parser<Character, SGFP.Property> {
        return curry { SGFP.Property(identifier: $0, values: $1) } </>
            parsePropertyIdent() <*> greedy(oneOrMore(eatWS() *> parsePropertyValueString()))
    }

    func parsePropertyIdent() -> Parser<Character, SGFP.PropIdent> {
        return { SGFP.PropIdent(name: String($0)) } </>
            parseGreedyCharactersFromSet(NSCharacterSet.uppercaseLetterCharacterSet())
    }
    
    func parsePropertyValueString() -> Parser<Character, SGFP.PropValue> {
        // parse the whole value as text for now, to keep the variations smaller
        let anythingButBracket = NSCharacterSet(charactersInString: "]").invertedSet
        return { SGFP.PropValue(valueString: String($0)) } </>
            pack(parseGreedyCharactersFromSet(anythingButBracket) <|> pure([]), start:"[", end:"]")
    }
    
}

