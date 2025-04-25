//
//  LeaderboardView.swift
//  TaskMasters_Game
//
//  Created by Jesten Scheideger on 4/18/25.
//

import SwiftUI

struct LeaderboardView: View {
    @State private var showClearConfirmation = false
    @ObservedObject var viewModel: ConnectFourViewModel
    @StateObject private var dvm = DataViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🏅 LEADERBOARD")
                .font(.title)
                .bold()
                .padding(.bottom)
            ScrollView{
                ForEach(dvm.savedentries) { player in
                    HStack {
                        Text(player.name ?? "Unknown").bold()
                        Spacer()
                        Text("Wins: \(player.wins), Games: \(player.totalGames), Win Rate: \(String(format: "%.0f", player.winRate * 100))%")
                            .font(.caption)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            Button("Clear Scores", systemImage: "trash") {

                showClearConfirmation = true
                
            }
            .padding(7)
            .background(Color.yellow.opacity(0.8))
            .foregroundColor(.black)
            .cornerRadius(10)
            
            .alert("Are you sure you want to leave the game?", isPresented: $showClearConfirmation) {

                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    dvm.clearAll()  // Call the clearAll method if confirmed
                    }

            }

            Spacer()
        }
        .padding()

        .background(
            LinearGradient(
                gradient: Gradient(colors: [.purple.opacity(0.2), .blue.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        
    }
}
#Preview {
    LeaderboardView(viewModel: .init())
}
