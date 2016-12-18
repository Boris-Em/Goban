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
