//
//  SGFPValueType.swift
//  GobanSampleProject
//
//  Created by John on 6/28/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import Foundation


extension SGFP {
    
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
        indirect case CompressedPoints(upperLeft: ValueType, lowerRight: ValueType)
        
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
            case .CompressedPoints(let upperLeft, let lowerRight): return "CompressedPoints:\(upperLeft):\(lowerRight)"
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
    case .CompressedPoints(let upperLeft, let lowerRight): if upperLeft == lowerRight { return true }
    }
    return false
}


