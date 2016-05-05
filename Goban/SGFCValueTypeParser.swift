//
//  SGFCValueTypeParser.swift
//  GobanSampleProject
//
//  Created by John on 5/5/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import Foundation

enum SGFCValueType {
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
}

struct SGFCValueTypeParser {
    let parseDigit = parseCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet())
    let parseDigits = oneOrMore(parseCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet()))
    let parseUcLetter = parseCharacterFromSet(NSCharacterSet.uppercaseLetterCharacterSet())
    let parseLcLetter = parseCharacterFromSet(NSCharacterSet.lowercaseLetterCharacterSet())
    let parseNone = parseIsCharacter(" ")
    let parseDecimalPt = parseIsCharacter(".")
    let parsePlusMinus = optional(parseIsCharacter("+") <|> parseIsCharacter("-"))
    let parseQuote = parseIsCharacter("\"")
    
    
    func parseNumberCharacters() -> Parser<Character, [Character]> {
        return prepend </> parsePlusMinus <*> parseDigits
    }
    
    func parseNumber() -> Parser<Character, SGFCValueType> {
        return { SGFCValueType.Number(value: Int(String($0))!) } </> parseNumberCharacters()
    }
    
//    func parseReal() -> Parser<Character, SGFCValueType> { return curry { SGFCValueType.Real(value: Float(String($0 ))!) } </> parseNumberCharacters <*> optional(parseDecimalPt <*> oneOrMore(parseDigit))
    
    func parseDouble() -> Parser<Character, SGFCValueType> {
        return { SGFCValueType.Double(value: $0) } </> (parseIsCharacter("1") <|> parseIsCharacter("2"))
    }
    
    func parseColor() -> Parser<Character, SGFCValueType> {
        return { SGFCValueType.Color(colorName: String($0)) } </> (parseIsCharacter("B") <|> parseIsCharacter("W"))
    }
//    func parseSimpleText() -> Parser<Character, SGFCValueType> {
//        return { SGFCValueType.SimpleText(text: String($0)) } </> parseQuote *> zeroOrMore(parseCharacterFromSet(NSCharacterSet.alphanumericCharacterSet())) <* parseQuote
//    }
//    let parseText = { SGFCValueType.SimpleText(text: String($0)) } </> parseQuote *> zeroOrMore(parseCharacterFromSet(NSCharacterSet.alphanumericCharacterSet())) <* parseQuote

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
        // parseNone | parseReal | paserSimpleTedt, ParseText
        return  parseNumber() <|> parseDouble() <|> parseColor() <|> parseGoPoint() <|> parseGoMove() <|> parseGoStone()
    }
    
}