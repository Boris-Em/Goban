//
//  GobanModel.swift
//  GobanSampleProject
//
//  Created by Bobo on 4/2/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import Foundation
import UIKit

class GobanManager: NSObject, GobanTouchProtocol, CAAnimationDelegate {
    let gobanView: GobanView
    
    required init(gobanView: GobanView) {
        self.gobanView = gobanView
        super.init()
    }
    
    fileprivate(set) var stoneHistory = [StoneModel]()
    
    fileprivate var temporaryStone: StoneModel?
    
    // MARK: Stone Management
    
    func addNewStoneAtGobanPoint(_ gobanPoint: GobanPoint, isUserInitiated: Bool) {
        guard stoneAtGobanPoint(gobanPoint) == nil else {
            removeTemporaryStoneAnimated(false)
            return
        }
        
        addStone(newStone(disabled: false), atGobanPoint: gobanPoint, isTemporary: false, isUserInitiated: isUserInitiated)
    }
    
    func addTemporaryStoneAtGobanPoint(_ gobanPoint: GobanPoint, isUserInitiated: Bool) {
        guard stoneAtGobanPoint(gobanPoint) == nil &&
            temporaryStone?.gobanPoint != gobanPoint else {
                return
        }
        
        removeTemporaryStoneAnimated(false)
        addStone(newStone(disabled: true), atGobanPoint: gobanPoint, isTemporary: true, isUserInitiated:isUserInitiated)
    }
    
    fileprivate func addStone(_ stone: StoneProtocol, atGobanPoint gobanPoint: GobanPoint, isTemporary: Bool, isUserInitiated: Bool) {
        gobanView.setStone(stone, atGobanPoint: gobanPoint, isUserInitiated: isUserInitiated, completion: { [weak self] stoneModel in
            if let stoneModel = stoneModel {
                if isTemporary == false {
                    self?.stoneHistory.append(stoneModel)
                    self?.removeTemporaryStoneAnimated(false)
                    self?._nextStoneColor = nil
                } else {
                    self?.temporaryStone = stoneModel
                }
            }
        })
    }
    
    fileprivate func addMarkup(_ markup: MarkupProtocol, atGobanPoint gobanPoint: GobanPoint) {
        gobanView.setMarkup(markup, atGobanPoint: gobanPoint, completion: nil)
    }
        
    func removeStone(_ stone: StoneModel, removeFromHistory: Bool, animated: Bool) {
        if animated {
            let animation = fadeOutAnimationForStone(stone, withCompletion: { [weak self] (stone) -> Void in
                self?.removeStone(stone, removeFromHistory: removeFromHistory)
            })
            stone.layer.add(animation, forKey: "opacity")
        } else {
            removeStone(stone, removeFromHistory: removeFromHistory)
        }
    }
    
    fileprivate func removeStone(_ stone: StoneModel, removeFromHistory: Bool) {
        stone.layer.removeFromSuperlayer()
        if removeFromHistory {
            if let index = stoneHistory.index(where: { $0 == stone }) {
                stoneHistory.remove(at: index)
            }
        }
    }
    
    func removeStoneAtGobanPoint(_ gobanPoint: GobanPoint, removeFromHistory: Bool, animated: Bool) {
        if let stone = stoneAtGobanPoint(gobanPoint) {
            removeStone(stone, removeFromHistory: removeFromHistory, animated: animated)
        }
    }
    
    func removeTemporaryStoneAnimated(_ animated: Bool) {
        guard temporaryStone != nil else {
            return
        }
        
        removeStone(temporaryStone!, removeFromHistory: false, animated: animated)
        temporaryStone = nil
    }
    
    func removeLastStoneAnimated(_ animated: Bool) {
        if let stoneModel = stoneHistory.last {
            removeStone(stoneModel, removeFromHistory: true, animated: animated)
        }
    }
    
    func removeAllStonesAnimated(_ animated: Bool) {
        for stoneModel in stoneHistory {
            removeStone(stoneModel, removeFromHistory: false, animated: animated)
        }
        
        removeTemporaryStoneAnimated(animated)
        stoneHistory.removeAll()
    }
    
    private var _nextStoneColor: GobanStoneColor?
    
    var nextStoneColor: GobanStoneColor {
        get {
            guard _nextStoneColor == nil else {
                return _nextStoneColor!
            }
            
            return stoneColor(after: lastStone)
        }
        set (newValue) {
            _nextStoneColor = newValue
        }
    }
    
    func stoneColor(after stone:StoneProtocol?) -> GobanStoneColor {
        guard stone != nil else {
            return GobanStoneColor.black
        }
        
        return stone!.stoneColor == .white ? .black : .white
    }
    
    var lastStone: StoneModel? {
        return stoneHistory.last
    }
    
    func newStone(disabled: Bool) -> Stone {
        return Stone(stoneColor: nextStoneColor, disabled: disabled)
    }
    
    // MARK: GobanTouchProtocol
    
    func didTouchGobanWithClosestGobanPoint(_ gobanView: GobanView, atGobanPoint gobanPoint: GobanPoint) {
        addTemporaryStoneAtGobanPoint(gobanPoint, isUserInitiated: true)
    }
    
    func didEndTouchGobanWithClosestGobanPoint(_ goban: GobanView, atGobanPoint gobanPoint: GobanPoint?) {
        guard let gobanPoint = gobanPoint else {
            removeTemporaryStoneAnimated(false)
            return
        }
        
        addNewStoneAtGobanPoint(gobanPoint, isUserInitiated: true)
    }
    
    // MARK: Helper Methods
    
    func stoneAtGobanPoint(_ gobanPoint: GobanPoint) -> StoneModel? {
        let filteredArray = stoneHistory.filter({ $0.gobanPoint == gobanPoint })
        return filteredArray.first
    }
    
    // MARK: Animations
    
    fileprivate typealias animationCompletion = ((_ stone: StoneModel) -> Void)
    fileprivate var animationCompletions = [StoneModel: animationCompletion]()
    var animationDuration = 0.8
    
    fileprivate func fadeOutAnimationForStone(_ stone: StoneModel, withCompletion completion: animationCompletion?) -> CABasicAnimation {
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.0
        opacityAnimation.delegate = self
        opacityAnimation.duration = animationDuration
        opacityAnimation.fillMode = kCAFillModeForwards
        opacityAnimation.isRemovedOnCompletion = false
        
        if completion != nil {
            opacityAnimation.setValue(stone.hashValue, forKey: "stoneId")
            animationCompletions[stone] = completion
        }
        
        return opacityAnimation
    }
    
    // MARK: CAAnimationDelegate
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let stoneId = anim.value(forKey: "stoneId") as? Int else {
            return
        }
        
        for stone in animationCompletions.keys {
            if stone.hashValue == stoneId {
                let completion = animationCompletions[stone]
                completion!(stone)
                animationCompletions.removeValue(forKey: stone)
            }
        }
    }
    
    // MARK: SGF
    
    fileprivate var game: SGFP.GameTree?
    
    func loadSGFFileAtURL(_ path: URL) {
        unloadSGF()
        
        var SGFString: String?
        
        do {
            SGFString = try String(contentsOf:path )
        } catch {
        }
        
        guard SGFString != nil else {
            return
        }
        
        let parser = SGFParserCombinator.collectionParser()
        guard let collection = Array(parser.parse(SGFString!.slice)).first?.0 else {
            return
        }
        
        game = collection.games.first
        
        removeAllStonesAnimated(false)
        gobanView.gobanSize = GobanSize(width: game?.boardSize ?? 19, height: game?.boardSize ?? 19)
    }
        
    func unloadSGF() {
        game = nil
        currentPath = []
    }

    private(set) public var currentPath: [Int] = []
    private var nextPath: [Int]? {
        get {
            return nextPaths?.first
        }
    }
    private var nextPaths: [[Int]]? {
        get {
            var currentPath = self.currentPath
            
            guard currentPath.count > 0  else {
                guard let count = game?.sequence.nodes.count, count > 0 else {
                    return nil
                }
                
                return [[0]]
            }
            
            let nodeIndex = currentPath.last!
            if let currentSequence = game?.game(forPath: currentPath)?.sequence {
                if currentSequence.nodes.count > nodeIndex + 1 {
                    currentPath[currentPath.count - 1] = nodeIndex + 1
                    return [currentPath]
                } else if currentSequence.games.count > 0 {
                    var paths = [[Int]]()
                    for (index, _) in currentSequence.games.enumerated() {
                        var path = currentPath
                        path.insert(index, at: path.count - 1)
                        path[currentPath.count] = 0
                        paths.append(path)
                    }
                    
                    return paths
                }
            }
            return nil
        }
    }
    private var currentIndex: Int? {
        get {
            return currentPath.last
        }
    }
    private func nextNode(tracked: Bool) -> SGFP.Node? {
        if let nextPath = self.nextPath {
            if tracked {
                currentPath = nextPath
            }
            return game?.node(forPath: nextPath)
        }
        
        return nil
    }
    
    var nextNode: SGFP.Node? {
        get {
            return nextNode(tracked: false)
        }
    }
    
    var nextNodes: [SGFP.Node]? {
        get {
            guard let nextPaths = self.nextPaths, nextPaths.count > 0 else {
                return nil
            }
            
            var nodes = Array<SGFP.Node>()
            for path in nextPaths {
                if let node = game?.node(forPath: path) {
                    nodes.append(node)
                }
            }
            
            return nodes
        }
    }
    
    func handleNextNode() {
        if let node = nextNode(tracked: true) {
            handleNode(node)
        }
    }
        
    func skipNextStone(at variationIndex: Int?) {
        guard let nextPaths = nextPaths else {
            return
        }
        
        let variationIndex = variationIndex ?? 0
        
        if nextPaths.count > variationIndex {
            currentPath = nextPaths[variationIndex]
        }
    }
    
    func handleNode(_ node: SGFP.Node) {
        node.properties.forEach { (property) in
            if let _ = SGFSetupProperties(rawValue: property.identifier) {
                handleSetupProperty(property)
            } else if let _ = SGFMoveProperties(rawValue: property.identifier) {
                handleMoveProperty(property)
            } else if let _ = SGFMarkupProperties(rawValue: property.identifier) {
                handleMarkupProperty(property)
            }
        }
    }
    
    fileprivate func handleSetupProperty(_ property: SGFP.Property) {
        switch SGFSetupProperties(rawValue: property.identifier)! {
        case .AB:
            property.values.forEach({ (value) in
                if let (col, row) = value.toPoint(), let gobanPoint = GobanPoint(SGFString: "\(col)\(row)") {
                    let stone = Stone(stoneColor: .black, disabled: false)
                    addStone(stone, atGobanPoint: gobanPoint, isTemporary: false, isUserInitiated: false)
                } else if let compressPoints = value.toCompresedPoints() {
                    if let points = GobanPoint.pointsFromCompressPoints(compressPoints) {
                        let stone = Stone(stoneColor: .black, disabled: false)
                        for point in points {
                            addStone(stone, atGobanPoint: point, isTemporary: false, isUserInitiated: false)
                        }
                    }
                }
            })
            break
        case .AE:
            property.values.forEach({ (value) in
                if let (col, row) = value.toPoint(), let gobanPoint = GobanPoint(SGFString: "\(col)\(row)") {
                    removeStoneAtGobanPoint(gobanPoint, removeFromHistory: false, animated: true)
                } else if let compressPoints = value.toCompresedPoints() {
                    if let points = GobanPoint.pointsFromCompressPoints(compressPoints) {
                        for point in points {
                            removeStoneAtGobanPoint(point, removeFromHistory: false, animated: true)
                        }
                    }
                }
            })
            break
        case .AW:
            property.values.forEach({ (value) in
                if let (col, row) = value.toPoint(), let gobanPoint = GobanPoint(SGFString: "\(col)\(row)") {
                    let stone = Stone(stoneColor: .white, disabled: false)
                    addStone(stone, atGobanPoint: gobanPoint, isTemporary: false, isUserInitiated: false)
                } else if let compressPoints = value.toCompresedPoints() {
                    if let points = GobanPoint.pointsFromCompressPoints(compressPoints) {
                        let stone = Stone(stoneColor: .white, disabled: false)
                        for point in points {
                            addStone(stone, atGobanPoint: point, isTemporary: false, isUserInitiated: false)
                        }
                    }
                }
            })
            break
        case .PL:
            if property.values.count != 1 {
                NSLog("unhandled: Player To Play has \(property.values.count) values")
            }
            if let color = property.values.first?.toColor() {
                _nextStoneColor = GobanStoneColor(string: color)
            }
            break
        }
    }
    
    fileprivate func handleMoveProperty(_ property: SGFP.Property) {
        switch SGFMoveProperties(rawValue: property.identifier)! {
        case .B:
            if property.values.count != 1 {
                NSLog("unhandled: Move has \(property.values.count) values")
            }
            if let (col,row) = property.values.first?.toPoint(), let gobanPoint = GobanPoint(SGFString: "\(col)\(row)") {
                let stone = Stone(stoneColor: .black, disabled: false)
                addStone(stone, atGobanPoint: gobanPoint, isTemporary: false, isUserInitiated: false)
            }
            break
        case .W:
            if property.values.count != 1 {
                NSLog("unhandled: Move has \(property.values.count) values")
            }
            if let (col,row) = property.values.first?.toPoint(), let gobanPoint = GobanPoint(SGFString: "\(col)\(row)") {
                let stone = Stone(stoneColor: .white, disabled: false)
                addStone(stone, atGobanPoint: gobanPoint, isTemporary: false, isUserInitiated: false)
            }
            break
        case .KO:
            break
        case .MN:
            break
        }
    }
    
    fileprivate func handleMarkupProperty(_ property: SGFP.Property) {
        switch SGFMarkupProperties(rawValue: property.identifier)! {
        case .MA:
            property.values.forEach({ (value) in
                if let (col, row) = value.toPoint(), let gobanPoint = GobanPoint(SGFString: "\(col)\(row)") {
                    let markup = Markup(markupColor: UIColor.white, markupType: MarkupType.Cross)
                    addMarkup(markup, atGobanPoint: gobanPoint)
                } else if let compressPoints = value.toCompresedPoints() {
                    if let points = GobanPoint.pointsFromCompressPoints(compressPoints) {
                        for point in points {
                            let markup = Markup(markupColor: UIColor.white, markupType: MarkupType.Cross)
                            addMarkup(markup, atGobanPoint: point)
                        }
                    }
                }
            })
            break
        default:
            break
        }
    }
    
}
