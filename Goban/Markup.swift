//
//  Markup.swift
//  GobanSampleProject
//
//  Created by Bobo on 1/13/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import UIKit

enum MarkupType {
    case Cross
}

protocol MarkupProtocol {
    var markupColor: UIColor { get set }
    var markupType: MarkupType { get set }
}

struct Markup: MarkupProtocol {
    var markupColor = UIColor.white
    var markupType = MarkupType.Cross
}

func ==(lhs: MarkupModel, rhs: MarkupModel) -> Bool {
    return lhs.gobanPoint == rhs.gobanPoint &&
        lhs.layer == rhs.layer &&
        lhs.markupColor == rhs.markupColor &&
        lhs.markupType == rhs.markupType
}

func ==(lhs: MarkupModel, rhs: SGFP.Node) -> Bool {
    switch lhs.markupType {
    case .Cross:
        guard let property = rhs.propertyWithName(SGFMarkupProperties.MA.rawValue) else {
            return false
        }
        
        guard let propertyValue = property.values.first?.toPoint() else {
            return false
        }
        
        if let gobanPoint = GobanPoint(col: propertyValue.col, row: propertyValue.row) {
            return gobanPoint == lhs.gobanPoint
        }
        break
    }
    
    return false
}

internal struct MarkupModel: MarkupProtocol, Hashable {
    var markupColor = UIColor.white
    var markupType = MarkupType.Cross
    var layer: CAShapeLayer
    var gobanPoint: GobanPoint
    var hashValue: Int {
        get { return "\(gobanPoint.x) \(gobanPoint.y) \(Unmanaged.passUnretained(layer).toOpaque())".hashValue }
        set { }
    }
}
