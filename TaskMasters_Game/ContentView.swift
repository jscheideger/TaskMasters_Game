//  ContentView.swift
//  TaskMasters_Game
//
//  UI for analytics, replay, and leaderboard(Sreeja Nama)
//  UI enhancement: gradient background, styled inputs, cards for stats, animated tokens(Sreeja Nama)
//Seperated Leaderboard/ MatchHistory to own screens uisng navigationlinks (Jesten)
//Add token next to player name at all times(Jesten)

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ConnectFourViewModel
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 15) {
                    Text("🎮 CONNECT FOUR")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.indigo)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Enter Player Names")
                            .font(.headline)

                        HStack {
                            Label {
                                TextField("Red", text: $viewModel.redPlayerName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            } icon: {
                                Text(Player.red.rawValue)
                            }

                            Label {
                                TextField("Yellow", text: $viewModel.yellowPlayerName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            } icon: {
                                Text(Player.yellow.rawValue)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    Text("Current Player: \(viewModel.currentPlayer.rawValue)")
                        .font(.headline)

                    HStack(spacing: 5) {
                        ForEach(0..<7, id: \ .self) { col in
                            VStack(spacing: 5) {
                                ForEach((0..<6).reversed(), id: \ .self) { row in
                                    Circle()
                                        .foregroundColor(viewModel.colorFor(viewModel.board[col][row]))
                                        .frame(width: 50, height: 50)
                                        .shadow(color: .black.opacity(0.2), radius: 4, x: 2, y: 2)
                                        .overlay(Circle().stroke(Color.black.opacity(0.2)))
                                        .transition(.move(edge: .top))
                                        .animation(.spring(), value: viewModel.board[col][row])
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
                        let winnerName = winner == .red ? viewModel.redPlayerName : viewModel.yellowPlayerName
                        Text("\(winner.rawValue) \(winnerName) wins!")
                            .font(.title)
                            .foregroundColor(.green)
                            .padding()
                    }


                    GameControlsView(viewModel: viewModel)

                    Divider()

                    VStack(spacing: 15) {
                        NavigationLink(destination: MatchHistoryView(viewModel: viewModel)) {
                            Text("⏮️ Match History")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.3))
                                .cornerRadius(10)
                        }

                        NavigationLink(destination: LeaderboardView(viewModel: viewModel)) {
                            Text("🏅 Leaderboard")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.purple.opacity(0.3))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Connect Four")
        }
    @StateObject private var viewModel = ConnectFourViewModel()
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                
                //  UI Enhancement by Sreeja Nama
                Text("🎮CONNECT FOUR")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.indigo)

                // Player Name Input UI Enhancement
                VStack(alignment: .leading, spacing: 10) {
                    Text("Enter Player Names")
                        .font(.headline)
                        .foregroundColor(.primary)
                    HStack {
                        TextField("Red", text: $viewModel.redPlayerName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Yellow", text: $viewModel.yellowPlayerName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                }
                .padding()

                Text("Current Player: \(viewModel.currentPlayer.rawValue)")
                    .font(.headline)

                // Board with animated tokens and drop shadow
                HStack(spacing: 5) {
                    ForEach(0..<7, id: \.self) { col in
                        VStack(spacing: 5) {
                            ForEach((0..<6).reversed(), id: \.self) { row in
                                Circle()
                                    .foregroundColor(viewModel.colorFor(viewModel.board[col][row]))
                                    .frame(width: 50, height: 50)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 2, y: 2)
                                    .overlay(Circle().stroke(Color.black.opacity(0.2)))
                                    .transition(.move(edge: .top))
                                    .animation(.spring(), value: viewModel.board[col][row])
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

                // Game Stats
                Divider().padding(.top)
                VStack(alignment: .leading, spacing: 4) {
                    Text("GAME STATS").font(.headline)
                    Text("Red Wins: \(viewModel.redWins)")
                    Text("Yellow Wins: \(viewModel.yellowWins)")
                    Text("Total Games: \(viewModel.totalGames)")
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)

                // added replay to view Match History
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Text("⏮️ MATCH HISTORY")
                        .font(.title3)
                        .bold()
                    ForEach(viewModel.matchHistory) { match in
                        HStack {
                            Text("🏆 \(match.winner.rawValue)")
                            Spacer()
                            Text(match.date, style: .time)
                            Button("Replay") {
                                viewModel.replayGame(match)
                            }
                            .padding(.leading)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding()

                //Leaderboard
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Text("🏅 LEADERBOARD").font(.title3).bold()
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
                }
                .padding()
            }
            .padding()
        }
        // Background
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.3), .purple.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .edgesIgnoringSafeArea(.all)
    }
}

// added draggable Player Token UI
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
