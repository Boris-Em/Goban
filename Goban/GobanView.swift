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
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    init?(col: Character, row: Character) {
        if let colIndex = GobanPoint.indexForCharacter(col),
            let rowIndex = GobanPoint.indexForCharacter(row) {
            x = colIndex
            y = rowIndex
        } else {
            return nil
        }
    }
    
    init?(SGFString: String) {
        guard SGFString.count == 2 else {
            return nil
        }

        self.init(col: SGFString.first!, row: SGFString.last!)
    }
    
    // MARK: Helpers
    
    static func indexForCharacter(_ character: Character) -> Int? {
        let alphabet = "abcdefghijklmnopqrstuvwxyz"
        
        if let indexForCharacterInString = alphabet.index(of: character) {
            return alphabet.distance(from: alphabet.startIndex, to: indexForCharacterInString) + 1
        }
        
        return nil
    }
    
    static func pointsFromCompressPoints(_ compressPoints: (upperLeftCol: Character, upperLeftRow: Character, lowerRightCol: Character, lowerRightRow: Character)) -> Set<GobanPoint>? {
        let indices = [compressPoints.upperLeftCol, compressPoints.upperLeftRow, compressPoints.lowerRightCol, compressPoints.lowerRightRow].map(GobanPoint.indexForCharacter)
        
        guard indices.filter({$0 != nil}).count == 4 else {
            return nil
        }
        
        var points = Set<GobanPoint>()
        
        for col in indices[0]! ... indices[2]! {
            for row in indices[1]! ... indices[3]! {
                points.insert(GobanPoint(x: col, y: row))
            }
        }
        
        return points
    }
    
}

struct GobanSize {
    var width: Int = 0
    var height: Int = 0
}

protocol GobanTouchProtocol: class {
    func didTouchGobanWithClosestGobanPoint(_ goban: GobanView, atGobanPoint gobanPoint: GobanPoint)
    func didEndTouchGobanWithClosestGobanPoint(_ goban: GobanView, atGobanPoint gobanPoint: GobanPoint?)
}

/** The delegate of a `GobanView` must adopt the `GobanTouchProtocol`.
The protocol allows the delegate to get information about when a stone gets set.
 */
protocol GobanProtocol: class {
    func gobanView(_ gobanView: GobanView, didSetStone stone: StoneModel, atGobanPoint gobanPoint: GobanPoint, isUserInitiated:Bool)
    func gobanView(_ gobanView: GobanView, didSetMarkup markup: MarkupModel, atGobanPoint gobanPoint: GobanPoint, isUserInitiated:Bool)
}

/** `GobanView` is used to create highly custmizable Goban representations.
 */
class GobanView: UIView {
    
    // MARK: Variables
    
    /** The actual size of the goban. That is, the number of lines that composes each side of the board.
    Setting this variable to a new value will redraw the `GobanView`.
    If `gobanSize` is set to a common size (9x9, 13x13 or 19x19), the star points will be automatically calculated. Defaults to 19x19.
    - SeeAlso: `startPoints`
    */
    var gobanSize: GobanSize = GobanSize(width: 19, height: 19) {
        didSet {
            if gobanSize.width == 9 && gobanSize.height == 9 {
                self.starPoints = [GobanPoint(x: 3, y: 3), GobanPoint(x: 7, y: 3), GobanPoint(x: 5, y: 5), GobanPoint(x: 3, y: 7), GobanPoint(x: 7, y: 7)]
            } else if gobanSize.width == 13 && gobanSize.height == 13 {
                self.starPoints = [GobanPoint(x: 4, y: 4), GobanPoint(x: 10, y: 4), GobanPoint(x: 7, y: 7), GobanPoint(x: 4, y: 10), GobanPoint(x: 10, y: 10)]
            } else if gobanSize.width == 19 && gobanSize.height == 19 {
                self.starPoints = [GobanPoint(x: 4, y: 4), GobanPoint(x: 10, y: 4), GobanPoint(x: 16, y: 4), GobanPoint(x: 4, y: 10), GobanPoint(x: 10, y: 10), GobanPoint(x: 16, y: 10), GobanPoint(x: 4, y: 16), GobanPoint(x: 10, y: 16), GobanPoint(x: 16, y: 16)]
            }
            drawGoban()
        }
    }
    
    /** An array of positions for the star points on the Goban to be drawn. Defautls to an empty array.
     - SeeAlso: `gobanSize`
     */
    var starPoints = [GobanPoint]() {
        didSet {
            drawStarPoints()
        }
    }
    
    /** The color of the lines (grid) on the goban. Defaults to R:0.35, G: 0.35, B: 0.35, A: 1.0.
     */
    let lineColor = UIColor(red: 90.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
    
    /** The width of the lines (grid) on the goban. Defaults to 2.0.
     */
    let lineWidth: CGFloat = 2.0
    
    /** The background color of the goban. Defaults to R:0.96, G: 0.82, B: 0.63, A: 1.0.
     */
    let gobanBackgroundColor = UIColor(red: 240.0 / 255.0, green: 211.0 / 255.0, blue: 159.0 / 255.0, alpha: 1.0)
    
    /** The color of the white stones. Defaults to white.
     */
    let whiteStoneColor = UIColor.white
    
    /** The color of the black stones. Defaults to black.
     */
    let blackStoneColor = UIColor.black
    
    /** The duration in seconds of the animation when a stone gets set. Defaults to 0.35.
    */
    public var animationDuration = 0.35
    
    /** The empty space between the grid and the actual goban limits as a percentage of the goban size. Defaults to 0.07.
     */
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
    
    /** The frame of the grid on the goban.
     */
    fileprivate var gridFrame: CGRect {
        get {
            return CGRect(x: frame.size.width * padding, y: frame.size.height * padding, width: frame.size.width - 2 * padding * frame.size.width, height: frame.size.height - 2 * padding * frame.size.height)
        }
        set { }
    }

    /** Gesture recognizer used to track user inputs on the goban.
    - SeeAlso: `gobanTouchDelegate`
     */
    fileprivate var longPressGestureRecognizer: UILongPressGestureRecognizer?
    
    /** The object that acts as the delegate for touch inputs on `GobanView`.
    - SeeAlso: `GobanTouchProtocol`
     */
    weak var gobanTouchDelegate: GobanTouchProtocol? {
        didSet {
            if longPressGestureRecognizer == nil {
                let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(GobanView.didLongPressGoban(_:)))
                longPressGestureRecognizer.minimumPressDuration = 0.0
                self.addGestureRecognizer(longPressGestureRecognizer)
            }
        }
    }
    
    /** The object that acts as the delegate of `GobanView`.
    - SeeAlso: `GobanProtocol`
     */
    weak var delegate: GobanProtocol?
    
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
    
    fileprivate func commonInit() {
        backgroundColor = gobanBackgroundColor
        layer.masksToBounds = true
    }
    
    // MARK: Drawings
    
    fileprivate var gridLayer = CAShapeLayer()
    fileprivate var starPointsLayer = CAShapeLayer()
    
    override func draw(_ rect: CGRect) {
        drawGoban()
    }
    
    fileprivate func drawGoban() {
        removeSubLayers()

        drawGrid()
        drawStarPoints()
        if padding > 0.0 {
            drawBorder()
        }
    }
    
    fileprivate func drawGrid() {
        gridLayer.removeFromSuperlayer()
        gridLayer = layerForGridWithFrame(self.bounds, withGobanSize: gobanSize, padding: padding)
        layer.addSublayer(gridLayer)
    }
    
    fileprivate func drawStarPoints() {
        starPointsLayer.removeFromSuperlayer()
        starPointsLayer = layerForStartPointsWithFrame(self.bounds, withGobanSize: gobanSize, padding: padding, starPoints: starPoints)
        layer.addSublayer(starPointsLayer)
    }
    
    fileprivate func drawBorder() {
        layer.borderWidth = lineWidth
        layer.borderColor = lineColor.cgColor
    }
    
    fileprivate func drawStone(_ stone: StoneProtocol, atGobanPoint gobanPoint: GobanPoint, animated: Bool) -> StoneModel {
        let stoneSize = sizeForStoneWithGobanSize(gobanSize, inFrame: gridFrame)
        let stoneCenter = centerForStoneAtGobanPoint(gobanPoint, gobanSize: gobanSize, inFrame: gridFrame)
        let stoneFrame = CGRect(x: stoneCenter.x - stoneSize / 2.0, y: stoneCenter.y - stoneSize / 2.0, width: stoneSize, height: stoneSize)
        
        let stoneLayer = layerForStoneWithFrame(stoneFrame, color: colorForStone(stone))
        if animated {
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 0.0
            animation.toValue = 1.0
            animation.duration = animationDuration
            stoneLayer.add(animation ,forKey: "opacity")
        }
        
        let stoneModel = StoneModel(stoneColor: stone.stoneColor, disabled: stone.disabled, layer: stoneLayer, gobanPoint: gobanPoint)
        
        layer.addSublayer(stoneLayer)
        
        return stoneModel
    }
    
    fileprivate func drawMarkup(_ markup: MarkupProtocol, atGobanPoint gobanPoint: GobanPoint) -> MarkupModel {
        let markupSize = sizeForMarkupWithGobanSize(gobanSize, inFrame: gridFrame)
        let markupCenter = centerForStoneAtGobanPoint(gobanPoint, gobanSize: gobanSize, inFrame: gridFrame)
        let markupFrame = CGRect(x: markupCenter.x - markupSize / 2.0, y: markupCenter.y - markupSize / 2.0, width: markupSize, height: markupSize)
        
        let markupLayer = layerForMarkupWithFrame(markupFrame, color: markup.markupColor, markupType: markup.markupType)
        
        let markupModel = MarkupModel(markupColor: markup.markupColor, markupType: markup.markupType, layer: markupLayer, gobanPoint: gobanPoint)
        
        layer.addSublayer(markupLayer)
        
        return markupModel
    }
    
    func reload() {
        drawGoban()
    }
    
    // MARK: Layers
    
    fileprivate func layerForGridWithFrame(_ frame: CGRect, withGobanSize size: GobanSize, padding: CGFloat) -> CAShapeLayer {
        let gridLayer = CAShapeLayer()
        gridLayer.frame = frame
        gridLayer.path = pathForGridInRect(gridFrame, withGobanSize: size).cgPath
        gridLayer.fillColor = UIColor.clear.cgColor
        gridLayer.strokeColor = lineColor.cgColor
        gridLayer.lineWidth = lineWidth
        
        return gridLayer
    }
    
    fileprivate func layerForStartPointsWithFrame(_ frame: CGRect, withGobanSize size: GobanSize, padding: CGFloat, starPoints: [GobanPoint]) -> CAShapeLayer {
        let starPointsLayer = CAShapeLayer()
        starPointsLayer.frame = frame
        starPointsLayer.path = pathForStarPointsInRect(gridFrame, withGobanSize: gobanSize, starPoints: starPoints).cgPath
        starPointsLayer.fillColor = lineColor.cgColor
        
        return starPointsLayer
    }
    
    fileprivate func layerForStoneWithFrame(_ frame: CGRect, color: UIColor) -> CAShapeLayer {
        let stoneLayer = CAShapeLayer()
        stoneLayer.frame = frame
        stoneLayer.path = pathForStoneInRect(stoneLayer.bounds).cgPath
        stoneLayer.fillColor = color.cgColor
        stoneLayer.strokeColor = UIColor.clear.cgColor
        
        return stoneLayer
    }
    
    fileprivate func layerForMarkupWithFrame(_ frame: CGRect, color: UIColor, markupType: MarkupType) -> CAShapeLayer {
        let markupLayer = CAShapeLayer()
        markupLayer.frame = frame
        markupLayer.path = pathForMarkupInRect(markupLayer.bounds, markupType: markupType).cgPath
        markupLayer.fillColor = color.cgColor
        markupLayer.strokeColor = UIColor.clear.cgColor
        
        return markupLayer
    }
    
    // MARK: Paths
    
    fileprivate func pathForGridInRect(_ rect: CGRect, withGobanSize gobanSize: GobanSize) -> UIBezierPath {
        let gridPath = UIBezierPath()
        
        let heightLineInterval = rect.size.height / CGFloat(gobanSize.height - 1)
        let widthLineInterval = rect.size.width / CGFloat(gobanSize.width - 1)

        for i in 0 ..< Int(gobanSize.height) {
            gridPath.move(to: CGPoint(x: rect.origin.x, y: CGFloat(i) * heightLineInterval + rect.origin.y))
            gridPath.addLine(to: CGPoint(x: rect.size.width + rect.origin.x, y: CGFloat(i) * heightLineInterval + rect.origin.y))
        }

        for i in 0 ..< Int(gobanSize.width) {
            gridPath.move(to: CGPoint(x: CGFloat(i) * widthLineInterval + rect.origin.x, y: rect.origin.y))
            gridPath.addLine(to: CGPoint(x: CGFloat(i) * widthLineInterval + rect.origin.x, y: rect.size.height + rect.origin.y))
        }
        
        return gridPath
    }
    
    fileprivate func pathForStarPointsInRect(_ rect: CGRect, withGobanSize gobanSize: GobanSize, starPoints: [GobanPoint]) -> UIBezierPath {
        let starPointsPath = UIBezierPath()
        let starSize = sizeForStarPointWithGobanSize(gobanSize, inFrame: rect)
        for gobanPoint in starPoints {
            let point = centerForStoneAtGobanPoint(gobanPoint, gobanSize: gobanSize, inFrame: rect)
            starPointsPath.append(UIBezierPath(ovalIn: CGRect(x: point.x - starSize / 2.0, y: point.y - starSize / 2.0, width: starSize, height: starSize)))
        }
        
        return starPointsPath
    }
    
    fileprivate func pathForStoneInRect(_ rect: CGRect) -> UIBezierPath {
        let stonePath = UIBezierPath(ovalIn: rect)
        
        return stonePath
    }
    
    fileprivate func pathForMarkupInRect(_ rect: CGRect, markupType: MarkupType) -> UIBezierPath {
        switch markupType {
        case .Cross:
            let widthRatio: CGFloat = 5.0
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: rect.size.width - rect.size.width / widthRatio, y: 0.0))
            bezierPath.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height / widthRatio))
            bezierPath.addLine(to: CGPoint(x: rect.size.width / widthRatio, y: rect.size.height))
            bezierPath.addLine(to: CGPoint(x: 0.0, y: rect.size.height - rect.size.height / widthRatio))
            bezierPath.close()
            
            bezierPath.move(to: CGPoint(x: rect.size.width / widthRatio, y: 0.0))
            bezierPath.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height - rect.size.height / 10.0))
            bezierPath.addLine(to: CGPoint(x: rect.size.width - rect.size.width / widthRatio, y: rect.size.height))
            bezierPath.addLine(to: CGPoint(x: 0.0, y: rect.size.height / widthRatio))
            bezierPath.close()
            
            return bezierPath
        case .Dot:
            return UIBezierPath(ovalIn: rect)
            
        }
    }
    
    // MARK: Stones
    
    func setStone(_ stone: StoneProtocol, atGobanPoint gobanPoint: GobanPoint, isUserInitiated:Bool, animated: Bool, completion:((_ stoneModel: StoneModel?) -> ())?) {
        guard gobanPoint.x >= 1 && gobanPoint.x <= gobanSize.width
            && gobanPoint.y >= 1 && gobanPoint.y <= gobanSize.height
            else {
                print("setStoneAtPoint -- Point outside of Goban")
                completion?(nil)
                return
        }
        
        let stoneModel = drawStone(stone, atGobanPoint: gobanPoint, animated: animated)
        completion?(stoneModel)
        delegate?.gobanView(self, didSetStone: stoneModel, atGobanPoint: gobanPoint, isUserInitiated: isUserInitiated)
    }
    
    func setMarkup(_ markup: MarkupProtocol, atGobanPoint gobanPoint: GobanPoint, isUserInitiated:Bool, completion:((_ markupModel: MarkupModel?) -> ())?) -> MarkupModel? {
        guard gobanPoint.x >= 1 && gobanPoint.x <= gobanSize.width
            && gobanPoint.y >= 1 && gobanPoint.y <= gobanSize.height
            else {
                print("setStoneAtPoint -- Point outside of Goban")
                completion?(nil)
                return nil
        }
        
        let markupModel = drawMarkup(markup, atGobanPoint: gobanPoint)
        completion?(markupModel)
        delegate?.gobanView(self, didSetMarkup: markupModel, atGobanPoint: gobanPoint, isUserInitiated: isUserInitiated)
        return markupModel
    }
    
    // MARK: Gesture Recognizers
    
    @objc func didLongPressGoban(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if self.gobanTouchDelegate != nil {
            switch longPressGestureRecognizer.state {
            case .began:
                break
            case .changed:
                let tapLocation = longPressGestureRecognizer.location(in: longPressGestureRecognizer.view)
                if let closestGobanPoint = closestGobanPointFromPoint(tapLocation) {
                    gobanTouchDelegate?.didTouchGobanWithClosestGobanPoint(self, atGobanPoint: closestGobanPoint)
                }
                break
            case .ended:
                let tapLocation = longPressGestureRecognizer.location(in: longPressGestureRecognizer.view)
                let closestGobanPoint = closestGobanPointFromPoint(tapLocation)
                gobanTouchDelegate?.didEndTouchGobanWithClosestGobanPoint(self, atGobanPoint: closestGobanPoint)
                
                break
            default:
                break
            }
        }
    }
    
    // MARK: Helper Methods
    
    fileprivate func removeSubLayers() {
        guard layer.sublayers != nil
            else {
                return
        }
        
        for subLayer in layer.sublayers! {
            subLayer.removeFromSuperlayer()
        }
    }
    
    func closestGobanPointFromPoint(_ point: CGPoint) -> GobanPoint? {
        guard bounds.contains(point) else {
            return nil
        }
        
        var closestGobanX =  CGFloat(gobanSize.width - 1) / (gridFrame.size.width / (point.x - gridFrame.origin.x)) + 1
        closestGobanX = min(max(closestGobanX, 1), CGFloat(gobanSize.width))
        
        var closestGobanY = CGFloat(gobanSize.height - 1) / (gridFrame.size.height / (point.y - gridFrame.origin.y)) + 1
        closestGobanY = min(max(closestGobanY, 1), CGFloat(gobanSize.height))
        
        return GobanPoint(x: Int(round(closestGobanX)), y: Int(round(closestGobanY)))
    }
    
    fileprivate func colorForStone(_ stone: StoneProtocol) -> UIColor {
        let alpha: CGFloat = stone.disabled == true ? 0.7 : 1.0
        let color = stone.stoneColor == GobanStoneColor.white ? whiteStoneColor : blackStoneColor
        
        return color.withAlphaComponent(alpha)
    }
    
    // MARK: Calculations
    
    fileprivate func sizeForStoneWithGobanSize(_ gobanSize: GobanSize, inFrame frame: CGRect) -> CGFloat {
        let smallestGobanFrameSize = max(frame.size.width, frame.size.height)
        let smallestGobanSize = max(gobanSize.width, gobanSize.height)
        
        let stoneSize = smallestGobanFrameSize / CGFloat(smallestGobanSize)
        
        return stoneSize
    }
    
    fileprivate func sizeForMarkupWithGobanSize(_ gobanSize: GobanSize, inFrame frame: CGRect) -> CGFloat {
        return sizeForStoneWithGobanSize(gobanSize, inFrame: frame) / 3.0
    }
    
    fileprivate func sizeForStarPointWithGobanSize(_ gobanSize: GobanSize, inFrame frame: CGRect) -> CGFloat {
        return sizeForStoneWithGobanSize(gobanSize, inFrame: frame) / 2.0
    }
    
    fileprivate func centerForStoneAtGobanPoint(_ gobanPoint: GobanPoint, gobanSize: GobanSize, inFrame frame: CGRect) -> CGPoint {
        let heightLineInterval = frame.size.height / CGFloat(gobanSize.height - 1)
        let widthLineInterval = frame.size.width / CGFloat(gobanSize.width - 1)

        let y = heightLineInterval * CGFloat((gobanPoint.y - 1)) + frame.origin.x
        let x = widthLineInterval * CGFloat((gobanPoint.x - 1)) + frame.origin.y
        
        return CGPoint(x: x, y: y)
    }
}
