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
        case none
        case number(value: Int)
        case real(value: Float)
        case double(value: Character)
        case color(colorName: String)
        case simpleText(text: String)
        case text(text: String)
        case point(column: Character, row: Character)
        case move(column: Character, row: Character)
        case stone(column: Character, row: Character)
        indirect case compressedPoints(upperLeft: ValueType, lowerRight: ValueType)
        
        var description: String {
            switch self {
            case .none: return "None"
            case .number(let v): return "Number:\(v)"
            case .real(let v): return "Real:\(v)"
            case .double(let v): return "Double:\(v)"
            case .color(let v): return "Color:\(v)"
            case .simpleText(let v): return "SimpleText:\(v)"
            case .text(let v): return "Text:\(v)"
            case .point(let c, let r): return "Point:\(c)\(r)"
            case .move(let c, let r): return "Move:\(c)\(r)"
            case .stone(let c, let r): return "Stone:\(c)\(r)"
            case .compressedPoints(let upperLeft, let lowerRight): return "CompressedPoints:\(upperLeft):\(lowerRight)"
            }
        }
    }
}

func ==(l: SGFP.ValueType, r: SGFP.ValueType) -> Bool {
    switch l {
    case .none:                 if case .none = r { return true }
    case .number(let vl):       if case .number(let vr) = r, vl == vr { return true }
    case .real(let vl):         if case .real(let vr) = r, vl == vr { return true }
    case .double(let vl):       if case .double(let vr) = r, vl == vr { return true }
    case .color(let vl):        if case .color(let vr) = r, vl == vr { return true }
    case .simpleText(let vl):   if case .simpleText(let vr) = r, vl == vr { return true }
    case .text(let vl):         if case .text(let vr) = r, vl == vr { return true }
    case .point(let cl, let rl):if case .point(let cr, let rr) = r, cl == cr && rl == rr { return true }
    case .move(let cl, let rl): if case .move(let cr, let rr) = r, cl == cr && rl == rr { return true }
    case .stone(let cl, let rl):if case .stone(let cr, let rr) = r, cl == cr && rl == rr { return true }
    case .compressedPoints(let upperLeft, let lowerRight): if upperLeft == lowerRight { return true }
    }
    return false
}


