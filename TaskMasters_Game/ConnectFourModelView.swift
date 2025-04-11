//
//  ConnectFourModelView.swift
//  TaskMasters_Game
//
//  Created by Jesten Scheideger on 4/11/25.
//

import Foundation
import SwiftUI

class ConnectFourViewModel: ObservableObject {
    @Published private var model = ConnectFourModel()
    @Published var dragColumn: Int? = nil

    var board: [[Player?]] {
        model.board
    }

    var currentPlayer: Player {
        model.currentPlayer
    }

    var winner: Player? {
        model.winner
    }

    func dropPiece(in column: Int) {
        if model.dropPiece(in: column) {
            SoundManager.shared.playSound(named: "drop")
        }
        objectWillChange.send()
    }

    func resetGame() {
        model.reset()
        objectWillChange.send()
    }

    func colorFor(_ player: Player?) -> Color {
        switch player {
        case .red: return .red
        case .yellow: return .yellow
        case .none: return .gray.opacity(0.3)
        }
    }
}
