import SwiftUI

struct MainMenuView: View {
    @State private var showNewGameConfirmation = false
    @State private var showSettings = false
    @State private var boardType: GameBoardType = .standard
    @State private var randomStartingPlayer = false
    @State private var selectedColumns = 7
    @State private var selectedRows = 6

    @State private var newGameActive = false
    @State private var tempViewModel: ConnectFourViewModel? = nil

    @State private var resumeGameActive = false
    // Create a single shared instance that will be used across the app
    @StateObject private var sharedViewModel = ConnectFourViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                // Apply background gradient
                Theme.backgroundGradient()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Spacer()

                    VStack(spacing: 10) {
                        Text("Task Masters")
                            .font(.largeTitle)
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2, x: 1, y: 1)

                        Text("Connect Four")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                            .shadow(color: .black.opacity(0.5), radius: 1)
                    }

                    Image("Unknown")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .padding()
                        .shadow(color: .black.opacity(0.3), radius: 8)

                    VStack(spacing: 16) {
                        if sharedViewModel.gameState == .paused {
                            Button(action: {
                                resumeGameActive = true
                            }) {
                                Text("▶️ Resume Game")
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.yellow.opacity(0.9))
                                    .foregroundColor(.black)
                                    .cornerRadius(10)
                                    .shadow(color: .black.opacity(0.2), radius: 3)
                            }
                        }

                        Button(action: {
                            // Use the shared view model but reset it for a new game
                            sharedViewModel.resetGame(
                                boardType: boardType,
                                randomPlayer: randomStartingPlayer
                            )
                            newGameActive = true
                        }) {
                            Text("🆕 New Game")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Theme.primaryButtonColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.2), radius: 3)
                        }

                        Button(action: {
                            showSettings = true
                        }) {
                            Text("⚙️ Game Settings")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.orange.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.2), radius: 3)
                        }

                        NavigationLink(destination: MatchHistoryView(viewModel: sharedViewModel)) {
                            Text("⏮️ Match History")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Theme.secondaryButtonColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.2), radius: 3)
                        }

                        NavigationLink(destination: LeaderboardView(viewModel: sharedViewModel)) {
                            Text("🏅 Leaderboard")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.black.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.2), radius: 3)
                        }
                    }
                    .padding(.horizontal)

                    Spacer()

                    HStack {
                        Text(boardTypeDescription)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.4))
                            .cornerRadius(8)

                        Spacer()

                        Text(randomStartingPlayer ? "Random First Player" : "Red First Player")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.4))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showSettings) {
                gameSettingsView
            }
            .navigationDestination(isPresented: $newGameActive) {
                ContentView(viewModel: sharedViewModel)
            }
            .navigationDestination(isPresented: $resumeGameActive) {
                ContentView(viewModel: sharedViewModel)
            }
        }
    }

    var boardTypeDescription: String {
        switch boardType {
        case .standard:
            return "Standard Board (7×6)"
        case .random:
            return "Random Board Size"
        case .custom(let dimensions):
            return "Custom Board (\(dimensions.columns)×\(dimensions.rows))"
        }
    }

    var gameSettingsView: some View {
        NavigationStack {
            Form {
                Section(header: Text("Board Type").foregroundColor(.orange)) {
                    Picker("Board Type", selection: $boardType) {
                        Text("Standard (7×6)").tag(GameBoardType.standard)
                        Text("Random Size").tag(GameBoardType.random)
                        Text("Custom Size").tag(GameBoardType.custom(BoardDimensions(rows: selectedRows, columns: selectedColumns)))
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .accentColor(.orange)

                    if case .custom = boardType {
                        Stepper("Columns: \(selectedColumns)", value: $selectedColumns, in: 5...10)
                            .onChange(of: selectedColumns) { _, newValue in
                                boardType = .custom(BoardDimensions(rows: selectedRows, columns: newValue))
                            }
                            .foregroundColor(.black)

                        Stepper("Rows: \(selectedRows)", value: $selectedRows, in: 4...10)
                            .onChange(of: selectedRows) { _, newValue in
                                boardType = .custom(BoardDimensions(rows: newValue, columns: selectedColumns))
                            }
                            .foregroundColor(.black)
                    }
                }

                Section(header: Text("Starting Player").foregroundColor(.orange)) {
                    Toggle("Random First Player", isOn: $randomStartingPlayer)
                        .tint(.orange)

                    if !randomStartingPlayer {
                        Text("Red player always starts first")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("Current Board Size").foregroundColor(.orange)) {
                    switch boardType {
                    case .standard:
                        Text("7 columns × 6 rows")
                            .foregroundColor(.black)
                    case .random:
                        Text("Random size (5-10 columns × 4-8 rows)")
                            .foregroundColor(.black)
                    case .custom(let dimensions):
                        Text("\(dimensions.columns) columns × \(dimensions.rows) rows")
                            .foregroundColor(.black)
                    }
                }
            }
            .navigationTitle("Game Settings")
            .navigationBarItems(trailing: Button("Done") {
                showSettings = false
            }
            .foregroundColor(.orange)
            .padding(8)
            .background(Color.black.opacity(0.1))
            .cornerRadius(8))
            .background(Color.white) // Keep the form background white for readability
        }
    }
}

#Preview {
    MainMenuView()
}
