//
//  SoundManager.swift
//  TaskMasters_Game
//
//  Created by Jesten Scheideger on 4/11/25.
//

import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    var player: AVAudioPlayer?

    func playSound(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Sound error: \(error)")
        }
    }
}

