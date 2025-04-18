//
//  LeaderboardView.swift
//  TaskMasters_Game
//
//  Created by Jesten Scheideger on 4/18/25.
//

import SwiftUI

struct LeaderboardView: View {
    @ObservedObject var viewModel: ConnectFourViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🏅 LEADERBOARD")
                .font(.title)
                .bold()
                .padding(.bottom)

            ForEach(viewModel.leaderboard) { player in
                HStack {
                    Text(player.name).bold()
                    Spacer()
                    Text("Wins: \(player.wins), Games: \(player.totalGames), Win Rate: \(String(format: "%.0f", player.winRate * 100))%")
                        .font(.caption)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Leaderboard")
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.purple.opacity(0.2), .blue.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
