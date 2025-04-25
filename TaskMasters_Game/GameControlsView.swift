import SwiftUI

struct GameControlsView: View {
    @ObservedObject var viewModel: ConnectFourViewModel
    @State private var showBoardOptions = false

    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 20) {
                Button(action: {
                    if viewModel.gameState == .playing {
                        viewModel.pauseGame()
                    } else if viewModel.gameState == .paused {
                        viewModel.resumeGame()
                    }
                }) {
                    Text(viewModel.gameState == .paused ? "▶️ Resume" : "⏸️ Pause")
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow.opacity(0.9))
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.2), radius: 3)
                }

                Button(action: {
                    viewModel.resetGame()
                    SoundManager.shared.playSound(named: "win")
                }) {
                    Text("🔁 Restart")
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.2), radius: 3)
                }
            }
            
            // New game board options
            Menu {
                Button(action: {
                    viewModel.resetGame(boardType: .standard, randomPlayer: false)
                    SoundManager.shared.playSound(named: "win")
                }) {
                    Label("Standard Board (7×6)", systemImage: "gamecontroller")
                }
                
                Button(action: {
                    viewModel.resetGame(boardType: .random, randomPlayer: true)
                    SoundManager.shared.playSound(named: "win")
                }) {
                    Label("Random Board Size", systemImage: "dice")
                }
                
                Button(action: {
                    showBoardOptions = true
                }) {
                    Label("Custom Board Size", systemImage: "slider.horizontal.3")
                }
            } label: {
                Text("🎲 New Board")
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(Color.orange.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.2), radius: 3)
            }
        }
        .padding()
        .background(Color.black.opacity(0.1))
        .cornerRadius(15)
        .sheet(isPresented: $showBoardOptions) {
            CustomBoardOptionsSheet(viewModel: viewModel, isPresented: $showBoardOptions)
        }
    }
}

// Extracted to a separate view for reuse
struct CustomBoardOptionsSheet: View {
    @ObservedObject var viewModel: ConnectFourViewModel
    @Binding var isPresented: Bool
    @State private var selectedColumns = 7
    @State private var selectedRows = 6
    @State private var randomStartingPlayer = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Board Dimensions").foregroundColor(.orange)) {
                    Stepper("Columns: \(selectedColumns)", value: $selectedColumns, in: 5...10)
                        .foregroundColor(.black)
                    
                    Stepper("Rows: \(selectedRows)", value: $selectedRows, in: 4...10)
                        .foregroundColor(.black)
                }
                
                Section(header: Text("Starting Player").foregroundColor(.orange)) {
                    Toggle("Random First Player", isOn: $randomStartingPlayer)
                        .tint(.orange)
                }
                
                Section {
                    Button(action: {
                        viewModel.resetGame(
                            boardType: .custom(BoardDimensions(rows: selectedRows, columns: selectedColumns)),
                            randomPlayer: randomStartingPlayer
                        )
                        SoundManager.shared.playSound(named: "win")
                        isPresented = false
                    }) {
                        Text("Start New Game")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Custom Board")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            }
            .foregroundColor(.orange)
            .padding(8)
            .background(Color.black.opacity(0.1))
            .cornerRadius(8))
        }
    }
}

#Preview {
    GameControlsView(viewModel: ConnectFourViewModel())
}
