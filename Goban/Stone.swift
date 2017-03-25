//
//  Stone.swift
//  GobanSampleProject
//
//  Created by Bobo on 4/2/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import UIKit

enum GobanStoneColor {
    case white
    case black
    
    init?(string: String) {
        switch string.lowercased() {
        case "b": self = .black
        case "w": self = .white
        default: return nil
        }
    }
    
    var reverse: GobanStoneColor {
        get {
            return self == .white ? .black : .white
        }
    }
    
    var uiColor: UIColor {
        get {
            return self == .white ? UIColor.white : UIColor.black
        }
    }
}

protocol StoneProtocol {
    var stoneColor: GobanStoneColor { get }
    var disabled: Bool { get set }
}

struct Stone: StoneProtocol {
    var stoneColor = GobanStoneColor.white
    var disabled = false
}

func ==(lhs: StoneModel, rhs: StoneModel) -> Bool {
    return lhs.gobanPoint == rhs.gobanPoint &&
        lhs.disabled == rhs.disabled &&
        lhs.layer == rhs.layer &&
        lhs.stoneColor == rhs.stoneColor
}

func ==(lhs: StoneModel, rhs: SGFP.Node) -> Bool {
    if lhs.stoneColor == GobanStoneColor.black {
        guard let property = rhs.propertyWithName(SGFMoveProperties.B.rawValue) else {
            return false
        }
        
        guard let propertyValue = property.values.first?.toMove() else {
            return false
        }
        
        if let gobanPoint = GobanPoint(col: propertyValue.col, row: propertyValue.row) {
            return gobanPoint == lhs.gobanPoint
        }
        
    } else {
        guard let property = rhs.propertyWithName(SGFMoveProperties.W.rawValue) else {
            return false
        }
        
        guard let propertyValue = property.values.first?.toMove() else {
            return false
        }
        
        if let gobanPoint = GobanPoint(col: propertyValue.col, row: propertyValue.row) {
            return gobanPoint == lhs.gobanPoint
        }
    }
    
    return false
}

internal struct StoneModel: StoneProtocol, Hashable {
    var stoneColor = GobanStoneColor.white
    var disabled = false
    var layer: CAShapeLayer
    var gobanPoint: GobanPoint
    var hashValue: Int {
        get { return "\(gobanPoint.x) \(gobanPoint.y) \(Unmanaged.passUnretained(layer).toOpaque())".hashValue }
        set { }
    }
}
