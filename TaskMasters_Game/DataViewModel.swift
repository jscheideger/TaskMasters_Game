//
//  DataViewModel.swift
//  TaskMasters_Game
//
//  Created by Gannon on 4/24/25.
//

import CoreData
import Foundation
class DataViewModel: ObservableObject {
    let container: NSPersistentContainer
    let secondaryContainer: NSPersistentContainer

    
    @Published var savedentries: [PlayerEntity] = []
    @Published var MatchArray: [MatchEntity] = []
    


    
    init() {
        container = NSPersistentContainer(name: "PlayerModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("ERROR LOADING DATA: \(error.localizedDescription)")
            }else{
                print("Successfully loaded Core Data")
            }
        }
        //second container
        secondaryContainer = NSPersistentContainer(name: "MatchModel")
           secondaryContainer.loadPersistentStores { description, error in
               if let error = error {
                   print("ERROR LOADING MatchModel: \(error.localizedDescription)")
               } else {
                   print("✅ MatchModel loaded")
               }
           }
        
        fetchPlayerData()
        fetchMatchData()
    }
    func fetchPlayerData(){
        let request = NSFetchRequest<PlayerEntity>(entityName: "PlayerEntity")
        
        do{
            try savedentries = container.viewContext.fetch(request)
        }catch let error{
            print("Error fetching data: \(error.localizedDescription)")
        }
        
    }
    func fetchMatchData(){
        let request = NSFetchRequest<MatchEntity>(entityName: "MatchEntity")
        
        do{
            try MatchArray = secondaryContainer.viewContext.fetch(request)
        }catch let error{
            print("Error fetching data: \(error.localizedDescription)")
        }
        
    }

    func addPlayer(player: PlayerStats){
        let newPlayer = PlayerEntity(context: container.viewContext)
        newPlayer.name = player.name
        newPlayer.id = player.id
        newPlayer.totalGames = Int64(player.totalGames)
        newPlayer.winRate = player.winRate
        newPlayer.wins = Int64(player.wins)
        

        saveData()
        //print (newBook.title ?? "No title") //debugging

    }

    
    func deletePlayer(player: PlayerStats){
        if let existingPlayer = savedentries.first(where: {$0.name == player.name}){
            container.viewContext.delete(existingPlayer)
            
        }
        saveData()

    }
    
    func clearAll() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = PlayerEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try container.viewContext.execute(deleteRequest)
            try container.viewContext.save()
            savedentries.removeAll() // Clear the local array too
            print("All player data cleared.")
        } catch {
            print("Failed to delete all player data: \(error.localizedDescription)")
        }
    }
    
    func updatePlayerData(for redName: String, for yellowName: String, redWon: Bool) { //true for red wins, false for yellow wins
        let winnerName = redWon ? redName : yellowName
        let loserName = redWon ? yellowName : redName
        //updates winner
        if let index = savedentries.first(where: { $0.name == winnerName }) {
            index.wins += 1
            index.totalGames += 1
            index.winRate = Double(index.wins) / Double(index.totalGames)
        } else {
            addPlayer(player:PlayerStats(name: winnerName, wins: 1, totalGames: 1))
        }
        //updates loser
        if let index = savedentries.first(where: { $0.name == loserName }) {
            index.totalGames += 1
            index.winRate = Double(index.wins) / Double(index.totalGames)
        } else {
            addPlayer(player:PlayerStats(name: loserName, wins: 0, totalGames: 1))
        }

        savedentries.sort { $0.winRate > $1.winRate }
        
        saveData()
    }
    
   

    
    private var databaseCount: Int{
        do{
            let count = try container.viewContext.count(for:PlayerEntity.fetchRequest())
            return count
        }catch{
            print("Error getting count: \(error)")
            return 0
        }
    }
    
    func saveData(){
        do{
            print("Number of Players (prefetch): \(databaseCount)")
            try container.viewContext.save()
            fetchPlayerData()
            print("Number of Players (postfetch): \(savedentries.count)")
        }catch let error{
            print("Error saving data: \(error.localizedDescription)")
        }
                
    }
    
}
