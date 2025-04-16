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
}

struct Move: Codable {
    let column: Int
    let player: Player
}

struct MatchRecord: Identifiable, Codable {
    let id = UUID()
    let winner: Player
    let date: Date
    let moves: [Move]
}

struct ConnectFourModel {
    var board: [[Player?]] = Array(repeating: Array(repeating: nil, count: 6), count: 7)
    var currentPlayer: Player = .red
    var winner: Player? = nil
    
    var moveHistory: [Move] = [] // Added by Sreeja Nama

    mutating func reset() {
        board = Array(repeating: Array(repeating: nil, count: 6), count: 7)
        currentPlayer = .red
        winner = nil
        moveHistory.removeAll() // Added by Sreeja Nama
    }

    mutating func dropPiece(in column: Int) -> Bool {
        guard winner == nil else { return false }

        for row in 0..<6 {
            if board[column][row] == nil {
                board[column][row] = currentPlayer
                moveHistory.append(Move(column: column, player: currentPlayer)) // Added by Sreeja Nama
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
                while x >= 0 && x < 7 && y >= 0 && y < 6,
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
}
