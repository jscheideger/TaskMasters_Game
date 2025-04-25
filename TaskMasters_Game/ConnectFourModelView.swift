import Foundation
import SwiftUI

// GameState enum added (Jesten/Sammer)
enum GameState {
    case playing
    case paused
    case ended
    case draw // Added state for draw games
}

enum GameBoardType: Hashable {
    case standard
    case random
    case custom(BoardDimensions)
    
    // Required for Hashable conformance with associated values
    func hash(into hasher: inout Hasher) {
        switch self {
        case .standard:
            hasher.combine(0)
        case .random:
            hasher.combine(1)
        case .custom(let dimensions):
            hasher.combine(2)
            hasher.combine(dimensions.columns)
            hasher.combine(dimensions.rows)
        }
    }
    
    // Required for Equatable conformance
    static func == (lhs: GameBoardType, rhs: GameBoardType) -> Bool {
        switch (lhs, rhs) {
        case (.standard, .standard):
            return true
        case (.random, .random):
            return true
        case (.custom(let lhsDimensions), .custom(let rhsDimensions)):
            return lhsDimensions.columns == rhsDimensions.columns &&
                   lhsDimensions.rows == rhsDimensions.rows
        default:
            return false
        }
    }
}

class ConnectFourViewModel: ObservableObject {
    @Published private var model: ConnectFourModel
    @Published private var dvm = DataViewModel()
    @Published var dragColumn: Int? = nil
    
    // Track game state (Jesten/Sammer)
    @Published var gameState: GameState = .playing
    
    // Game Analytics (Sreeja Nama)
    @Published var matchHistory: [MatchRecord] = []
    @Published var redWins = 0
    @Published var yellowWins = 0
    @Published var totalGames = 0
    @Published var draws = 0 // Track draw games
    
    // Leaderboard System (Sreeja Nama & Gannon D)
    @Published var redPlayerName = "Red"
    @Published var yellowPlayerName = "Yellow"
    
        init(boardType: GameBoardType = .standard, randomPlayer: Bool = false) {
        // First initialize the model with default values
        self.model = ConnectFourModel(
            dimensions: BoardDimensions.standard,
            startingPlayer: .red
        )
        
        // Then explicitly reset the game with the provided parameters
        // This ensures a completely fresh game state
        switch boardType {
        case .standard:
            self.model = ConnectFourModel(
                dimensions: BoardDimensions.standard,
                startingPlayer: randomPlayer ? Player.random : .red
            )
        case .random:
            self.model = ConnectFourModel(
                dimensions: BoardDimensions.random,
                startingPlayer: randomPlayer ? Player.random : .red
            )
        case .custom(let dimensions):
            self.model = ConnectFourModel(
                dimensions: dimensions,
                startingPlayer: randomPlayer ? Player.random : .red
            )
        }
        
        // Ensure game state is properly reset
        gameState = .playing
        
        // No need to set winner directly as it's a computed property
        // Just make sure model state is fresh by clearing move history
        model.moveHistory.removeAll()
    }
    
    var board: [[Player?]] {
        model.board
    }
    
    var currentPlayer: Player {
        model.currentPlayer
    }
    
    var winner: Player? {
        model.winner
    }
    
    var boardDimensions: BoardDimensions {
        model.dimensions
    }
    
    var columns: Int {
        model.dimensions.columns
    }
    
    var rows: Int {
        model.dimensions.rows
    }
    
    // Drop piece method with sound, win tracking, and analytics
    func dropPiece(in column: Int) {
        guard gameState == .playing else { return }
        
        if model.dropPiece(in: column) {
            SoundManager.shared.playSound(named: "drop")
            
            // Check for winner
            if let winner = model.winner {
                gameState = .ended
                totalGames += 1
                if winner == .red {
                    redWins += 1
                    dvm.updatePlayerData(for: redPlayerName, for: yellowPlayerName, redWon: true)
                } else {
                    yellowWins += 1
                    dvm.updatePlayerData(for: redPlayerName, for: yellowPlayerName, redWon: false)
                }
                
                let winnerName = winner == .red ? redPlayerName : yellowPlayerName
                let loserName = winner == .red ? yellowPlayerName : redPlayerName
                let loser = winner == .red ? Player.yellow : Player.red
                
                let match = MatchRecord(
                    winner: winner,
                    loser: loser,
                    winnerName: winnerName,
                    loserName: loserName,
                    date: Date(),
                    moves: model.moveHistory,
                    boardDimensions: model.dimensions
                )
                matchHistory.insert(match, at: 0)
                
                // Play victory sound
                SoundManager.shared.playSound(named: "win")
            }
            // Check for a draw
            else if model.isBoardFull() {
                gameState = .draw
                totalGames += 1
                draws += 1
                
                // You might want to add a draw state to your match history as well
                // For now, we'll just update the game state
                SoundManager.shared.playSound(named: "draw") // You'll need to add this sound
            }
        }
        
        objectWillChange.send()
    }
    
    // Pause/resume/reset functionality
    func pauseGame() {
        if winner == nil && gameState == .playing {
            gameState = .paused
        }
    }
    
    func resumeGame() {
        if winner == nil && gameState == .paused {
            gameState = .playing
        }
    }
    
    func resetGame(boardType: GameBoardType = .standard, randomPlayer: Bool = false) {
        // Handle different board types for reset
        switch boardType {
        case .standard:
            model.reset(dimensions: BoardDimensions.standard, randomPlayer: randomPlayer)
        case .random:
            model.reset(dimensions: BoardDimensions.random, randomPlayer: randomPlayer)
        case .custom(let dimensions):
            model.reset(dimensions: dimensions, randomPlayer: randomPlayer)
        }
        
        gameState = .playing
        objectWillChange.send()
    }
    
    func colorFor(_ player: Player?) -> Color {
        switch player {
        case .red: return .red
        case .yellow: return .yellow
        case .none: return .gray.opacity(0.3)
        }
    }
    
    func replayGameDirectly(_ match: MatchRecord) {
        // Reset with the same dimensions as the recorded match
        resetGame(boardType: .custom(match.boardDimensions))
        
        // Set the game state to playing
        gameState = .playing
        
        // Replay all moves without delay for testing
        for move in match.moves {
            // Apply each move directly
            _ = model.dropPiece(in: move.column)
            objectWillChange.send()
        }
    }
    
    // Replay Feature (Sreeja Nama)
    func replayGame(_ match: MatchRecord) {
        // Reset with the same dimensions as the recorded match
        resetGame(boardType: .custom(match.boardDimensions))
        gameState = .playing
        
        // Set the player names from the match record
        redPlayerName = match.winner == .red ? match.winnerName : match.loserName
        yellowPlayerName = match.winner == .yellow ? match.winnerName : match.loserName
        
        // Clear any existing moves to prepare for replay
        model.moveHistory.removeAll()
        
        // Schedule the moves with a slower delay for better visibility
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            for (index, move) in match.moves.enumerated() {
                // Increase delay between moves to 1.5 seconds (from 0.8)
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 1.5) { [weak self] in
                    guard let self = self else { return }
                    
                    // Apply the move and update the UI
                    _ = self.model.dropPiece(in: move.column)
                    self.objectWillChange.send()
                    
                    // Play the drop sound for each move to enhance the experience
                    SoundManager.shared.playSound(named: "drop")
                    
                    // If this is the last move, play the win sound after a delay
                    if index == match.moves.count - 1 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            SoundManager.shared.playSound(named: "win")
                        }
                    }
                }
            }
        }
    }
}
