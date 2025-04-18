//
//  GameControlsView.swift
//  TaskMasters_Game
//
//  Created by Jesten Scheideger on 4/18/25.
//

import SwiftUI

struct GameControlsView: View {
    @ObservedObject var viewModel: ConnectFourViewModel

    var body: some View {
        HStack(spacing: 20) {
            Button(action: {
                if viewModel.gameState == .playing {
                    viewModel.pauseGame()
                } else if viewModel.gameState == .paused {
                    viewModel.resumeGame()
                }
            }) {
                Text(viewModel.gameState == .paused ? "▶️ Resume" : "⏸️ Pause")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow.opacity(0.8))
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }

            Button(action: {
                viewModel.resetGame()
                SoundManager.shared.playSound(named: "win")
            }) {
                Text("🔁 Restart")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
