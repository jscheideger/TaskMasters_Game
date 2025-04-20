import SwiftUI

struct MainMenuView: View {
    @StateObject private var gameViewModel = ConnectFourViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()

                VStack(spacing: 10) {
                    Text("Task Masters")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundColor(.orange)

                    Text("Connect Four")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }

                Image("osu_pete")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .padding()

                VStack(spacing: 16) {
                    // New Game – generates a fresh instance
                    NavigationLink(destination: ContentView(viewModel: ConnectFourViewModel())) {
                        Text("🆕 New Game")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    NavigationLink(destination: MatchHistoryView(viewModel: gameViewModel)) {
                        Text("⏮️ Match History")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    NavigationLink(destination: LeaderboardView(viewModel: gameViewModel)) {
                        Text("🏅 Leaderboard")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.white, .orange.opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationBarHidden(true)
        }
    }
}




