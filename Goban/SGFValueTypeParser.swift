//
//  SGFP.ValueTypeParser.swift
//  GobanSampleProject
//
//  Created by John on 5/5/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import Foundation


struct SGFValueTypeParser {
    let parseDigit = parseCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet())
    let parseDigits = parseGreedyCharactersFromSet(NSCharacterSet.decimalDigitCharacterSet())
    let parseUcLetter = parseCharacterFromSet(NSCharacterSet.uppercaseLetterCharacterSet())
    let parseLcLetter = parseCharacterFromSet(NSCharacterSet.lowercaseLetterCharacterSet())
    let parseNone = parseCharacter(" ")
    let parseDecimalPt = parseCharacter(".")
    let parsePlusMinus: Parser<Character, Character?> = optional(parseCharacter("+") <|> parseCharacter("-"))
    let parseQuote = parseCharacter("\"")
    
    func parseNumberCharacters() -> Parser<Character, [Character]> {
        return curry { (plusMinus, digits) in return plusMinus != nil ? [plusMinus!] + digits : digits } </> parsePlusMinus <*> parseDigits
    }
    
    func parseNumber() -> Parser<Character, SGFP.ValueType> {
        return { SGFP.ValueType.Number(value: Int(String($0))!) } </> parseNumberCharacters()
    }
    
    func parseReal() -> Parser<Character, SGFP.ValueType> {
        return curry { SGFValueTypeParser.realFromWholeDigits($0, fractionDigits: $1) } </> parseNumberCharacters() <*> optional(parseDecimalPt *> oneOrMore(parseDigit))
    }
    
    static func realFromWholeDigits(wholeDigits: [Character], fractionDigits: [Character]?) -> SGFP.ValueType {
        let wholeChars = String(wholeDigits)
        let fractionChars = fractionDigits != nil ? String(fractionDigits!) : ""
        let realString = wholeChars + "." + fractionChars
        let real = Float(realString)!
        return SGFP.ValueType.Real(value: real)
    }
    
    func parseDouble() -> Parser<Character, SGFP.ValueType> {
        return { SGFP.ValueType.Double(value: $0) } </> (parseCharacter("1") <|> parseCharacter("2"))
    }
    
    func parseColor() -> Parser<Character, SGFP.ValueType> {
        return { SGFP.ValueType.Color(colorName: String($0)) } </> (parseCharacter("B") <|> parseCharacter("W"))
    }
    func parseSimpleText() -> Parser<Character, SGFP.ValueType> {
        let anythingButBracket = NSCharacterSet(charactersInString: "]").invertedSet
        
        return { SGFP.ValueType.SimpleText(text: String($0)) } </> parseGreedyCharactersFromSet(anythingButBracket)
    }
    
    func parseText() -> Parser<Character, SGFP.ValueType> {
        let anythingButBracket = NSCharacterSet(charactersInString: "]").invertedSet
        
        return { SGFP.ValueType.Text(text: String($0)) } </> parseGreedyCharactersFromSet(anythingButBracket)
    }
    
    func parseGoPoint() -> Parser<Character, SGFP.ValueType> {
        return curry { SGFP.ValueType.Point(column: $0, row: $1) } </> parseLcLetter <*> parseLcLetter
    }

    func parseGoMove() -> Parser<Character, SGFP.ValueType> {
        return curry { SGFP.ValueType.Move(column: $0, row: $1) } </> parseLcLetter <*> parseLcLetter
    }
    
    func parseGoStone() -> Parser<Character, SGFP.ValueType> {
        return curry { SGFP.ValueType.Stone(column: $0, row: $1) } </> parseLcLetter <*> parseLcLetter
    }
    
    
    func parseCValue() -> Parser<Character, SGFP.ValueType> {
        return  parseNumber() <|> parseReal() <|> parseDouble() <|> parseColor() <|> parseGoPoint() <|> parseGoMove() <|> parseGoStone() <|> parseSimpleText() <|>  parseText()
    }
    
}