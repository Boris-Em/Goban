//
//  SGFParser.swift
//  GobanSampleProject
//
//  Created by John on 5/4/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import Foundation


struct SGFParserCombinator {
    
    static func collectionParser() -> Parser<Character, SGFP.Collection> {
        return { SGFP.Collection(games: $0) } </>
            just(greedy(oneOrMore(eatWS() *> gameTreeParser())) <* eatWS())
    }

    static func gameTreeParser() -> Parser<Character, SGFP.GameTree> {
        return { SGFP.GameTree(sequence: $0) } </>
            pack(sequenceParser() <* eatWS(), start: "(", end: ")")
    }

    static func sequenceParser() -> Parser<Character, SGFP.Sequence> {
        return curry { SGFP.Sequence(nodes: $0, games:$1) } </>
            greedy(oneOrMore(eatWS() *> nodeParser())) <*>
            zeroOrMore(eatWS() *> lazy { gameTreeParser() })
    }
    
    static func nodeParser() -> Parser<Character, SGFP.Node> {
        return { SGFP.Node(properties: $0) } </>
            (parseCharacter(";") *> greedy(zeroOrMore(eatWS() *> propertyParser())))
    }

    static func propertyParser() -> Parser<Character, SGFP.Property> {
        return curry { SGFP.Property(identifier: $0, values: $1) } </>
            propIdentParser() <*> greedy(oneOrMore(eatWS() *> propValueStringParser()))
    }

    static func propIdentParser() -> Parser<Character, SGFP.PropIdent> {
        return { SGFP.PropIdent(name: String($0)) } </>
            parseGreedyCharactersFromSet(NSCharacterSet.uppercaseLetterCharacterSet())
    }
    
    static func propValueStringParser() -> Parser<Character, SGFP.PropValue> {
        // parse the whole value as text for now, to keep the variations smaller
        let anythingButBracket = NSCharacterSet(charactersInString: "]").invertedSet
        return { SGFP.PropValue(valueString: String($0)) } </>
            pack(parseGreedyCharactersFromSet(anythingButBracket) <|> pure([]), start:"[", end:"]")
    }
    
}

