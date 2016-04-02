//
//  Stone.swift
//  GobanSampleProject
//
//  Created by Bobo on 4/2/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import UIKit

enum GobanStoneColor {
    case White
    case Black
}

protocol StoneProtocol {
    var stoneColor: GobanStoneColor { get }
    var disabled: Bool { get set }
}

struct Stone: StoneProtocol {
    var stoneColor = GobanStoneColor.White
    var disabled = false
}

internal struct StoneModel: StoneProtocol {
    var stoneColor = GobanStoneColor.White
    var disabled = false
    var layer: CAShapeLayer?
    var gobanPoint: GobanPoint?    
}
