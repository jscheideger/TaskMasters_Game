//  ConnectFourModelView.swift
//  TaskMasters_Game
//
//  Modified by Sreeja Nama – Added match tracking, analytics, replay logic, and leaderboard support.

import Foundation
import SwiftUI

//GameState enum added (Jesten/Sammer)
enum GameState {
    case playing
    case paused
    case ended
}

class ConnectFourViewModel: ObservableObject {
    @Published private var model = ConnectFourModel()
    @Published var dragColumn: Int? = nil
    
    //Track game state(Jesten/Sammer)
    @Published var gameState: GameState = .playing

class ConnectFourViewModel: ObservableObject {
    @Published private var model = ConnectFourModel()
    @Published var dragColumn: Int? = nil

    // Game Analytics  (Sreeja Nama)
    @Published var matchHistory: [MatchRecord] = []
    @Published var redWins = 0
    @Published var yellowWins = 0
    @Published var totalGames = 0

    // Leaderboard System (Sreeja Nama)
    @Published var redPlayerName = "Red"
    @Published var yellowPlayerName = "Yellow"
    @Published var leaderboard: [PlayerStats] = []

    var board: [[Player?]] {
        model.board
    }

    var currentPlayer: Player {
        model.currentPlayer
    }

    var winner: Player? {
        model.winner
    }
    
    //block moves if pause or ended (Jesten/Sammer)
    func dropPiece(in column: Int) {
        guard gameState == .playing else { return }
    

    func dropPiece(in column: Int) {
        if model.dropPiece(in: column) {
            SoundManager.shared.playSound(named: "drop")

            if let winner = model.winner {
                gameState = .ended //JS
                totalGames += 1
                if winner == .red {
                    redWins += 1
                    updateLeaderboard(for: redPlayerName) // Added by Sreeja Nama
                } else {
                    yellowWins += 1
                    updateLeaderboard(for: yellowPlayerName) // Added by Sreeja Nama
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
                                    moves: model.moveHistory
                                )
                                matchHistory.insert(match, at: 0)
                let match = MatchRecord(winner: winner, date: Date(), moves: model.moveHistory)
                matchHistory.insert(match, at: 0)
            }
        }
        objectWillChange.send()
    }
    
    //pause support (Jesten/Sammer)
    
    func pauseGame() {
        if winner == nil {
            gameState = .paused
        }
    }
    
    //resume support (Jesten/Sammer)
    func resumeGame() {
        if winner == nil {
            gameState = .playing
        }
    }
    
    
    func resetGame() {
        model.reset()
        gameState = .playing //JS

    func resetGame() {
        model.reset()
        objectWillChange.send()
    }

    func colorFor(_ player: Player?) -> Color {
        switch player {
        case .red: return .red
        case .yellow: return .yellow
        case .none: return .gray.opacity(0.3)
        }
    }

    // Replay Feature( Sreeja Nama)
    func replayGame(_ match: MatchRecord) {
        resetGame()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for (index, move) in match.moves.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                    _ = self.model.dropPiece(in: move.column)
                    self.objectWillChange.send()
                }
            }
        }
    }

    // Leaderboard Update Logic( Sreeja Nama)
    func updateLeaderboard(for name: String) {
        if let index = leaderboard.firstIndex(where: { $0.name == name }) {
            leaderboard[index].wins += 1
            leaderboard[index].totalGames += 1
        } else {
            leaderboard.append(PlayerStats(name: name, wins: 1, totalGames: 1))
        }

        leaderboard.sort { $0.winRate > $1.winRate }
    }
}
