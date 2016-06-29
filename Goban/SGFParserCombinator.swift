//
//  SGFParser.swift
//  GobanSampleProject
//
//  Created by John on 5/4/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import Foundation


struct SGFParserCombinator {
    
    static func collectionParser() -> CharacterParser<SGFP.Collection> {
        return { SGFP.Collection(games: $0) } </>
            just(greedy(oneOrMore(eatWS() *> gameTreeParser())) <* eatWS())
    }

    static func gameTreeParser() -> CharacterParser<SGFP.GameTree> {
        return { SGFP.GameTree(sequence: $0) } </>
            pack(sequenceParser() <* eatWS(), start: "(", end: ")")
    }

    static func sequenceParser() -> CharacterParser<SGFP.Sequence> {
        return curry { SGFP.Sequence(nodes: $0, games:$1) } </>
            greedy(oneOrMore(eatWS() *> nodeParser())) <*>
            zeroOrMore(eatWS() *> lazy { gameTreeParser() })
    }
    
    static func nodeParser() -> CharacterParser<SGFP.Node> {
        return { SGFP.Node(properties: $0) } </>
            (parseCharacter(";") *> greedy(zeroOrMore(eatWS() *> propertyParser())))
    }

    static func propertyParser() -> CharacterParser<SGFP.Property> {
        return curry { SGFP.Property(identifier: String($0), values: $1) } </>
            parseGreedyCharactersFromSet(NSCharacterSet.uppercaseLetterCharacterSet()) <*> greedy(oneOrMore(eatWS() *> propValueAsStringParser()))
    }
    
    static func propValueAsStringParser() -> CharacterParser<SGFP.PropValue> {
        // parse the whole value as text for now, to keep the variations smaller
        let anythingButBracket = NSCharacterSet(charactersInString: "]").invertedSet
        return { SGFP.PropValue(asString: String($0)) } </>
            pack(parseGreedyCharactersFromSet(anythingButBracket) <|> pure([]), start:"[", end:"]")
    }
    
}

