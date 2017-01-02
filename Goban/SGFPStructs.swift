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
        var description: String { return "Collection: \(games.map{$0.description}.joined(separator: "\n"))" }
    }
    
    struct GameTree: CustomStringConvertible {
        let sequence: SGFP.Sequence
        var description: String { return "GameTree: \(sequence.description)" }
        
        func node(forPath path: [Int]) -> SGFP.Node? {
            guard let game = self.game(forPath: path) else {
                return nil
            }
            
            return game.sequence.node(atIndex: path.last)
        }
        
        func game(forPath path: [Int]) -> SGFP.GameTree? {
            guard path.count > 1 else {
                return self
            }
            
            return self.sequence.variation(forPath: path)
        }
    }
    
    struct Sequence: CustomStringConvertible {
        let nodes: [SGFP.Node]
        let games: [SGFP.GameTree]
        var description: String { return "Sequence: \(nodes.map{$0.description}.joined(separator: "\n"))" }
        
        func node(atIndex index: Int?) -> SGFP.Node? {
            guard let index = index, nodes.count > index else {
                return nil
            }
            
            return nodes[index]
        }
        
        func variation(forPath path: [Int]) -> SGFP.GameTree? {
            guard path.count > 1 else {
                return nil
            }
            
            guard let variationIndex = path.first, games.count > variationIndex else {
                return nil
            }
            
            let game = games[variationIndex]
            
            guard path.count != 2 else {
                return game
            }
            
            return game.sequence.variation(forPath: Array(path.dropFirst()))
        }
    }
    
    struct Node: CustomStringConvertible {
        let properties: [SGFP.Property]
        var description: String { return "Node: \(properties.map{$0.description}.joined(separator: ""))" }
        
        func propertyWithName(_ name: String) -> Property? {
            if let i = properties.index( where: { $0.identifier == name } ) {
                return properties[i]
            }
            return nil
        }
    }
    
    struct Property: CustomStringConvertible {
        let identifier: String
        let values: [SGFP.PropValue]
        var description: String { return "\(identifier)\(values.map{"[\($0)]"}.joined(separator: ""))" }
    }
    
    struct PropValue: CustomStringConvertible {
        let asString: String
        var description: String { return asString }
    }
}

extension SGFP.PropValue {
    
    typealias ValueParser = SGFPValueTypeParser
    
    func parseWith(_ p: CharacterParser<SGFP.ValueType>) -> SGFP.ValueType? {
        return just(p).parse(asString.slice).makeIterator().next()?.0
    }
    
    func toNumber() -> Int? {
        if let v = parseWith(ValueParser.numberParser() ), case let .number(n) = v { return n }
        return nil
    }
    
    func toReal() -> Float? {
        if let v = parseWith(ValueParser.realParser()), case let .real(n) = v { return n }
        return nil
    }
    
    func toDouble() -> Character? {
        if let v = parseWith(ValueParser.doubleParser() ), case let .double(n) = v { return n }
        return nil
    }
    
    func toColor() -> String? {
        if let v = parseWith(ValueParser.colorParser() ), case let .color(n) = v { return n }
        return nil
    }
    
    func toSimpleText() -> String? {
        if let v = parseWith(ValueParser.simpleTextParser() ), case let .simpleText(n) = v { return n }
        return nil
    }
    
    func toText() -> String? {
        if let v = parseWith(ValueParser.textParser()), case let .text(n) = v { return n }
        return nil
    }
    
    func toPoint() -> (col: Character, row: Character)? {
        if let v = parseWith(ValueParser.goPointParser()), case let .point(c, r) = v { return (col:c, row:r) }
        return nil
    }
    
    func toMove() -> (col: Character, row: Character)? {
        if let v = parseWith(ValueParser.goMoveParser()), case let .move(c, r) = v { return (col:c, row:r) }
        return nil
    }
    
    func toStone() -> (col: Character, row: Character)? {
        if let v = parseWith(ValueParser.goStoneParser()), case let .stone(c, r) = v { return (col:c, row:r) }
        return nil
    }
    
    func toCompresedPoints() -> (upperLeftCol: Character, upperLeftRow: Character, lowerRightCol: Character, lowerRightRow: Character)? {
        if let v = parseWith(ValueParser.goCompressedPointsParser()),
            case let .compressedPoints(ul, lr) = v,
            case let .point(upperLeftCol, upperLeftRow) = ul,
            case let .point(lowerRightCol, lowerRightRow) = lr {
            
            return (upperLeftCol: upperLeftCol, upperLeftRow: upperLeftRow, lowerRightCol: lowerRightCol, lowerRightRow: lowerRightRow)
        }
        return nil
    }

}



