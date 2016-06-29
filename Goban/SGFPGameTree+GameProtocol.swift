//
//  SGFGame2.swift
//  GobanSampleProject
//
//  Created by John on 5/10/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import Foundation

extension SGFP.GameTree {
    
    // The name of the person commenting the game.
    var annotation: String? {
        return gameInfoProperty(.AN)?.values.first?.toText()
    }
    
    // The application used to create the SGF file.
    var application: String? { 
        return rootProperty(.AP)?.values.first?.toText() 
    }
    
    // The SGF file format.
    var fileFormat: Int? { 
        return rootProperty(.FF)?.values.first?.toNumber() 
    }
    
    // The copyright of the file.
    var copyright: String? { 
        return gameInfoProperty(.CP)?.values.first?.toText() 
    }
    
    // The date of the game.
    var date: NSDate? {
        guard let dateString = gameInfoProperty(.DT)?.values.first?.toText() else {
            return nil
        }

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD"
        
        return dateFormatter.dateFromString(dateString)
    }
    
    // The name of the event.
    var eventName: String? { 
        return gameInfoProperty(.EV)?.values.first?.toText() 
    }
    
    // The name of the game.
    var gameName: String? { 
        return gameInfoProperty(.GN)?.values.first?.toText() 
    }
    
    // The number of handicap stones given to the black player.
    var handicap: Int? { 
        return rootNode?.propertyWithName(GoProperties.HA.rawValue)?.values.first?.toNumber() 
    }
    
    // The komi. Points added to the white player.
    var komi: Float? {
        return rootNode?.propertyWithName(GoProperties.KM.rawValue)?.values.first?.toReal()
    }
    
    // The overtime system used by the game.
    var overtime: String? { 
        return gameInfoProperty(.OT)?.values.first?.toSimpleText() 
    }
    
    // The location where the game took place.
    var locationName: String? { 
        return gameInfoProperty(.PC)?.values.first?.toText() 
    }
    
    // Result of the game.
    var result: String? { 
        return gameInfoProperty(.RE)?.values.first?.toText() 
    }
    
    // Round of the game.
    var round: String? {
        return gameInfoProperty(.RO)?.values.first?.toText()
    }
    
    // The rule set used for the game.
    var rules: String? { 
        return gameInfoProperty(.RU)?.values.first?.toText() 
    }
    
    // The source of the SGF file.
    var source: String? { 
        return gameInfoProperty(.SO)?.values.first?.toText() 
    }
    
    // The size of the board used for the game.
    var boardSize: Int? { 
        return rootProperty(.SZ)?.values.first?.toNumber() 
    }
    
    // The time limit in seconds.
    var timeLimit: Int? { 
        return gameInfoProperty(.TM)?.values.first?.toNumber()
    }
    
    // Name of the creator of the SGF file.
    var user: String? { 
        return gameInfoProperty(.US)?.values.first?.toText() 
    }
    
    // MARK: Players
    
    // The name of the white player.
    var whiteName: String? { 
        return gameInfoProperty(.PW)?.values.first?.toText() 
    }
    
    // The name of the black player.
    var blackName: String? { 
        return gameInfoProperty(.PB)?.values.first?.toText() 
    }
    
    // Rank of the white player.
    var whiteRank: String? { 
        return gameInfoProperty(.WR)?.values.first?.toText() 
    }
    
    // Rank of the black player.
    var blackRank: String? { 
        return gameInfoProperty(.BR)?.values.first?.toText() 
    }
    
    // The team of the white player.
    var whiteTeam: String? { 
        return gameInfoProperty(.WT)?.values.first?.toText() 
    }
    
    // The tead of the black player.
    var blackTeam: String? { 
        return gameInfoProperty(.BT)?.values.first?.toText() 
    }
    
    // Game comment.
    var comment: String? {
        return rootNode?.propertyWithName(SGFNodeAnnotationProperties.C.rawValue)?.values.first?.toText() 
    }
    
    // Game nodes.
    
    var rootNode: SGFP.Node? {
        return sequence.nodes.first
    }

    var nodes: [SGFP.Node] {
        return sequence.nodes
    }
   
    func rootProperty(property: SGFRootProperties) -> SGFP.Property? {
        return rootNode?.propertyWithName(property.rawValue)
    }
    
    func gameInfoProperty(property: SGFGameInfoProperties) -> SGFP.Property? {
        return rootNode?.propertyWithName(property.rawValue)
    }
    
}