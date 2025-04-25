//
//  ConnectFourModel.swift
//  TaskMasters_Game
//
//  Created by Jesten Scheideger on 4/11/25.
//  Added analytics, match history, and replay support(added by Sreeja Nama)
//

import Foundation

enum Player: String, Codable {
    case red = "🔴"
    case yellow = "🟡"
    
    var next: Player {
        self == .red ? .yellow : .red
    }
    // Get a random starting player (Jesten)
    static var random: Player {
        return Bool.random() ? .red : . yellow
    }
}

//Board Dimensions (Jesten)

struct BoardDimensions: Codable {
    let rows: Int
    let columns: Int
    
    //Default
    static let standard: BoardDimensions = BoardDimensions(rows: 6, columns: 7)
    
    //Create Random Board
    static var random: BoardDimensions {
        let columns = Int.random(in: 6...9)
        let rows = Int.random(in: 5...8)
        return BoardDimensions(rows: rows, columns: columns)
    }
}

struct Move: Codable {
    let column: Int
    let player: Player
}

struct MatchRecord: Identifiable, Codable, Equatable {
    let id = UUID()
    let winner: Player
    let loser: Player
    let winnerName: String
    let loserName: String
    let date: Date
    let moves: [Move]
    let boardDimensions: BoardDimensions
    
    // Required for Equatable conformance
    static func == (lhs: MatchRecord, rhs: MatchRecord) -> Bool {
        return lhs.id == rhs.id
    }
}


struct ConnectFourModel {
    var board: [[Player?]]
    var currentPlayer: Player
    var winner: Player? = nil
    var moveHistory: [Move] = [] // Added by Sreeja Nama
    var dimensions: BoardDimensions
    
    init(dimensions: BoardDimensions = .standard, startingPlayer: Player? = nil) {
            self.dimensions = dimensions
            // Initialize the board with the given dimensions
            self.board = Array(repeating: Array(repeating: nil, count: dimensions.rows), count: dimensions.columns)
            // Set the starting player (random if nil)
            self.currentPlayer = startingPlayer ?? Player.random
        }

    mutating func reset(dimensions: BoardDimensions? = nil, randomPlayer: Bool = false) {
            // Update dimensions if provided
            if let newDimensions = dimensions {
                self.dimensions = newDimensions
            }
            
            // Reinitialize the board with current dimensions
            board = Array(repeating: Array(repeating: nil, count: self.dimensions.rows), count: self.dimensions.columns)
            
            // Set the player, either random or default to red
            currentPlayer = randomPlayer ? Player.random : .red
            
            winner = nil
            moveHistory.removeAll()
        }

        mutating func dropPiece(in column: Int) -> Bool {
            guard winner == nil, column >= 0, column < dimensions.columns else { return false }

            for row in 0..<dimensions.rows {
                if board[column][row] == nil {
                    board[column][row] = currentPlayer
                    moveHistory.append(Move(column: column, player: currentPlayer))
                    if checkWinner(at: column, row: row) {
                        winner = currentPlayer
                    } else {
                        currentPlayer = currentPlayer.next
                    }
                    return true
                }
            }
            return false
        }

        func checkWinner(at col: Int, row: Int) -> Bool {
            let directions = [(1, 0), (0, 1), (1, 1), (1, -1)]
            guard let symbol = board[col][row] else { return false }

            for (dx, dy) in directions {
                var count = 1
                for dir in [-1, 1] {
                    var x = col + dx * dir
                    var y = row + dy * dir
                    while x >= 0 && x < dimensions.columns && y >= 0 && y < dimensions.rows,
                          board[x][y] == symbol {
                        count += 1
                        x += dx * dir
                        y += dy * dir
                    }
                }
                if count >= 4 {
                    return true
                }
            }
            return false
        }
        
        // Check if the board is completely full (draw)
        func isBoardFull() -> Bool {
            for col in 0..<dimensions.columns {
                for row in 0..<dimensions.rows {
                    if board[col][row] == nil {
                        return false
                    }
                }
            }
            return true
        }
    }
