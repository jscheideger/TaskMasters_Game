//
//  MatchHistoryView.swift
//  TaskMasters_Game
//
//  Created by Jesten Scheideger on 4/18/25.
//
// Shows player names and tokens in history

import SwiftUI

struct MatchHistoryView: View {
    @ObservedObject var viewModel: ConnectFourViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("⏮️ MATCH HISTORY")
                .font(.title)
                .bold()

            ForEach(viewModel.matchHistory) { match in
                let redName = viewModel.redPlayerName
                let yellowName = viewModel.yellowPlayerName
                let winnerToken = match.winner.rawValue
                let winnerName = match.winner == .red ? redName : yellowName
                let loserName = match.winner == .red ? yellowName : redName
                let loserToken = match.winner == .red ? Player.yellow.rawValue : Player.red.rawValue

                HStack {
                    VStack(alignment: .leading) {
                        Text("\(winnerToken) \(winnerName) vs \(loserToken) \(loserName)")
                            .bold()
                        Text(match.date, style: .time)
                            .font(.caption)
                    }
                    Spacer()
                    Button("Replay") {
                        viewModel.replayGame(match)
                    }
                    .padding(.leading)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Match History")
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.2), .purple.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
