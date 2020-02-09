//
//  QuizViewModelTests.swift
//  ArcTouchTestTests
//
//  Created by Rafael  Hieda on 2/9/20.
//  Copyright © 2020 Rafael_Hieda. All rights reserved.
//

import XCTest
@testable import ArcTouchTest

class QuizViewModelTests: XCTestCase {
    
    var sut: QuizViewModelProtocol!
    var gameManager: GameManagerProtocol!
    var game: Game!
    var uiDelegate: QuizUIDelegateSpy!
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        uiDelegate = QuizUIDelegateSpy()
        sut = QuizViewModel(uiDelegate: uiDelegate)
        
        let testBundle = Bundle(for: type(of: self))
        let filepath = testBundle.path(forResource: "GameResponse", ofType: "json")!
        var gr: GameResponse!
        if let data = FileManager().contents(atPath: filepath),
            let gameResponse = try? JSONDecoder().decode(GameResponse.self, from: data) {
            gr = gameResponse
        }
        
        game = Game(with: gr)
        
        gameManager = GameManager(with: game, gameTimeInSeconds: 10, finishHandler: sut.finishHandler(with:), scoreHandler: sut.updateScoreHandler(with:), timeHandler: sut.updateTime(with:))
        sut.gameManager = gameManager
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testViewModelShouldReturnValidNumberOfCorrectAnswers() {
        sut.gameManager.correctAnswers = game.gameData.answers
        XCTAssertEqual(sut.totalOfCorrectAnswers(), 50)
    }
    
    func testViewModelShouldReturnAnswerGivenIndexPath() {
        sut.gameManager.correctAnswers = game.gameData.answers
        let indexPath = IndexPath(row: 0, section: 0)
        let expectedAnswer = sut.answerFor(indexPath: indexPath)
        let answer = "abstract"
        sut.startGame()
        XCTAssertEqual(answer, expectedAnswer)
    }
    
    func testViewModelShouldStartGame() {
        sut.startGame()
        XCTAssertEqual(gameManager.gameStatus, .started)
    }
    
    func testViewModelShouldEndGame() {
        sut.startGame()
        sut.endGame()
        XCTAssertEqual(gameManager.gameStatus, .finished)
    }
    
    func testViewModelShouldCallFinishHandler() {
        let gameScore = GameScore.win
        sut.finishHandler(with: gameScore)
        XCTAssertTrue(uiDelegate.didCallFinishGame)
    }
    
    func testViewModelShouldCallUpdateScoreHandler() {
        sut.updateScoreHandler(with: 10)
        XCTAssertTrue(uiDelegate.didCallUpdateScore)
    }
    
    func testViewModelShouldCallUpdateTime() {
        sut.updateTime(with: 1)
        XCTAssertTrue(uiDelegate.didCallUpdateTime)
    }
    
    func testSubmitKeywordIsInserted() {
        let word = "abstract"
        var correctAnswers = game.gameData.answers!
        correctAnswers.removeFirst()
        sut.gameManager.correctAnswers = correctAnswers
        sut.startGame()
        sut.submitWord(with: word)
        
        XCTAssertEqual(sut.totalOfCorrectAnswers(), 50)
        XCTAssertFalse(gameManager.isGameRunning())
        XCTAssertTrue(gameManager.correctAnswers.contains(word))
        
    }
    
    func testSubmitKeywordIsRejected() {
        let word = "abstrakt"
        var correctAnswers = game.gameData.answers!
        correctAnswers.removeFirst()
        sut.gameManager.correctAnswers = correctAnswers
        sut.startGame()
        sut.submitWord(with: word)
        
        XCTAssertNotEqual(sut.totalOfCorrectAnswers(), 50)
        XCTAssertTrue(gameManager.isGameRunning())
        XCTAssertFalse(correctAnswers.contains(word))
    }
    
    func testViewModelShouldHaveValidGameManagerIfSuccessGameResponse() {
        let gameResponse = game.gameData
        let result = Result.success(gameResponse)
        
        sut.handleGameResponse(with: result)
        XCTAssertNotNil(sut.gameManager)
    }
    
    func testViewModelShouldHaveNilGameManagerIfErrorWhileFetchingGameResponse() {
        sut.gameManager = nil
        let result = Result<GameResponse>.error(NetworkError.noDataFromServer)
        sut.handleGameResponse(with: result)
        XCTAssertNil(sut.gameManager)
        XCTAssertTrue(uiDelegate.didCallDisplayGameDataError)
    }
    
    
    
    

}

final class QuizUIDelegateSpy: QuizUIDelegate {
    
    var didCallUpdateScore: Bool = false
    var didCallUpdateTime: Bool = false
    var didCallFinishGame: Bool = false
    var didCallDisplayGameDataError: Bool = false
    
    func updateScore(with updatedScore: Int) {
        didCallUpdateScore = true
    }
    
    func updateTime(with labeledTime: String) {
        didCallUpdateTime = true
    }
    
    func finishGame(with gameState: GameScore) {
        didCallFinishGame = true
    }
    
    func displayGameDataError(with stringError: String) {
        didCallDisplayGameDataError = true
    }
    
}
