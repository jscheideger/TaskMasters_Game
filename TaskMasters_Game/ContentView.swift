import SwiftUI

struct ContentView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showBackConfirmation = false
    @ObservedObject var viewModel: ConnectFourViewModel
    @State private var dragOffset: CGSize = .zero
    
    // Initialize with a fresh board using the settings from MainMenuView
    init(viewModel: ConnectFourViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    // Calculate circle size based on screen and board dimensions
    var circleSize: CGFloat {
        let screenWidth = UIScreen.main.bounds.width - 40 // Some padding
        let columnSpace = screenWidth / CGFloat(viewModel.columns)
        return min(columnSpace - 10, 50) // Max size of 50, with 10pt spacing
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Apply background gradient
                Theme.backgroundGradient()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 15) {
                    // Player name inputs
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Enter Player Names")
                            .font(.headline)
                            .foregroundColor(Theme.titleColor)
                        
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
                        .background(Color.white.opacity(0.4)) // Improved contrast for text fields
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Board Size: \(viewModel.columns)×\(viewModel.rows)")
                            .font(.subheadline)
                            .foregroundColor(Theme.bodyTextColor)
                        
                        Spacer()
                        
                        Text("Current Player: \(viewModel.currentPlayer.rawValue)")
                            .font(.headline)
                            .foregroundColor(viewModel.currentPlayer == .red ? .red : .orange)
                    }
                    .padding(.horizontal)
                    
                    // Game board - dynamically sized
                    ScrollView([.horizontal, .vertical], showsIndicators: true) {
                        HStack(spacing: 5) {
                            ForEach(0..<viewModel.columns, id: \.self) { col in
                                VStack(spacing: 5) {
                                    ForEach((0..<viewModel.rows).reversed(), id: \.self) { row in
                                        Circle()
                                            .foregroundColor(viewModel.colorFor(viewModel.board[col][row]))
                                            .frame(width: circleSize, height: circleSize)
                                            .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
                                            .overlay(Circle().stroke(Color.orange.opacity(0.4)))
                                            .transition(.move(edge: .top))
                                            .animation(.spring(), value: viewModel.board[col][row])
                                    }
                                    .onTapGesture {
                                        withAnimation {
                                            viewModel.dropPiece(in: col)
                                        }
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
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.2), radius: 10)
                    }
                    .frame(maxHeight: CGFloat(viewModel.rows) * (circleSize + 10))
                   
                    DraggableToken(player: viewModel.currentPlayer, size: circleSize)
              
                    // Win or draw message
                    if let winner = viewModel.winner {
                        let winnerName = winner == .red ? viewModel.redPlayerName : viewModel.yellowPlayerName
                        Text("\(winner.rawValue) \(winnerName) wins!")
                            .font(.title)
                            .foregroundColor(winner == .red ? .red : .orange)
                            .padding()
                        
                        // Navigation links
                        HStack(spacing: 15) {
                            NavigationLink(destination: MatchHistoryView(viewModel: viewModel)) {
                                Text("⏮️ Match History")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Theme.secondaryButtonColor)
                                    .foregroundColor(Theme.secondaryButtonTextColor)
                                    .cornerRadius(10)
                            }
                            
                            NavigationLink(destination: LeaderboardView(viewModel: viewModel)) {
                                Text("🏅 Leaderboard")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Theme.primaryButtonColor)
                                    .foregroundColor(Theme.primaryButtonTextColor)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    } else if viewModel.gameState == .draw {
                        Text("It's a draw!")
                            .font(.title)
                            .foregroundColor(.orange)
                            .padding()
                        
                        // Navigation links for draw case
                        HStack(spacing: 15) {
                            NavigationLink(destination: MatchHistoryView(viewModel: viewModel)) {
                                Text("⏮️ Match History")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Theme.secondaryButtonColor)
                                    .foregroundColor(Theme.secondaryButtonTextColor)
                                    .cornerRadius(10)
                            }
                            
                            NavigationLink(destination: LeaderboardView(viewModel: viewModel)) {
                                Text("🏅 Leaderboard")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Theme.primaryButtonColor)
                                    .foregroundColor(Theme.primaryButtonTextColor)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    GameControlsView(viewModel: viewModel)
                }
                .padding()
            }
           
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showBackConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.orange.opacity(0.8))
                    .cornerRadius(8)
                }
            }
        }
        .alert("Are you sure you want to leave the game?", isPresented: $showBackConfirmation) {
            Button("Leave", role: .destructive) {
                presentationMode.wrappedValue.dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

struct DraggableToken: View {
    let player: Player
    let size: CGFloat
    
    var body: some View {
        Text(player.rawValue)
            .font(.system(size: size * 0.8))
            .frame(width: size + 10, height: size + 10)
            .background(Circle().fill(Color.white))
            .shadow(radius: 5)
            .onDrag {
                return NSItemProvider(object: NSString(string: player.rawValue))
            }
    }
}

#Preview {
    ContentView(viewModel: ConnectFourViewModel())
}
