import SwiftUI

struct LeaderboardView: View {
    @State private var showClearConfirmation = false
    @ObservedObject var viewModel: ConnectFourViewModel
    @StateObject private var dvm = DataViewModel()

    var body: some View {
        ZStack {
            // Apply background gradient
            Theme.backgroundGradient()
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("🏅 LEADERBOARD")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.bottom)
                    .shadow(color: .black, radius: 1)
                    
                ScrollView {
                    ForEach(dvm.savedentries) { player in
                        HStack {
                            Text(player.name ?? "Unknown")
                                .bold()
                                .foregroundColor(.black)
                            Spacer()
                            Text("Wins: \(player.wins), Games: \(player.totalGames), Win Rate: \(String(format: "%.0f", player.winRate * 100))%")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.1), radius: 3)
                        .padding(.bottom, 5)
                    }
                }
                
                Button(action: {
                    showClearConfirmation = true
                }) {
                    Label("Clear Scores", systemImage: "trash")
                        .foregroundColor(.black)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.9))
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.2), radius: 3)
                }
                .padding(.top, 10)
                .alert("Are you sure you want to clear all scores?", isPresented: $showClearConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Clear", role: .destructive) {
                        dvm.clearAll()
                    }
                }

                Spacer()
            }
            .padding()
            .onAppear {
                // Refresh the data whenever the leaderboard appears
                dvm.fetchPlayerData()
            }
        }
    }
}

#Preview {
    LeaderboardView(viewModel: .init())
}
