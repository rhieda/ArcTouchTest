//
//  GameManager.swift
//  ArcTouchTest
//
//  Created by Rafael  Hieda on 2/8/20.
//  Copyright © 2020 Rafael_Hieda. All rights reserved.
//

import Foundation

typealias FinishGameHandler = (GameScore) -> ()
typealias UpdateScoreHandler = (Int) -> ()
typealias UpdateTimeHandler = (Int) -> ()

protocol GameManagerProtocol {
    var game: Game { get set }
    var timer: Timer! { get set }
    var timeInSeconds: Int {get}
    var timeElapsed: Int {get set}
    var correctAnswers: [String]! { get set }
    var gameStatus: GameState { get }
    var totalOfCorrectAnswers: Int { get }
    var finishGameHandler: FinishGameHandler { get set }
    var updateScoreHandler: UpdateScoreHandler { get set }
    var updateTimeHandler: UpdateScoreHandler { get set }
    func checkKeyword(with inputValue: String)
    func startGame()
    func endGame()
    func isGameRunning() -> Bool
    func performUpdates()
    func timeLeft() -> Int
}

class GameManager: GameManagerProtocol {
    
    var game: Game
    var timer: Timer!
    var timeInSeconds: Int
    var timeElapsed: Int
    
    var finishGameHandler: FinishGameHandler
    var updateScoreHandler: UpdateScoreHandler
    var updateTimeHandler: UpdateScoreHandler
    
    var gameStatus: GameState {
        return game.gameState
    }
    
    var gameQuestion: String {
        guard let question = game.gameData.question else {
            return ""
        }
        return question
    }
    
    private var answers: [String] {
        guard let answers = game.gameData.answers else {
            return []
        }
        return answers
    }
    
    var correctAnswers: [String]! {
        didSet {
            if correctAnswers.count == answers.count {
                endGame()
            } else {
                updateScoreHandler(totalOfCorrectAnswers)
            }
        }
    }
    
    var totalOfCorrectAnswers: Int {
        correctAnswers.count
    }
    
    init(with newGame: Game, gameTimeInSeconds: Int, finishHandler: @escaping FinishGameHandler, scoreHandler: @escaping UpdateScoreHandler, timeHandler: @escaping UpdateTimeHandler) {
        game = newGame
        timeInSeconds = gameTimeInSeconds
        timeElapsed = 0
        correctAnswers = []
        finishGameHandler = finishHandler
        updateScoreHandler = scoreHandler
        updateTimeHandler = timeHandler
    }
    
    func startGame() {
        game.gameState = .started
        self.timer = Timer(timeInterval: 1, target: self, selector: #selector(performUpdates), userInfo: nil, repeats: false)
    }
    
    func endGame() {
        game.gameState = .finished
        if timeElapsed < timeInSeconds && (correctAnswers.count == answers.count) {
            finishGameHandler(.win)
        } else {
            finishGameHandler(.loss(correctAnswers.count))
        }
    }
        
    func isGameRunning() -> Bool {
        return (timer.isValid) && (gameStatus == .started)
    }
    
    @objc func performUpdates() {
        if isGameRunning() {
            timeElapsed += 1
            if timeElapsed >= timeInSeconds {
                timer.invalidate()
                endGame()
            } else {
                updateTimeHandler(timeElapsed)
            }
        }
    }
    
    func timeLeft() -> Int {
        return (timeInSeconds - timeElapsed) >= 0 ? (timeInSeconds - timeElapsed) : 0
    }
    
    func checkKeyword(with inputValue: String) {
        if isGameRunning() {
            if (game.gameData.answers?.contains(inputValue))! && !correctAnswers.contains(inputValue) {
                correctAnswers.append(inputValue)
            }
        }
    }
}
