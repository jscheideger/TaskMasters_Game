// PlayerStats.swift
//  TaskMasters_Game
//
//  Added leaderboard system with player stats(--Sreeja Nama)

import Foundation

struct PlayerStats: Identifiable, Codable {
    let id = UUID()
    let name: String
    var wins: Int
    var totalGames: Int

    var winRate: Double {
        guard totalGames > 0 else { return 0 }
        return Double(wins) / Double(totalGames)
    }
}
