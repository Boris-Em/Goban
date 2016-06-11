//
//  SGFGame.swift
//  GobanSampleProject
//
//  Created by Bobo on 4/26/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import Foundation

struct SGFGame: SGFGameProtocol {
    
    /** The name of the person commenting the game.
     */
    private(set) var annotation: String?
    
    /** The application used to create the SGF file.
     */
    private(set) var application: String?
    
    /** The SGF file format.
     */
    private(set) var fileFormat: Int? = 3
    
    /** The copyright of the file.
     */
    private(set) var copyright: String?
    
    /** The date of the game.
     */
    private(set) var date: NSDate?
    
    /** The name of the event.
     */
    private(set) var eventName: String?
    
    /** The name of the game.
     */
    private(set) var gameName: String?
    
    /** The number of handicap stones given to the black player.
     */
    private(set) var handicap: Int?
    
    /** The komi. Points added to the white player.
     */
    private(set) var komi: Int?
    
    /** The overtime system used by the game.
     */
    private(set) var overtime: String?
    
    /** The location where the game took place.
     */
    private(set) var locationName: String?
    
    /** Result of the game.
     */
    private(set) var result: String?
    
    /** Round of the game.
     */
    private(set) var round: Int?
    
    /** The rule set used for the game.
     */
    private(set) var rules: String? = "Japanese"
    
    /** The source of the SGF file.
    */
    private(set) var source: String?
    
    /** The size of the board used for the game.
     */
    private(set) var boardSize: Int? = 19
    
    /** The time limit in seconds.
     */
    private(set) var timeLimit: Int?
    
    /** Name of the creator of the SGF file.
     */
    private(set) var user: String?
    
    // MARK: Players
    
    /** The name of the white player.
     */
    private(set) var whiteName: String?
    
    /** The name of the black player.
     */
    private(set) var blackName: String?
    
    /** Rank of the white player.
     */
    private(set) var whiteRank: String?
    
    /** Rank of the black player.
     */
    private(set) var blackRank: String?
    
    /** The team of the white player.
     */
    private(set) var whiteTeam: String?
    
    /** The tead of the black player.
     */
    private(set) var blackTeam: String?
    
    /** Game comment.
     */
    private(set) var comment: String?
    
    /** Game nodes.
     */
    private(set) var nodes = [SGFNodeProtocol]()
    
    init(SGFString: String) {
        guard SGFString.substringToIndex(SGFString.startIndex.advancedBy(2)) == "(;" else {
            return
        }
        
        guard SGFString.substringFromIndex(SGFString.endIndex.predecessor()) == ")" else {
            return
        }
        
        parseGame(SGFString)
    }
    
    private mutating func parseGame(game: String) {
        guard var nodes = self.getNodesFromString(game) else {
            return
        }
        
        guard nodes.count > 2 else {
            return
        }
        
        nodes.removeFirst()
        
        for (index, node) in nodes.enumerate() {
            if index == 0 {
                parseRootNode(node)
            } else {
                parseNode(node)
            }
        }
    }
    
    private func getNodesFromString(string: String) -> [String]? {
        return string.characters.split(";").map({String($0)})
    }
    
    private mutating func parseRootNode(rootNode: String) {
        guard let properties = getPropertiesFromNode(rootNode) else {
            return
        }
        
        for key in properties.keys {
            parseRootPropertyWithKey(key, value: properties[key]!)
        }
    }
    
    private mutating func parseNode(node: String) {
        guard let properties = getPropertiesFromNode(node) else {
            return
        }
        
        var node = SGFNode()
        
        for key in properties.keys {
            node.parsePropertyWithKey(key, value: properties[key]!)
        }
        
        nodes.append(node)
    }
    
    private func getPropertiesFromNode(node: String) -> [String: String]? {
        var properties = [String: String]()
        
        var propertyKey = ""
        var propertyValue = ""
        
        var isValue = false
        
        // TODO: Hanlde escaped characters ("\[")
        // TODO: Ignore lower case characters
        
        for character in node.characters {
            if character == "[" {
                guard propertyKey.characters.count > 0 else {
                    return nil
                }
                
                isValue = true
            } else if character == "]" {
                guard propertyKey.characters.count > 0 &&
                    propertyValue.characters.count > 0 &&
                    propertyKey.characters.count < 3 else {
                    return nil
                }
                
                properties[propertyKey] = propertyValue
                
                propertyKey = ""
                propertyValue = ""
                isValue = false
            } else {
                isValue ? propertyValue.append(character) : propertyKey.append(character)
            }
        }
        
        guard properties.count > 0 else {
            return nil
        }
        
        return properties
    }
    
    private mutating func parseRootPropertyWithKey(key: String, value: String) {
        switch key {
        case "FF":
            fileFormat = Int(value) ?? 3
            break
        case "SZ":
            boardSize = Int(value) ?? 19
            break
        case "RU":
            rules = value
            break
        case "C":
            comment = value
            break
        case "AN":
            annotation = value
            break
        case "AP":
            application = value
            break
        case "BR":
            blackRank = value
            break
        case "BT":
            blackTeam = value
            break
        case "CP":
            copyright = value
            break
        case "DT":
            // TODO: Implement date
            break
        case "EV":
            eventName = value
            break
        case "GN":
            gameName = value
            break
        case "HA":
            handicap = Int(value)
            break
        case "KM":
            komi = Int(value)
            break
        case "OT":
            overtime = value
            break
        case "PB":
            blackName = value
            break
        case "PC":
            locationName = value
            break
        case "PW":
            whiteName = value
            break
        case "RE":
            result = value
            break
        case "RO":
            round = Int(value)
            break
        case "SO":
            source = value
            break
        case "TM":
            timeLimit = Int(value)
            break
        case "US":
            user = value
            break
        case "WR":
            whiteRank = value
            break
        case "WT":
            whiteTeam = value
            break
        default:
            break
        }
    }
}
