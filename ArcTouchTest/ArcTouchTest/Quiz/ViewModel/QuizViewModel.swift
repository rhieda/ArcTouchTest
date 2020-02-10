//
//  QuizViewModel.swift
//  ArcTouchTest
//
//  Created by Rafael  Hieda on 2/9/20.
//  Copyright © 2020 Rafael_Hieda. All rights reserved.
//

import Foundation

protocol QuizViewModelProtocol: class, QuizViewModelHandlerProtocol {
    var uiDelegate: QuizUIDelegate { get }
    var repository: GameRepositoryProtocol { get }
    var gameManager: GameManagerProtocol! { get set }
    var gameState: GameState { get }
    
    func totalOfCorrectAnswers() -> Int
    func answerFor(indexPath: IndexPath) -> String
    func startGame()
    func endGame()
    func resetGame()
    func submitWord(with word: String)
    func fetchGameData()
    func handleGameResponse(with response: Result<GameResponse>)
}

protocol QuizViewModelHandlerProtocol {
    func finishHandler(with gameScore: GameScore)
    func updateScoreHandler(with newScore: Int)
    func updateTime(with currentTime: TimeInterval)
}

protocol QuizUIDelegate: class {
    func updateScore(with updatedScore: Int)
    func updateTime(with labeledTime: String)
    func finishGame(with gameState: GameScore)
    func displayGameDataError(with stringError: String)
}

final class QuizViewModel: QuizViewModelProtocol {
        
    var repository: GameRepositoryProtocol
    var gameManager: GameManagerProtocol!
    var uiDelegate: QuizUIDelegate
    
    var gameState: GameState {
        return gameManager.gameStatus
    }
    
    init(uiDelegate: QuizUIDelegate) {
        repository = GameRepository(stringURL: "https://codechallenge.arctouch.com/quiz/1")
        self.uiDelegate = uiDelegate
    }
    
    func totalOfCorrectAnswers() -> Int {
        return gameManager.totalOfCorrectAnswers
    }
    
    func totalOfAnswers() -> Int {
        return gameManager.game.gameData.answers!.count
    }
    
    func answerFor(indexPath: IndexPath) -> String {
        return gameManager.correctAnswers[indexPath.row]
    }
    
    func startGame() {
        gameManager.startGame()
    }
    
    func endGame() {
        gameManager.endGame()
    }
    
    func resetGame() {
        gameManager.endGame()
        gameManager.correctAnswers = []
        gameManager.timeElapsed = 0
    }
    
    func submitWord(with word: String) {
        gameManager.checkKeyword(with: word)
    }
    
    func fetchGameData() {
        repository.fetchGameData { [weak self] (response) in
            guard let self = self else { return }
            self.handleGameResponse(with: response)
        }
    }
    
    func handleGameResponse(with response: Result<GameResponse>) {
        switch response {
        case .success(let gameResponse):
            let game = gameResponse.toGame()
            gameManager = GameManager(with: game, gameTimeInSeconds: 10, finishHandler: self.finishHandler(with:), scoreHandler: self.updateScoreHandler(with:), timeHandler: self.updateTime(with:))
            break
        case .error(let error):
            uiDelegate.displayGameDataError(with: error.localizedDescription)
            break
        }
    }
        
    func finishHandler(with gameScore: GameScore) {
        uiDelegate.finishGame(with: gameScore)
    }
    
    func updateScoreHandler(with newScore: Int) {
        uiDelegate.updateScore(with: newScore)
    }
    
    func updateTime(with currentTime: TimeInterval) {
        uiDelegate.updateTime(with: TimeToStringHelper.timeToMinutes(with: currentTime))
    }
        
}

class TimeToStringHelper {
    static func timeToMinutes(with inputTime: TimeInterval) -> String {
        let minutes = Int(inputTime) / 60 % 60
        let seconds = Int(inputTime) % 60
        let formattedTimeString = String(format: "%02i:%02i", minutes, seconds)
        return formattedTimeString
    }
}
