//
//  GobanView.swift
//  GobanSampleProject
//
//  Created by Bobo on 3/19/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import UIKit

func ==(lhs: GobanPoint, rhs: GobanPoint) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

struct GobanPoint: Hashable {
    var x: Int = 0
    var y: Int = 0
    
    var hashValue: Int {
        get {
            return "\(self.x), \(self.y)".hashValue
        }
    }
}

struct GobanSize {
    var width: Int = 0
    var height: Int = 0
}

enum GobanStoneColor {
    case White
    case Black
}

protocol GobanTouchProtocol: class {
    func didTouchGobanWithClosestGobanPoint(goban: GobanView, atGobanPoint gobanPoint: GobanPoint)
    func didEndTouchGobanWithClosestGobanPoint(goban: GobanView, atGobanPoint gobanPoint: GobanPoint)
}

protocol GobanProtocol: class {
    func didSetStoneAtGobanPoint(gobanView: GobanView, gobanPoint: GobanPoint)
    func didRemoveStoneAtGobanPoint(gobanView: GobanView, gobanPoint: GobanPoint)
}

class GobanView: UIView {
    
    // MARK: Properties
    
    var gobanSize: GobanSize = GobanSize(width: 19, height: 19) {
        didSet {
            drawGoban()
        }
    }
    
    let lineColor = UIColor(red: 90.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
    let lineWidth: CGFloat = 2.0
    let gobanBackgroundColor = UIColor(red: 240.0 / 255.0, green: 211.0 / 255.0, blue: 159.0 / 255.0, alpha: 1.0)
    let whiteStoneColor = UIColor.whiteColor()
    let blackStoneColor = UIColor.blackColor()
    var padding: CGFloat = 0.07 {
        didSet {
            if padding > 1.0 {
                padding = 1.0
            } else if padding < 0.0 {
                padding = 0.0
            }
            
            drawGoban()
        }
    }
    
    private(set) internal var lastSetStonePlayer: GobanStoneColor?
    
    private var gridFrame: CGRect {
        get {
            return CGRectMake(frame.size.width * padding, frame.size.height * padding, frame.size.width - 2 * padding * frame.size.width, frame.size.height - 2 * padding * frame.size.height)
        }
        set { }
    }
    
    private var longPressGestureRecognizer: UILongPressGestureRecognizer?
    
    weak var gobanTouchDelegate: GobanTouchProtocol? {
        didSet {
            if longPressGestureRecognizer == nil {
                let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(GobanView.didLongPressGoban(_:)))
                longPressGestureRecognizer.minimumPressDuration = 0.0
                self.addGestureRecognizer(longPressGestureRecognizer)
            }
        }
    }
    weak var delegate: GobanProtocol?
    
    private var stones = [GobanPoint : CAShapeLayer]()
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    convenience init(size: GobanSize, frame: CGRect) {
        self.init(frame: frame)
        self.gobanSize = size
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = gobanBackgroundColor
    }
    
    // MARK: Drawings
    
    private var gridLayer = CAShapeLayer()
    
    private func drawGoban() {
        removeSubLayers()

        drawGrid()
        if padding > 0.0 {
            drawBorder()
        }
    }
    
    private func drawGrid() {
        gridLayer = layerForGridWithFrame(self.bounds, withGobanSize: gobanSize, padding: padding)
        layer.addSublayer(gridLayer)
    }
    
    private func drawBorder() {
        layer.borderWidth = lineWidth
        layer.borderColor = lineColor.CGColor
    }
    
    private func drawStoneAtGobanPoint(gobanPoint: GobanPoint, gobanStoneColor: GobanStoneColor) {
        let stoneSize = sizeForStoneWithGobanSize(gobanSize, inFrame: gridFrame)
        let stoneCenter = centerForStoneAtGobanPoint(gobanPoint, gobanSize: gobanSize, inFrame: gridFrame)
        let stoneFrame = CGRectMake(stoneCenter.x - stoneSize / 2.0, stoneCenter.y - stoneSize / 2.0, stoneSize, stoneSize)
        
        let stoneLayer = layerForStoneWithFrame(stoneFrame, color: gobanStoneColor == .White ? whiteStoneColor : blackStoneColor)
        
        stones[gobanPoint] = stoneLayer
        layer.addSublayer(stoneLayer)
    }
    
    // MARK: Layers
    
    private func layerForGridWithFrame(frame: CGRect, withGobanSize size: GobanSize, padding: CGFloat) -> CAShapeLayer {
        let gridLayer = CAShapeLayer()
        gridLayer.frame = frame
        gridLayer.path = pathForGridInRect(gridFrame, withGobanSize: size).CGPath
        gridLayer.fillColor = UIColor.clearColor().CGColor
        gridLayer.strokeColor = lineColor.CGColor
        gridLayer.lineWidth = lineWidth
        
        return gridLayer
    }
    
    private func layerForStoneWithFrame(frame: CGRect, color: UIColor) -> CAShapeLayer {
        let stoneLayer = CAShapeLayer()
        stoneLayer.frame = frame
        stoneLayer.path = pathForStoneInRect(stoneLayer.bounds).CGPath
        stoneLayer.fillColor = color.CGColor
        stoneLayer.strokeColor = UIColor.clearColor().CGColor
        
        return stoneLayer
    }
    
    // MARK: Paths
    
    private func pathForGridInRect(rect: CGRect, withGobanSize gobanSize: GobanSize) -> UIBezierPath {
        let gridPath = UIBezierPath()
        
        let heightLineInterval = rect.size.height / CGFloat(gobanSize.height - 1)
        let widthLineInterval = rect.size.width / CGFloat(gobanSize.width - 1)

        for i in 0 ..< Int(gobanSize.height) {
            gridPath.moveToPoint(CGPointMake(rect.origin.x, CGFloat(i) * heightLineInterval + rect.origin.y))
            gridPath.addLineToPoint(CGPointMake(rect.size.width + rect.origin.x, CGFloat(i) * heightLineInterval + rect.origin.y))
        }

        for i in 0 ..< Int(gobanSize.width) {
            gridPath.moveToPoint(CGPointMake(CGFloat(i) * widthLineInterval + rect.origin.x, rect.origin.y))
            gridPath.addLineToPoint(CGPointMake(CGFloat(i) * widthLineInterval + rect.origin.x, rect.size.height + rect.origin.y))
        }
        
        return gridPath
    }
    
    private func pathForStoneInRect(rect: CGRect) -> UIBezierPath {
        let stonePath = UIBezierPath(ovalInRect: rect)
        
        return stonePath
    }
    
    // MARK: Stones
    
    func setStoneAtGobanPoint(gobanPoint: GobanPoint, gobanStoneColor: GobanStoneColor, overwrite: Bool) {
        guard gobanPoint.x >= 1 && gobanPoint.x <= gobanSize.width
            && gobanPoint.y >= 1 && gobanPoint.y <= gobanSize.height
            else {
                print("setStoneAtPoint -- Point outside of Goban")
                return
        }
        
        if hasStoneAtGobanPoint(gobanPoint) {
            if overwrite {
                removeStoneAtGobanPoint(gobanPoint)
            } else {
                return
            }
        }
        
        drawStoneAtGobanPoint(gobanPoint, gobanStoneColor: gobanStoneColor)
        lastSetStonePlayer = gobanStoneColor
        delegate?.didSetStoneAtGobanPoint(self, gobanPoint: gobanPoint)
    }
    
    func hasStoneAtGobanPoint(gobanPoint: GobanPoint) -> Bool {
        return stones[gobanPoint] != nil
    }
    
    func removeStoneAtGobanPoint(gobanPoint: GobanPoint) {
        if let layer = stones[gobanPoint] {
            layer.removeFromSuperlayer()
            stones[gobanPoint] = nil
            delegate?.didRemoveStoneAtGobanPoint(self, gobanPoint: gobanPoint)
        }
    }
    
    func clearGoban() {
        for (gobanPoint, layer) in stones {
            layer.removeFromSuperlayer()
            delegate?.didRemoveStoneAtGobanPoint(self, gobanPoint: gobanPoint)
        }
        
        stones.removeAll()
    }
    
    // MARK: Gesture Recognizers
    
    func didLongPressGoban(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if self.gobanTouchDelegate != nil {
            switch longPressGestureRecognizer.state {
            case .Began, .Changed:
                let tapLocation = longPressGestureRecognizer.locationInView(longPressGestureRecognizer.view)
                if let closestGobanPoint = closestGobanPointFromPoint(tapLocation) {
                    gobanTouchDelegate?.didTouchGobanWithClosestGobanPoint(self, atGobanPoint: closestGobanPoint)
                }
                break
            case .Ended:
                let tapLocation = longPressGestureRecognizer.locationInView(longPressGestureRecognizer.view)
                if let closestGobanPoint = closestGobanPointFromPoint(tapLocation) {
                    gobanTouchDelegate?.didEndTouchGobanWithClosestGobanPoint(self, atGobanPoint: closestGobanPoint)
                }
                
                break
            default:
                break
            }
        }
    }
    
    // MARK: Helper Methods
    
    private func removeSubLayers() {
        guard layer.sublayers != nil
            else {
                return
        }
        
        for subLayer in layer.sublayers! {
            subLayer.removeFromSuperlayer()
        }
    }
    
    func closestGobanPointFromPoint(point: CGPoint) -> GobanPoint? {
        guard CGRectContainsPoint(bounds, point) else {
            return nil
        }
        
        var closestGobanX =  CGFloat(gobanSize.width - 1) / (gridFrame.size.width / (point.x - gridFrame.origin.x)) + 1
        closestGobanX = min(max(closestGobanX, 1), CGFloat(gobanSize.width))
        
        var closestGobanY = CGFloat(gobanSize.height - 1) / (gridFrame.size.height / (point.y - gridFrame.origin.y)) + 1
        closestGobanY = min(max(closestGobanY, 1), CGFloat(gobanSize.height))
        
        return GobanPoint(x: Int(round(closestGobanX)), y: Int(round(closestGobanY)))
    }
    
    // MARK: Calculations
    
    private func sizeForStoneWithGobanSize(gobanSize: GobanSize, inFrame frame: CGRect) -> CGFloat {
        let smallestGobanFrameSize = max(frame.size.width, frame.size.height)
        let smallestGobanSize = max(gobanSize.width, gobanSize.height)
        
        let stoneSize = smallestGobanFrameSize / CGFloat(smallestGobanSize)
        
        return stoneSize
    }
    
    private func centerForStoneAtGobanPoint(gobanPoint: GobanPoint, gobanSize: GobanSize, inFrame frame: CGRect) -> CGPoint {
        let heightLineInterval = frame.size.height / CGFloat(gobanSize.height - 1)
        let widthLineInterval = frame.size.width / CGFloat(gobanSize.width - 1)

        let y = heightLineInterval * CGFloat((gobanPoint.y - 1)) + frame.origin.x
        let x = widthLineInterval * CGFloat((gobanPoint.x - 1)) + frame.origin.y
        
        return CGPointMake(x, y)
    }
}
