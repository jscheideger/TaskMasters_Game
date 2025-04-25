import SwiftUI

struct MatchHistoryView: View {
    @ObservedObject var viewModel: ConnectFourViewModel
    @State private var navigateToGame = false
    @State private var selectedMatch: MatchRecord? = nil
    
    var body: some View {
        ZStack {
            // Apply background gradient
            Theme.backgroundGradient()
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("⏮️ MATCH HISTORY")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .shadow(color: .black, radius: 1)
                
                if viewModel.matchHistory.isEmpty {
                    VStack {
                        Spacer()
                        Text("No matches played yet.")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(10)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.matchHistory) { match in
                                Button(action: {
                                    selectedMatch = match
                                    // First set the selected match
                                    // Then navigate to game view
                                    navigateToGame = true
                                }) {
                                    MatchHistoryRowView(match: match)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $navigateToGame) {
                // Navigate to ContentView with the same shared viewModel
                ContentView(viewModel: viewModel)
                    .onAppear {
                        // Start the replay only after navigation is complete
                        if let match = selectedMatch {
                            viewModel.replayGame(match)
                        }
                    }
            }
        }
    }
}

struct MatchHistoryRowView: View {
    let match: MatchRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            let winnerToken = match.winner.rawValue
            let loserToken = match.winner == .red ? Player.yellow.rawValue : Player.red.rawValue
            let boardSize = "\(match.boardDimensions.columns)×\(match.boardDimensions.rows)"
            
            HStack {
                Text("\(winnerToken) \(match.winnerName) vs \(loserToken) \(match.loserName)")
                    .bold()
                    .foregroundColor(.black)
                Spacer()
                Text("Board: \(boardSize)")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            
            Text(match.date, style: .time)
                .font(.caption)
                .foregroundColor(.black.opacity(0.7))
            
            HStack {
                Image(systemName: "play.circle.fill")
                    .foregroundColor(.orange)
                    .imageScale(.large)
                
                Text("Tap to watch replay")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .bold()
                
                Spacer()
                
                Text("\(match.moves.count) moves")
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.7))
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.orange.opacity(0.5), lineWidth: 2)
        )
    }
}

#Preview {
    MatchHistoryView(viewModel: .init())
}
