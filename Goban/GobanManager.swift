//
//  GobanModel.swift
//  GobanSampleProject
//
//  Created by Bobo on 4/2/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import Foundation

class GobanManager: NSObject, GobanTouchProtocol {
    let gobanView: GobanView
    
    required init(gobanView: GobanView) {
        self.gobanView = gobanView
        super.init()
    }
    
    private(set) var stoneHistory = [StoneModel]()
    
    private var temporaryStone: StoneModel?
    
    // MARK: Stones Management
    
    func addNewStoneAtGobanPoint(gobanPoint: GobanPoint) {
        guard stoneAtGobanPoint(gobanPoint) == nil else {
            return
        }
        
        let lastStone: StoneProtocol = stoneHistory.last ?? Stone(stoneColor: .White, disabled: false)
        let newStone = Stone(stoneColor: lastStone.stoneColor == .White ? .Black : . White, disabled: false)
        addStone(newStone, atGobanPoint: gobanPoint, isTemporary: false)
    }
    
    func AddTemporaryStoneAtGobanPoint(gobanPoint: GobanPoint) {
        guard stoneAtGobanPoint(gobanPoint) == nil &&
            temporaryStone?.gobanPoint != gobanPoint else {
                return
        }
        
        removeTemporaryStone()
        let lastStone: StoneProtocol = stoneHistory.last ?? Stone(stoneColor: .White, disabled: false)
        let newStone = Stone(stoneColor: lastStone.stoneColor == .White ? .Black : . White, disabled: true)
        addStone(newStone, atGobanPoint: gobanPoint, isTemporary: true)
    }
    
    func addStone(stone: StoneProtocol, atGobanPoint gobanPoint: GobanPoint, isTemporary: Bool) {
        if let stoneModel = gobanView.setStone(stone, atGobanPoint: gobanPoint) {
            if isTemporary == false {
                stoneHistory.append(stoneModel)
                removeTemporaryStone()
            } else {
                temporaryStone = stoneModel
            }
        }
    }
    
    func removeStone(stone: StoneModel) {
        stone.layer?.removeFromSuperlayer()
    }
    
    func removeTemporaryStone() {
        guard temporaryStone != nil else {
            return
        }
        
        removeStone(temporaryStone!)
        temporaryStone = nil
    }
    
    func removeLastStone() {
        if let stoneModel = stoneHistory.last {
            removeStone(stoneModel)
        }
    }
    
    func removeAllStones() {
        for stoneModel in stoneHistory {
            removeStone(stoneModel)
        }
        
        removeTemporaryStone()
        stoneHistory.removeAll()
    }
    
    // MARK: GobanTouchProtocol
    
    func didTouchGobanWithClosestGobanPoint(gobanView: GobanView, atGobanPoint gobanPoint: GobanPoint) {
        AddTemporaryStoneAtGobanPoint(gobanPoint)
    }
    
    func didEndTouchGobanWithClosestGobanPoint(goban: GobanView, atGobanPoint gobanPoint: GobanPoint?) {
        guard gobanPoint != nil else {
            removeTemporaryStone()
            return
        }
        
        addNewStoneAtGobanPoint(gobanPoint!)
    }
    
    // MARK: Helper Methods
    
    func stoneAtGobanPoint(gobanPoint: GobanPoint) -> StoneModel? {
        let filteredArray = stoneHistory.filter({$0.gobanPoint == gobanPoint})
        return filteredArray.first
    }
}