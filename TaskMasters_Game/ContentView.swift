import SwiftUI

struct ContentView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showBackConfirmation = false
    @ObservedObject var viewModel: ConnectFourViewModel
    @State private var dragOffset: CGSize = .zero


    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 15) {
                    
                    
                    // Player name inputs
                    VStack(alignment: .leading, spacing: 5) {
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
                    
                    // Game board
                    
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
                                //added this because my trackpad SUCKS -Gannon
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
                   
                    DraggableToken(player: viewModel.currentPlayer)
              
                    
                    // Win message
                    if let winner = viewModel.winner {
                        let winnerName = winner == .red ? viewModel.redPlayerName : viewModel.yellowPlayerName
                        Text("\(winner.rawValue) \(winnerName) wins!")
                            .font(.title)
                            .foregroundColor(.green)
   
                        
                        
                        
                        
                        Divider()
                        
                        // Navigation links
                        HStack(spacing: 15) {
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
                }
            }
        }
        .alert("Are you sure you want to leave the game?", isPresented: $showBackConfirmation) {
            Button("Leave", role: .destructive) {
                presentationMode.wrappedValue.dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }

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

#Preview {
    ContentView(viewModel: ConnectFourViewModel())
}
