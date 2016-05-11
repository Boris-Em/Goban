//
//  SGF.Node.swift
//  GobanSampleProject
//
//  Created by Bobo on 4/26/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import Foundation

protocol SGFNodeProtocol {
    var simpleproperties: [(name: String, value: String)] { get }
}

struct SGFNode: SGFNodeProtocol {
    var simpleproperties: [(name: String, value: String)] = []
    
    private(set) var actions = [SGFAction]()
    private(set) var comment: String?
    
    mutating func parsePropertyWithKey(key: String, value: String) {
        // keep simple properties along with actions
        simpleproperties.append((key, value))
        
        switch key {
        case "AB":
            actions.append(SGFAction(actionType: .AddBlack, value: value))
            break
        case "AW":
            actions.append(SGFAction(actionType: .AddWhite, value: value))
            break
        case "AE":
            actions.append(SGFAction(actionType: .AddEmpty, value: value))
            break
        case "B":
            actions.append(SGFAction(actionType: .MoveBlack, value: value))
            break
        case "W":
            actions.append(SGFAction(actionType: .MoveWhite, value: value))
            break
        default:
            break
        }
    }
}

struct SGFAction {
    private(set) var actionType: SGFActionTypes
    private(set) var value: String
    
    init(actionType: SGFActionTypes, value: String) {
        self.actionType = actionType
        self.value = value
    }
}

enum SGFActionTypes {
    case AddBlack
    case AddWhite
    case AddEmpty
    case MoveBlack
    case MoveWhite
}
