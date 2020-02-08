//
//  GameManager.swift
//  ArcTouchTest
//
//  Created by Rafael  Hieda on 2/8/20.
//  Copyright © 2020 Rafael_Hieda. All rights reserved.
//

import Foundation

protocol GameManagerProtocol {
    var game: Game { get set }
    var timer: Timer! { get set }
    var timeInSeconds: Int! {get}
    var timeElapsed: Int! {get set}
    func checkKeyword(with inputValue: String)
    func startGame()
    func endGame(completionHandler: @escaping () -> ())
    func isGameRunning() -> Bool
    func performUpdates()
    func timeLeft() -> Int
}

class GameManager: GameManagerProtocol {
    
    var game: Game
    var timer: Timer!
    var timeInSeconds: Int!
    var timeElapsed: Int!
    init(with game: Game, and timeInSeconds: Int) {
        self.game = game
        self.timer = Timer(timeInterval: 1, target: self, selector: #selector(performUpdates), userInfo: nil, repeats: false)
        self.timeInSeconds = timeInSeconds
        timeElapsed = 0
    }
    
    func checkKeyword(with inputValue: String) {
        
    }
    
    func startGame() {
        
    }
    
    func endGame(completionHandler: @escaping () -> ()) {
        
    }
        
    func isGameRunning() -> Bool {
        fatalError("Not Implemented yet")
    }
    
    @objc func performUpdates() {
        
    }
    
    func timeLeft() -> Int {
        fatalError("Not Implemented yet")
    }
}
