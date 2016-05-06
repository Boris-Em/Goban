//
//  SGFCValueTypeParser.swift
//  GobanSampleProject
//
//  Created by John on 5/5/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import Foundation

enum SGFCValueType: Equatable, CustomStringConvertible {
    case None
    case Number(value: Int)
    case Real(value: Float)
    case Double(value: Character)
    case Color(colorName: String)
    case SimpleText(text: String)
    case Text(text: String)
    case Point(column: Character, row: Character)
    case Move(column: Character, row: Character)
    case Stone(column: Character, row: Character)
    
    var description: String {
        switch self {
        case .None: return "None"
        case .Number(let v): return "Number:\(v)"
        case .Real(let v): return "Real:\(v)"
        case .Double(let v): return "Double:\(v)"
        case .Color(let v): return "Color:\(v)"
        case .SimpleText(let v): return "SimpleText:\(v)"
        case .Text(let v): return "Text:\(v)"
        case .Point(let c, let r): return "Point:\(c)\(r)"
        case .Move(let c, let r): return "Move:\(c)\(r)"
        case .Stone(let c, let r): return "Stone:\(c)\(r)"
        }
    }
}

func ==(l: SGFCValueType, r: SGFCValueType) -> Bool {
    switch l {
    case .None:                 if case .None = r { return true }
    case .Number(let vl):       if case .Number(let vr) = r where vl == vr { return true }
    case .Real(let vl):         if case .Real(let vr) = r where vl == vr { return true }
    case .Double(let vl):       if case .Double(let vr) = r where vl == vr { return true }
    case .Color(let vl):        if case .Color(let vr) = r where vl == vr { return true }
    case .SimpleText(let vl):   if case .SimpleText(let vr) = r where vl == vr { return true }
    case .Text(let vl):         if case .Text(let vr) = r where vl == vr { return true }
    case .Point(let cl, let rl):if case .Point(let cr, let rr) = r where cl == cr && rl == rr { return true }
    case .Move(let cl, let rl): if case .Move(let cr, let rr) = r where cl == cr && rl == rr { return true }
    case .Stone(let cl, let rl):if case .Stone(let cr, let rr) = r where cl == cr && rl == rr { return true }
    }
    return false
}

struct SGFCValueTypeParser {
    let parseDigit = parseCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet())
    let parseDigits = oneOrMore(parseCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet()))
    let parseUcLetter = parseCharacterFromSet(NSCharacterSet.uppercaseLetterCharacterSet())
    let parseLcLetter = parseCharacterFromSet(NSCharacterSet.lowercaseLetterCharacterSet())
    let parseNone = parseCharacter(" ")
    let parseDecimalPt = parseCharacter(".")
    let parsePlusMinus: Parser<Character, Character?> = optional(parseCharacter("+") <|> parseCharacter("-"))
    let parseQuote = parseCharacter("\"")
    
    
    func parseNumberCharacters() -> Parser<Character, [Character]> {
        return curry { (plusMinus, digits) in return plusMinus != nil ? [plusMinus!] + digits : digits } </> parsePlusMinus <*> parseDigits
    }
    
    func parseNumber() -> Parser<Character, SGFCValueType> {
        return { SGFCValueType.Number(value: Int(String($0))!) } </> parseNumberCharacters()
    }
    
    func parseReal() -> Parser<Character, SGFCValueType> {
        return curry { SGFCValueTypeParser.realFromWholeDigits($0, fractionDigits: $1) } </> parseNumberCharacters() <*> optional(parseDecimalPt *> oneOrMore(parseDigit))
    }
    static func realFromWholeDigits(wholeDigits: [Character], fractionDigits: [Character]?) -> SGFCValueType {
        let wholeChars = String(wholeDigits)
        let fractionChars = fractionDigits != nil ? String(fractionDigits!) : ""
        let realString = wholeChars + "." + fractionChars
        let real = Float(realString)!
        return SGFCValueType.Real(value: real)
    }
    
    func parseDouble() -> Parser<Character, SGFCValueType> {
        return { SGFCValueType.Double(value: $0) } </> (parseCharacter("1") <|> parseCharacter("2"))
    }
    
    func parseColor() -> Parser<Character, SGFCValueType> {
        return { SGFCValueType.Color(colorName: String($0)) } </> (parseCharacter("B") <|> parseCharacter("W"))
    }
    func parseSimpleText() -> Parser<Character, SGFCValueType> {
        let anythingButBracket = NSCharacterSet(charactersInString: "]").invertedSet
        
        return { SGFCValueType.SimpleText(text: String($0)) } </> zeroOrMore(parseCharacterFromSet(anythingButBracket))
    }
    
    func parseText() -> Parser<Character, SGFCValueType> {
        let anythingButBracket = NSCharacterSet(charactersInString: "]").invertedSet
        
        return { SGFCValueType.Text(text: String($0)) } </> zeroOrMore(parseCharacterFromSet(anythingButBracket))
    }
    
    func parseGoPoint() -> Parser<Character, SGFCValueType> {
        return curry { SGFCValueType.Point(column: $0, row: $1) } </> parseLcLetter <*> parseLcLetter
    }

    func parseGoMove() -> Parser<Character, SGFCValueType> {
        return curry { SGFCValueType.Move(column: $0, row: $1) } </> parseLcLetter <*> parseLcLetter
    }
    func parseGoStone() -> Parser<Character, SGFCValueType> {
        return curry { SGFCValueType.Stone(column: $0, row: $1) } </> parseLcLetter <*> parseLcLetter
    }
    
    
    func parseCValue() -> Parser<Character, SGFCValueType> {
        return  parseNumber() <|> parseReal() <|> parseDouble() <|> parseColor() <|> parseGoPoint() <|> parseGoMove() <|> parseGoStone() <|> parseSimpleText() <|>  parseText()
    }
    
}