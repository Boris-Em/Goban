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
        return parseCharacterFromSet(CharacterSet.decimalDigits)
    }
    
    static func digitsParser() -> CharacterParser<[Character]> {
        return  parseGreedyCharactersFromSet(CharacterSet.decimalDigits)
    }
    
    static func numberStringParser() -> CharacterParser<String> {
        let parserPlusMinus = optional(parseCharacter("+") <|> parseCharacter("-"))
        func plusMinusToString(_ plusMinus: Character?, digits: [Character]) -> String {
            return plusMinus == nil ? String(digits) : (String(describing: plusMinus) + String(digits))
        }
        return curry(plusMinusToString) </> parserPlusMinus <*> digitsParser()
    }
    
    static func numberParser() -> CharacterParser<SGFP.ValueType> {
        return { SGFP.ValueType.number(value: Int($0)!) } </> numberStringParser()
    }
    
    static func realParser() -> CharacterParser<SGFP.ValueType> {
        return curry { SGFPValueTypeParser.realFromWholeDigits($0, fractionDigits: $1) } </> numberStringParser() <*> optional(parseCharacter(".") *> oneOrMore(digitParser()))
    }
    
    static func doubleParser() -> CharacterParser<SGFP.ValueType> {
        return { SGFP.ValueType.double(value: $0) } </> (parseCharacter("1") <|> parseCharacter("2"))
    }
    
    static func colorParser() -> CharacterParser<SGFP.ValueType> {
        return { SGFP.ValueType.color(colorName: String($0)) } </> (parseCharacter("B") <|> parseCharacter("W"))
    }
    
    static func simpleTextParser() -> CharacterParser<SGFP.ValueType> {
        let anythingButBracket = CharacterSet(charactersIn: "]").inverted
        
        return { SGFP.ValueType.simpleText(text: String($0)) } </> parseGreedyCharactersFromSet(anythingButBracket)
    }
    
    static func textParser() -> CharacterParser<SGFP.ValueType> {
        let anythingButBracket = CharacterSet(charactersIn: "]").inverted
        
        return { SGFP.ValueType.text(text: String($0)) } </> parseGreedyCharactersFromSet(anythingButBracket)
    }
    
    static func goPointParser() -> CharacterParser<SGFP.ValueType> {
        let parseLcLetter = parseCharacterFromSet(CharacterSet.lowercaseLetters)
        return curry { SGFP.ValueType.point(column: $0, row: $1) } </> parseLcLetter <*> parseLcLetter
    }

    static func goCompressedPointsParser() -> CharacterParser<SGFP.ValueType> {
        let parseColon = parseCharacter(":")
        return curry { SGFP.ValueType.compressedPoints(upperLeft: $0, lowerRight: $1) } </> goPointParser() <* parseColon <*> goPointParser()
    }

    
    static func goMoveParser() -> CharacterParser<SGFP.ValueType> {
        let parseLcLetter = parseCharacterFromSet(CharacterSet.lowercaseLetters)
        return curry { SGFP.ValueType.move(column: $0, row: $1) } </> parseLcLetter <*> parseLcLetter
    }
    
    static func goStoneParser() -> CharacterParser<SGFP.ValueType> {
        let parseLcLetter = parseCharacterFromSet(CharacterSet.lowercaseLetters)
        return curry { SGFP.ValueType.stone(column: $0, row: $1) } </> parseLcLetter <*> parseLcLetter
    }
    
    static func anyValueParser() -> CharacterParser<SGFP.ValueType> {
        return numberParser() <|> realParser() <|> doubleParser() <|> colorParser() <|> goPointParser() <|> goMoveParser() <|> goStoneParser() <|> simpleTextParser() <|>  textParser()
    }

    
    fileprivate static func realFromWholeDigits(_ wholeDigits: String, fractionDigits: [Character]?) -> SGFP.ValueType {
        let wholeChars = String(wholeDigits)
        let fractionChars = fractionDigits != nil ? String(fractionDigits!) : ""
        let realString = wholeChars! + "." + fractionChars
        let real = Float(realString)!
        return SGFP.ValueType.real(value: real)
    }

}
