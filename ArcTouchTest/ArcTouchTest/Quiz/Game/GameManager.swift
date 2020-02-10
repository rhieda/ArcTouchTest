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
typealias UpdateTimeHandler = (TimeInterval) -> ()

protocol GameManagerProtocol {
    var game: Game { get set }
    var timer: Timer! { get set }
    var timeInSeconds: TimeInterval {get}
    var timeElapsed: TimeInterval {get set}
    var correctAnswers: [String]! { get set }
    var totalOfCorrectAnswers: Int { get }
    var gameStatus: GameState { get }
    var totalOfAnswers: Int {get}
    var finishGameHandler: FinishGameHandler { get set }
    var updateScoreHandler: UpdateScoreHandler { get set }
    var updateTimeHandler: UpdateTimeHandler { get set }
    var gameQuestion: String { get }
    func checkKeyword(with inputValue: String)
    func startGame()
    func endGame()
    func isGameRunning() -> Bool
    func performUpdates()
    func timeLeft() -> TimeInterval
}

class GameManager: GameManagerProtocol {
    
    var game: Game
    var timer: Timer!
    var timeInSeconds: TimeInterval
    var timeElapsed: TimeInterval
    
    var finishGameHandler: FinishGameHandler
    var updateScoreHandler: UpdateScoreHandler
    var updateTimeHandler: UpdateTimeHandler
    
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
    
    var totalOfAnswers: Int {
        game.totalOfAnswers
    }
    
    init(with newGame: Game, gameTimeInSeconds: TimeInterval, finishHandler: @escaping FinishGameHandler, scoreHandler: @escaping UpdateScoreHandler, timeHandler: @escaping UpdateTimeHandler) {
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
        correctAnswers = []
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(performUpdates), userInfo: nil, repeats: true)
    }
    
    func endGame() {
        game.gameState = .finished
        timeElapsed = 0
        guard let timer = timer else { return }
        timer.invalidate()
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
                updateTimeHandler(timeLeft())
                endGame()
            } else {
                updateTimeHandler(timeLeft())
            }
        }
    }
    
    func timeLeft() -> TimeInterval {
        let time = (timeInSeconds - timeElapsed)
        return time >= 0 ? time : 0
    }
    
    func checkKeyword(with inputValue: String) {
        if isGameRunning() {
            if (game.gameData.answers?.contains(inputValue))! && !correctAnswers.contains(inputValue) {
                correctAnswers.append(inputValue)
            }
        }
    }
}
