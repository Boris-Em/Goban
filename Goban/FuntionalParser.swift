//
//  FuntionalParser.swift
//  GobanSampleProject
//
//  Created by John on 5/3/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import Foundation

// 
// MARK: - Parser
//

struct Parser<Token, Result> {
    let parse: ArraySlice<Token> -> AnySequence<(Result, ArraySlice<Token>)>
}

//
// MARK: - simple parsers
//

// empty sequence
func emptySequence<T>() -> AnySequence<T> {
    return AnySequence([])
}

func parseFail<Token, A>() -> Parser<Token, A> {
    return Parser { _ in emptySequence() }
}

// parse tokens equal to token
func parseSatisfying<Token>(condition: Token -> Bool) -> Parser<Token, Token> {
    return Parser { x in
        guard let (head, tail) = x.decompose where condition(head) else {
            return AnySequence([])
        }
        
        return anySequenceOfOne((head, tail))
    }
}

// parse token equal to given token
func parseToken<Token: Equatable>(t: Token) -> Parser<Token, Token> {
    return parseSatisfying { $0 == t }
}

// parse only the given character
func parseCharacter(c: Character) -> Parser<Character, Character> {
    return parseToken(c)
}

// parse any character in set
func parseCharacterFromSet(set: NSCharacterSet) -> Parser<Character, Character> {
    return parseSatisfying { (ch: Character) in
        let uniChar = (String(ch) as NSString).characterAtIndex(0)
        return set.characterIsMember(uniChar)
    }
}

// take as many characters from the set as possible, don't provide alternatives
func parseGreedyCharactersFromSet(set: NSCharacterSet) -> Parser<Character, [Character]> {
    func uniChar(ch: Character) -> UniChar {
        return String(ch).utf16.first!
    }
    
    return Parser { input in
        let escapeChar = Character("\\")
        var escapeNext = false
        var lastCharInSet: Int?

        for (i,ch) in input.enumerate() {
            if !(set.characterIsMember(uniChar(ch)) || escapeNext) {
                break
            }
            lastCharInSet = i
            escapeNext = (ch == escapeChar) && !escapeNext
        }
        
        guard let _ = lastCharInSet else {
            return emptySequence()
        }
        
        let chars = Array(input.prefix(lastCharInSet! + 1))
        return anySequenceOfOne((chars, input.dropFirst(chars.count)))
    }
}

// eat up whitespace
func eatWS() -> Parser<Character, [Character]> {
    return (parseGreedyCharactersFromSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) <|> pure([]))
}

// consumes no Tokens and returns contained T
func pure<Token, T>(value: T) -> Parser<Token, T> {
    return Parser { anySequenceOfOne((value, $0)) }
}

//
// MARK: - combinator operators
//

// choice operator
infix operator <|> { associativity right precedence 130 }
func <|> <Token, Result>(l: Parser<Token, Result>, r: Parser<Token, Result>) -> Parser<Token, Result> {
    return Parser { l.parse($0) + r.parse($0) }
}

// sequence operator
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

// combinator, but throw away the result on right
infix operator <* { associativity left precedence 150 }
func <* <Token,A,B>(p: Parser<Token, A>, q: Parser<Token, B>) -> Parser<Token, A> {
    return { x in { _ in x } } </> p <*> q
}

// combinator, but throw away the result on left
infix operator *> { associativity left precedence 150 }
func *> <Token,A,B>(p: Parser<Token,A>, q: Parser<Token, B>) -> Parser<Token, B> {
    return { _ in { y in y } } </> p <*> q
}

// apply combinator operator
infix operator </> { associativity left precedence 170 }
func </><Token, A,B>(f: A -> B, r: Parser<Token, A>) -> Parser<Token, B> {
    return pure(f) <*> r
}

//
// MARK: - convenience combinators
//

// f() returns a parser. f() not evaluate evaluated parse time
func lazy<Token,A>(f: () -> Parser<Token, A>) -> Parser<Token,A> {
    return Parser { f().parse($0) }
}

// return [A]{0,1}
func optional<Token,A>(p: Parser<Token, A>) -> Parser<Token, A?> {
    return (pure { $0 } <*> p ) <|> pure(nil)
}

// return [A]{0,*}
func zeroOrMore<Token,A>(p: Parser<Token, A>) -> Parser<Token, [A]> {
    return (prepend </> p <*> lazy { zeroOrMore(p) }) <|> pure([])
}

// return [A]{1,*}
func oneOrMore<Token,A>(p: Parser<Token, A>) -> Parser<Token, [A]> {
    return prepend </> p <*> zeroOrMore(p)
}

// return [A]{1,*}
func greedy<Token,A>(p: Parser<Token, A>) -> Parser<Token, A> {
    return Parser { input in
        return greediestResults(p.parse(input))
    }
}

// return only the results that consume the most tokens
func greediestResults<Token, A>(results: AnySequence<(A, ArraySlice<Token>)>) -> AnySequence<(A, ArraySlice<Token>)> {
    guard let shortestTail = (results.map { $0.1.count }.minElement()) else {
        return results
    }
    return AnySequence(results.filter { $0.1.count == shortestTail })
}

// no matter what you pass, it returs A
func const<A,B>(x: A) -> (B) -> A {
    return { _ in x }
}

// parse a sequence of tokens
func parseTokens<A: Equatable>(input: [A]) -> Parser<A, [A]> {
    guard let (head, tail) = input.decompose else { return pure([]) }
    return prepend </> parseToken(head) <*> parseTokens(tail)
}

// parse a sequence of characters matching string (and return string)
func parseString(string: String) -> Parser<Character, String> {
    return const(string) </> parseTokens(Array(string.characters))
}

// choose one of parsers from array
func oneOf<Token, A>(parsers: [Parser<Token, A>]) -> Parser<Token, A> {
    return parsers.reduce(parseFail(), combine: <|>)
}

func just<Token, A>(p: Parser<Token, A>) -> Parser<Token, A> {
    return Parser { input in
        let results = p.parse(input)
        return AnySequence(results.filter { $0.1.isEmpty })
    }
}
func pack<Token: Equatable, A>(p: Parser<Token, A>, start: Token, end: Token) -> Parser<Token, A> {
    return parseToken(start) *> p <* parseToken(end)
}



