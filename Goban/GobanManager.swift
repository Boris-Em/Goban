//
//  GobanModel.swift
//  GobanSampleProject
//
//  Created by Bobo on 4/2/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import Foundation
import UIKit

class GobanManager: NSObject, GobanTouchProtocol {
    let gobanView: GobanView
    
    required init(gobanView: GobanView) {
        self.gobanView = gobanView
        super.init()
    }
    
    private(set) var stoneHistory = [StoneModel]()
    
    private var temporaryStone: StoneModel?
    
    // MARK: Stone Management
    
    func addNewStoneAtGobanPoint(gobanPoint: GobanPoint) {
        guard stoneAtGobanPoint(gobanPoint) == nil else {
            removeTemporaryStoneAnimated(false)
            return
        }
        
        let lastStone: StoneProtocol = stoneHistory.last ?? Stone(stoneColor: .White, disabled: false)
        let newStone = Stone(stoneColor: lastStone.stoneColor == .White ? .Black : . White, disabled: false)
        addStone(newStone, atGobanPoint: gobanPoint, isTemporary: false)
    }
    
    func addTemporaryStoneAtGobanPoint(gobanPoint: GobanPoint) {
        guard stoneAtGobanPoint(gobanPoint) == nil &&
            temporaryStone?.gobanPoint != gobanPoint else {
                return
        }
        
        removeTemporaryStoneAnimated(false)
        let lastStone: StoneProtocol = stoneHistory.last ?? Stone(stoneColor: .White, disabled: false)
        let newStone = Stone(stoneColor: lastStone.stoneColor == .White ? .Black : . White, disabled: true)
        addStone(newStone, atGobanPoint: gobanPoint, isTemporary: true)
    }
    
    private func addStone(stone: StoneProtocol, atGobanPoint gobanPoint: GobanPoint, isTemporary: Bool) {
        if let stoneModel = gobanView.setStone(stone, atGobanPoint: gobanPoint) {
            if isTemporary == false {
                stoneHistory.append(stoneModel)
                removeTemporaryStoneAnimated(false)
            } else {
                temporaryStone = stoneModel
            }
        }
    }
    
    func removeStone(stone: StoneModel, removeFromHistory: Bool, animated: Bool) {
        if animated {
            let animation = fadeOutAnimationForStone(stone, withCompletion: { [weak self] (stone) -> Void in
                self?.removeStone(stone, removeFromHistory: removeFromHistory)
            })
            stone.layer.addAnimation(animation, forKey: "opacity")
        } else {
            removeStone(stone, removeFromHistory: removeFromHistory)
        }
    }
    
    private func removeStone(stone: StoneModel, removeFromHistory: Bool) {
        stone.layer.removeFromSuperlayer()
        if removeFromHistory {
            if let index = stoneHistory.indexOf({ $0 == stone }) {
                stoneHistory.removeAtIndex(index)
            }
        }
    }
    
    func removeStoneAtGobanPoint(gobanPoint: GobanPoint, removeFromHistory: Bool, animated: Bool) {
        if let stone = stoneAtGobanPoint(gobanPoint) {
            removeStone(stone, removeFromHistory: removeFromHistory, animated: animated)
        }
    }
    
    func removeTemporaryStoneAnimated(animated: Bool) {
        guard temporaryStone != nil else {
            return
        }
        
        removeStone(temporaryStone!, removeFromHistory: false, animated: animated)
        temporaryStone = nil
    }
    
    func removeLastStoneAnimated(animated: Bool) {
        if let stoneModel = stoneHistory.last {
            removeStone(stoneModel, removeFromHistory: true, animated: animated)
        }
    }
    
    func removeAllStonesAnimated(animated: Bool) {
        for stoneModel in stoneHistory {
            removeStone(stoneModel, removeFromHistory: false, animated: animated)
        }
        
        removeTemporaryStoneAnimated(animated)
        stoneHistory.removeAll()
    }
    
    // MARK: GobanTouchProtocol
    
    func didTouchGobanWithClosestGobanPoint(gobanView: GobanView, atGobanPoint gobanPoint: GobanPoint) {
        addTemporaryStoneAtGobanPoint(gobanPoint)
    }
    
    func didEndTouchGobanWithClosestGobanPoint(goban: GobanView, atGobanPoint gobanPoint: GobanPoint?) {
        guard gobanPoint != nil else {
            removeTemporaryStoneAnimated(false)
            return
        }
        
        addNewStoneAtGobanPoint(gobanPoint!)
    }
    
    // MARK: Helper Methods
    
    func stoneAtGobanPoint(gobanPoint: GobanPoint) -> StoneModel? {
        let filteredArray = stoneHistory.filter({ $0.gobanPoint == gobanPoint })
        return filteredArray.first
    }
    
    // MARK: Animations
    
    private typealias animationCompletion = ((stone: StoneModel) -> Void)
    private var animationCompletions = [StoneModel: animationCompletion]()
    var animationDuration = 0.8
    
    private func fadeOutAnimationForStone(stone: StoneModel, withCompletion completion: animationCompletion?) -> CABasicAnimation {
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.0
        opacityAnimation.delegate = self
        opacityAnimation.duration = animationDuration
        opacityAnimation.fillMode = kCAFillModeForwards
        opacityAnimation.removedOnCompletion = false
        
        if completion != nil {
            opacityAnimation.setValue(stone.hashValue, forKey: "stoneId")
            animationCompletions[stone] = completion
        }
        
        return opacityAnimation
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        guard let stoneId = anim.valueForKey("stoneId") as? Int else {
            return
        }
        
        for stone in animationCompletions.keys {
            if stone.hashValue == stoneId {
                let completion = animationCompletions[stone]
                completion!(stone: stone)
                animationCompletions.removeValueForKey(stone)
            }
        }
    }
    
    // MARK: SGF
    
    private var game: SGFGameProtocol?
    
    func loadSGFFileAtURL(path: NSURL) {
        unloadSGF()
        
        var SGFString: String?
        
        do {
            SGFString = try String(contentsOfURL:path )
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
        gobanView.gobanSize = GobanSize(width: game!.boardSize!, height: game!.boardSize!)
    }
        
    func unloadSGF() {
        game = nil
        gameNodeGenerator = nil
    }

    private var gameNodeGenerator: AnyGenerator<SGFNodeProtocol>!
    
    func handleNextNode() {
        if gameNodeGenerator == nil,
            let generator = game?.nodes.generate()  {
            gameNodeGenerator = AnyGenerator(generator)
        }
        
        if let node = gameNodeGenerator.next() {
            handleNode(node)
        }
    }

    func handleNode(node: SGFNodeProtocol) {
        for (k,v) in node.simpleproperties {
            if let setup = SGFSetupProperties(rawValue: k) {
                handleSetupProperty(setup, withValue: v)
            } else if let move = SGFMoveProperties(rawValue: k) {
                handleMoveProperty(move, withValue: v)
            }
        }
    }
    
    private func handleSetupProperty(setup: SGFSetupProperties, withValue value: String) {
        switch setup {
        case .AB:
            break
        case .AE:
            break
        case .AW:
            break
        case .PL:
            break
        }
    }
    
    private func handleMoveProperty(move: SGFMoveProperties, withValue value: String) {
        switch move {
        case .B:
            if let gobanPoint = GobanPoint(SGFString: value) {
                let stone = Stone(stoneColor: .Black, disabled: false)
                addStone(stone, atGobanPoint: gobanPoint, isTemporary: false)
            }
        case .W:
            if let gobanPoint = GobanPoint(SGFString: value) {
                let stone = Stone(stoneColor: .White, disabled: false)
                addStone(stone, atGobanPoint: gobanPoint, isTemporary: false)
            }
        case .KO:
            break
        case .MN:
            break
        }
    }
    
}