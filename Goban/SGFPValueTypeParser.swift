//
//  SGFP.ValueTypeParser.swift
//  GobanSampleProject
//
//  Created by John on 5/5/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import Foundation


struct SGFPValueTypeParser {
    
    static func digitParser() -> CharacterParser<Character> {
        return parseCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet())
    }
    
    static func digitsParser() -> CharacterParser<[Character]> {
        return  parseGreedyCharactersFromSet(NSCharacterSet.decimalDigitCharacterSet())
    }
    
    static func numberStringParser() -> CharacterParser<String> {
        let parserPlusMinus = optional(parseCharacter("+") <|> parseCharacter("-"))
        func plusMinusToString(plusMinus: Character?, digits: [Character]) -> String {
            return plusMinus == nil ? String(digits) : (String(plusMinus) + String(digits))
        }
        return curry(plusMinusToString) </> parserPlusMinus <*> digitsParser()
    }
    
    static func numberParser() -> CharacterParser<SGFP.ValueType> {
        return { SGFP.ValueType.Number(value: Int($0)!) } </> numberStringParser()
    }
    
    static func realParser() -> CharacterParser<SGFP.ValueType> {
        return curry { SGFPValueTypeParser.realFromWholeDigits($0, fractionDigits: $1) } </> numberStringParser() <*> optional(parseCharacter(".") *> oneOrMore(digitParser()))
    }
    
    static func doubleParser() -> CharacterParser<SGFP.ValueType> {
        return { SGFP.ValueType.Double(value: $0) } </> (parseCharacter("1") <|> parseCharacter("2"))
    }
    
    static func colorParser() -> CharacterParser<SGFP.ValueType> {
        return { SGFP.ValueType.Color(colorName: String($0)) } </> (parseCharacter("B") <|> parseCharacter("W"))
    }
    
    static func simpleTextParser() -> CharacterParser<SGFP.ValueType> {
        let anythingButBracket = NSCharacterSet(charactersInString: "]").invertedSet
        
        return { SGFP.ValueType.SimpleText(text: String($0)) } </> parseGreedyCharactersFromSet(anythingButBracket)
    }
    
    static func textParser() -> CharacterParser<SGFP.ValueType> {
        let anythingButBracket = NSCharacterSet(charactersInString: "]").invertedSet
        
        return { SGFP.ValueType.Text(text: String($0)) } </> parseGreedyCharactersFromSet(anythingButBracket)
    }
    
    static func goPointParser() -> CharacterParser<SGFP.ValueType> {
        let parseLcLetter = parseCharacterFromSet(NSCharacterSet.lowercaseLetterCharacterSet())
        return curry { SGFP.ValueType.Point(column: $0, row: $1) } </> parseLcLetter <*> parseLcLetter
    }

    static func goCompressedPointsParser() -> CharacterParser<SGFP.ValueType> {
        let parseColon = parseCharacter(":")
        return curry { SGFP.ValueType.CompressedPoints(upperLeft: $0, lowerRight: $1) } </> goPointParser() <* parseColon <*> goPointParser()
    }

    
    static func goMoveParser() -> CharacterParser<SGFP.ValueType> {
        let parseLcLetter = parseCharacterFromSet(NSCharacterSet.lowercaseLetterCharacterSet())
        return curry { SGFP.ValueType.Move(column: $0, row: $1) } </> parseLcLetter <*> parseLcLetter
    }
    
    static func goStoneParser() -> CharacterParser<SGFP.ValueType> {
        let parseLcLetter = parseCharacterFromSet(NSCharacterSet.lowercaseLetterCharacterSet())
        return curry { SGFP.ValueType.Stone(column: $0, row: $1) } </> parseLcLetter <*> parseLcLetter
    }
    
    static func anyValueParser() -> CharacterParser<SGFP.ValueType> {
        return numberParser() <|> realParser() <|> doubleParser() <|> colorParser() <|> goPointParser() <|> goMoveParser() <|> goStoneParser() <|> simpleTextParser() <|>  textParser()
    }

    
    private static func realFromWholeDigits(wholeDigits: String, fractionDigits: [Character]?) -> SGFP.ValueType {
        let wholeChars = String(wholeDigits)
        let fractionChars = fractionDigits != nil ? String(fractionDigits!) : ""
        let realString = wholeChars + "." + fractionChars
        let real = Float(realString)!
        return SGFP.ValueType.Real(value: real)
    }

}