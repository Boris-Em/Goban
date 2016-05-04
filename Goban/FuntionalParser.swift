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

// choice operator
infix operator <|> { associativity right precedence 130 }
func <|> <Token, Result>(l: Parser<Token, Result>, r: Parser<Token, Result>) -> Parser<Token, Result> {
    return Parser { l.parse($0) + r.parse($0) }
}

// sequence
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

// pure consumes no Tokens and returns contained T
func pure<Token, T>(value: T) -> Parser<Token, T> {
    return Parser { anySequenceOfOne((value, $0)) }
}

// combinator operator
infix operator <*> { associativity left precedence 150 }
func <*><Token, A, B>(l: Parser<Token, A -> B>, r: Parser<Token, A>) -> Parser<Token, B> {
    typealias Result = (B, ArraySlice<Token>)
    typealias Results = [Result]

    return Parser { input in
        let leftResult = l.parse(input)
        return leftResult.flatMap { (f, leftRest) -> Results in
            let rightResult = r.parse(leftRest)
            return rightResult.map { (right, rightRest) -> Result in
                (f(right), rightRest)
            }
        }
    }
}


func curry<A,B,C>(f: (A,B) -> C) -> A -> B -> C  {
    return { a in { b in f(a,b) } }
}

func curry<A,B,C,D>(f: (A,B,C) -> D) -> A -> B -> C -> D  {
    return { a in { b in { c in f(a,b,c) } } }
}

func isCharacterFromSet(set: NSCharacterSet) -> Parser<Character, Character> {
    return parseSatisfying { (ch: Character) in
        let uniChar = (String(ch) as NSString).characterAtIndex(0)
        return set.characterIsMember(uniChar)
    }
}


func prepend<A>(l: A) -> [A] -> [A] {
    return { r in return [l] + r }
}

func lazy<Token,A>(f: () -> Parser<Token,A>) -> Parser<Token,A> {
    return Parser { f().parse($0) }
}

func zeroOrMore<Token, A>(p: Parser<Token, A>) -> Parser<Token, [A]> {
    return (pure(prepend) <*> p <*> lazy { zeroOrMore(p) }) <|> pure([])
}

func oneOrMore<Token, A>(p: Parser<Token, A>) -> Parser<Token, [A]> {
    return pure(prepend) <*> p <*> zeroOrMore(p)
}

func intFromChars(chars: [Character]) -> Int {
    return Int(String(chars))!
}

// pure combinator operator
infix operator </> { associativity left precedence 170 }
func </><Token, A,B>(f: A -> B, r: Parser<Token, A>) -> Parser<Token, B> {
    return pure(f) <*> r
}