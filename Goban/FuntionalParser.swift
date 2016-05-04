//
//  FuntionalParser.swift
//  GobanSampleProject
//
//  Created by John on 5/3/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import Foundation


struct Parser<Token, Result> {
    let parse: ArraySlice<Token> -> AnySequence<(Result, ArraySlice<Token>)>
}

func emptySequence<T>() -> AnySequence<T> {
    return AnySequence([])
}

func parseSatisfying<Token>(condition: Token -> Bool) -> Parser<Token, Token> {
    return Parser { x in
        guard let (head, tail) = x.decompose where condition(head) else {
            return AnySequence([])
        }
        
        return anySequenceOfOne((head, tail))
    }
}

func parseIsToken<Token: Equatable>(t: Token) -> Parser<Token, Token> {
    return parseSatisfying { $0 == t }
}

func parseIsCharacter(c: Character) -> Parser<Character, Character> {
    return parseIsToken(c)
}

infix operator<|> { associativity right precedence 130 }
func <|> <Token, Result>(l: Parser<Token, Result>, r: Parser<Token, Result>) -> Parser<Token, Result> {
    return Parser { l.parse($0) + r.parse($0) }
}

func sequence<Token, A, B>(l: Parser<Token, A>, _ r: Parser<Token, B>) -> Parser<Token, (A,B) > {
    return Parser { input in
        let leftResults = l.parse(input)
        return leftResults.flatMap { (a, leftRest) -> [((A,B), ArraySlice<Token>)]  in
            let rightResult = r.parse(leftRest)
            return rightResult.map { b, rightRest in
                ((a,b), rightRest)
            }
        }
    }
}