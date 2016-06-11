import Foundation

protocol SGFGameProtocol {
    
    // The name of the person commenting the game.
    var annotation: String? { get }
    
    // The application used to create the SGF file.
    var application: String? { get }
    
    // The SGF file format.
    var fileFormat: Int? { get }
    
    // The copyright of the file.
    var copyright: String? { get }
    
    // The date of the game.
    var date: NSDate? { get }
    
    // The name of the event.
    var eventName: String? { get }
    
    // The name of the game.
    var gameName: String? { get }
    
    // The number of handicap stones given to the black player.
    var handicap: Int? { get }
    
    // The komi. Points added to the white player.
    var komi: Int? { get }
    
    // The overtime system used by the game.
    var overtime: String? { get }
    
    // The location where the game took place.
    var locationName: String? { get }
    
    // Result of the game.
    var result: String? { get }
    
    // Round of the game.
    var round: Int? { get }
    
    // The rule set used for the game.
    var rules: String? { get }
    
    // The source of the SGF file.
    var source: String? { get }
    
    // The size of the board used for the game.
    var boardSize: Int? { get }
    
    // The time limit in seconds.
    var timeLimit: Int? { get }
    
    // Name of the creator of the SGF file.
    var user: String? { get }
    
    // MARK: Players
    
    // The name of the white player.
    var whiteName: String? { get }
    
    // The name of the black player.
    var blackName: String? { get }
    
    // Rank of the white player.
    var whiteRank: String? { get }
    
    // Rank of the black player.
    var blackRank: String? { get }
    
    // The team of the white player.
    var whiteTeam: String? { get }
    
    // The tead of the black player.
    var blackTeam: String? { get }
    
    // Game comment.
    var comment: String? { get }
    
    // Game nodes.
    var nodes: [SGFNodeProtocol] { get }
}

protocol SGFNodeProtocol {
    var simpleproperties: [(name: String, value: String)] { get }
}