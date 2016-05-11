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
    }
    
    struct Property: CustomStringConvertible {
        let identifier: SGFP.PropIdent;
        let values: [SGFP.PropValue]
        var description: String { return "\(identifier)\(values.map{"[\($0)]"}.joinWithSeparator(""))" }
    }
    
    struct PropIdent: CustomStringConvertible {
        let name: String
        var description: String { return name }
    }
    
    struct PropValue: CustomStringConvertible {
        let valueString: String
        var description: String { return "\(String(valueString))" }
        
        var valueParser: SGFValueTypeParser { return SGFValueTypeParser() }
        func parseWith(parserFrom: (SGFValueTypeParser) -> Parser<Character, SGFP.ValueType>) -> SGFP.ValueType? {
            return parserFrom(SGFValueTypeParser()).parse(valueString.slice).generate().next()?.0
        }
        func parse(p: Parser<Character, SGFP.ValueType>) -> SGFP.ValueType? {
            return p.parse(valueString.slice).generate().next()?.0
        }
        
        func toNumber() -> Int? {
            if let v = parseWith({ $0.parseNumber() }), case let .Number(n) = v { return n }
            return nil
        }
        
        func toReal() -> Float? {
            if let v = parseWith({ $0.parseReal() }), case let .Real(n) = v { return n }
            return nil
        }

        func toDouble() -> Character? {
            if let v = parseWith({ $0.parseDouble() }), case let .Double(n) = v { return n }
            return nil
        }

        func toColor() -> String? {
            if let v = parseWith({ $0.parseColor() }), case let .Color(n) = v { return n }
            return nil
        }
        
        func toSimpleText() -> String? {
            if let v = parseWith({ $0.parseSimpleText() }), case let .SimpleText(n) = v { return n }
            return nil
        }
        
        func toText() -> String? {
            if let v = parseWith({ $0.parseText() }), case let .Text(n) = v { return n }
            return nil
        }

        func toPoint() -> (col: Character, row: Character)? {
            if let v = parseWith({ $0.parseGoPoint() }), case let .Point(c, r) = v { return (col:c, row:r) }
            return nil
        }

        func toMove() -> (col: Character, row: Character)? {
            if let v = parseWith({ $0.parseGoMove() }), case let .Move(c, r) = v { return (col:c, row:r) }
            return nil
        }

        func toStone() -> (col: Character, row: Character)? {
            if let v = parseWith({ $0.parseGoStone() }), case let .Stone(c, r) = v { return (col:c, row:r) }
            return nil
        }
    }
    
    enum ValueType: Equatable, CustomStringConvertible {
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
}



func ==(l: SGFP.ValueType, r: SGFP.ValueType) -> Bool {
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

