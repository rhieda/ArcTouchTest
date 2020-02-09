//
//  QuizViewModel.swift
//  ArcTouchTest
//
//  Created by Rafael  Hieda on 2/9/20.
//  Copyright © 2020 Rafael_Hieda. All rights reserved.
//

import Foundation

protocol QuizViewModelProtocol: class {
    var uiDelegate: QuizUIDelegate { get }
    var repository: GameRepositoryProtocol { get }
    var gameManager: GameManagerProtocol! { get set }
    
    func totalOfCorrectAnswers() -> Int
    func answerFor(indexPath: IndexPath) -> String
    func startGame()
    func endGame()
    func submitWord(with word: String)
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
    
    func totalOfCorrectAnswers() -> Int {
        return gameManager.totalOfCorrectAnswers
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
    
    func submitWord(with word: String) {
        gameManager.checkKeyword(with: word)
    }
    
    func fetchGameData() {
        repository.fetchGameData { [weak self] (response) in
            guard let self = self else { return }
            switch response {
            case .success(let gameResponse):
                let game = gameResponse.toGame()
                self.gameManager = GameManager(with: game, gameTimeInSeconds: 300, finishHandler: self.finishHandler(with:), scoreHandler: self.updateScoreHandler(with:), timeHandler: self.updateTime(with:))
                break
            case .error(let error):
                self.uiDelegate.displayGameDataError(with: error.localizedDescription)
                break
            }
        }
    }
    
    init(uiDelegate: QuizUIDelegate) {
        repository = GameRepository(stringURL: "")
        self.uiDelegate = uiDelegate
    }
        
}

extension QuizViewModel {
    
    func finishHandler(with gameScore: GameScore) {
        uiDelegate.finishGame(with: gameScore)
    }
    
    func updateScoreHandler(with newScore: Int) {
        uiDelegate.updateScore(with: newScore)
    }
    
    func updateTime(with currentTime: TimeInterval) {
        //perform time formatting to show up
//        uiDelegate.updateTime(with: <#T##String#>)
    }
}
