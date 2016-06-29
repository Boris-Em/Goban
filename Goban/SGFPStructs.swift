//
//  SGFStructs.swift
//  GobanSampleProject
//
//  Created by John on 5/6/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import Foundation

struct SGFP {
    
    struct Collection: CustomStringConvertible {
        let games: [SGFP.GameTree]
        var description: String { return "Collection: \(games.map{$0.description}.joinWithSeparator("\n"))" }
    }
    
    struct GameTree: CustomStringConvertible {
        let sequence: SGFP.Sequence
        var description: String { return "GameTree: \(sequence.description)" }
    }
    
    struct Sequence: CustomStringConvertible {
        let nodes: [SGFP.Node]
        let games: [SGFP.GameTree]
        var description: String { return "Sequence: \(nodes.map{$0.description}.joinWithSeparator("\n"))" }
    }
    
    struct Node: CustomStringConvertible {
        let properties: [SGFP.Property]
        var description: String { return "Node: \(properties.map{$0.description}.joinWithSeparator(""))" }
        
        func propertyWithName(name: String) -> Property? {
            if let i = properties.indexOf( { $0.identifier == name } ) {
                return properties[i]
            }
            return nil
        }
    }
    
    struct Property: CustomStringConvertible {
        let identifier: String
        let values: [SGFP.PropValue]
        var description: String { return "\(identifier)\(values.map{"[\($0)]"}.joinWithSeparator(""))" }
    }
    
    struct PropValue: CustomStringConvertible {
        let asString: String
        var description: String { return "\(String(asString))" }
    }
}

extension SGFP.PropValue {
    
    typealias ValueParser = SGFPValueTypeParser
    
    func parseWith(p: CharacterParser<SGFP.ValueType>) -> SGFP.ValueType? {
        return just(p).parse(asString.slice).generate().next()?.0
    }
    
    func toNumber() -> Int? {
        if let v = parseWith(ValueParser.numberParser() ), case let .Number(n) = v { return n }
        return nil
    }
    
    func toReal() -> Float? {
        if let v = parseWith(ValueParser.realParser()), case let .Real(n) = v { return n }
        return nil
    }
    
    func toDouble() -> Character? {
        if let v = parseWith(ValueParser.doubleParser() ), case let .Double(n) = v { return n }
        return nil
    }
    
    func toColor() -> String? {
        if let v = parseWith(ValueParser.colorParser() ), case let .Color(n) = v { return n }
        return nil
    }
    
    func toSimpleText() -> String? {
        if let v = parseWith(ValueParser.simpleTextParser() ), case let .SimpleText(n) = v { return n }
        return nil
    }
    
    func toText() -> String? {
        if let v = parseWith(ValueParser.textParser()), case let .Text(n) = v { return n }
        return nil
    }
    
    func toPoint() -> (col: Character, row: Character)? {
        if let v = parseWith(ValueParser.goPointParser()), case let .Point(c, r) = v { return (col:c, row:r) }
        return nil
    }
    
    func toMove() -> (col: Character, row: Character)? {
        if let v = parseWith(ValueParser.goMoveParser()), case let .Move(c, r) = v { return (col:c, row:r) }
        return nil
    }
    
    func toStone() -> (col: Character, row: Character)? {
        if let v = parseWith(ValueParser.goStoneParser()), case let .Stone(c, r) = v { return (col:c, row:r) }
        return nil
    }
    
    func toCompresedPoints() -> (upperLeftCol: Character, upperLeftRow: Character, lowerRightCol: Character, lowerRightRow: Character)? {
        if let v = parseWith(ValueParser.goCompressedPointsParser()),
            case let .CompressedPoints(ul, lr) = v,
            case let .Point(upperLeftCol, upperLeftRow) = ul,
            case let .Point(lowerRightCol, lowerRightRow) = lr {
            
            return (upperLeftCol: upperLeftCol, upperLeftRow: upperLeftRow, lowerRightCol: lowerRightCol, lowerRightRow: lowerRightRow)
        }
        return nil
    }

}



