//
//  ContentView.swift
//  TaskMasters_Game
//
//  Created by Jesten Scheideger on 4/11/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ConnectFourViewModel()
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        VStack(spacing: 10) {
            Text("Connect Four")
                .font(.largeTitle)

            Text("Current Player: \(viewModel.currentPlayer.rawValue)")
                .font(.headline)

            HStack(spacing: 5) {
                ForEach(0..<7, id: \.self) { col in
                    VStack(spacing: 5) {
                        ForEach((0..<6).reversed(), id: \.self) { row in
                            Circle()
                                .foregroundColor(viewModel.colorFor(viewModel.board[col][row]))
                                .frame(width: 50, height: 50)
                                .overlay(Circle().stroke(Color.black.opacity(0.2)))
                                .transition(.move(edge: .top))
                                .animation(.easeIn(duration: 0.3), value: viewModel.board[col][row])
                        }
                        .onDrop(of: ["public.text"], isTargeted: nil) { _ in
                            withAnimation {
                                viewModel.dropPiece(in: col)
                            }
                            return true
                        }
                    }
                }
            }
            .padding()

            DraggableToken(player: viewModel.currentPlayer)

            if let winner = viewModel.winner {
                Text("\(winner.rawValue) Wins!")
                    .font(.title)
                    .foregroundColor(.green)
                    .padding()

                Button("Restart Game") {
                    viewModel.resetGame()
                    SoundManager.shared.playSound(named: "win")
                }
                .padding()
            }
        }
        .padding()
    }
}

struct DraggableToken: View {
    let player: Player
    var body: some View {
        Text(player.rawValue)
            .font(.largeTitle)
            .frame(width: 60, height: 60)
            .background(Circle().fill(Color.white))
            .shadow(radius: 5)
            .onDrag {
                return NSItemProvider(object: NSString(string: player.rawValue))
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
