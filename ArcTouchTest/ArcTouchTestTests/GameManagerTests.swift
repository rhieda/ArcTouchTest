//
//  GameManagerTests.swift
//  ArcTouchTestTests
//
//  Created by Rafael  Hieda on 2/8/20.
//  Copyright © 2020 Rafael_Hieda. All rights reserved.
//

import XCTest
@testable import ArcTouchTest

class GameManagerTests: XCTestCase {
    
    var sut: GameManagerProtocol!
    var game: Game!
    var filepath: String!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let testBundle = Bundle(for: type(of: self))
        filepath = testBundle.path(forResource: "GameResponse", ofType: "json")
        var gr: GameResponse!
        if let data = FileManager().contents(atPath: filepath),
            let gameResponse = try? JSONDecoder().decode(GameResponse.self, from: data) {
            gr = gameResponse
        }
        
        game = Game(with: gr)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testManagerShouldStartGame() {
        sut = GameManager(with: game, gameTimeInSeconds: 10, finishHandler: { _ in }, scoreHandler: {_ in}, timeHandler: {_ in})
        sut.startGame()
        XCTAssertTrue(sut.isGameRunning() == true)
        XCTAssertTrue(sut.timer.isValid)
    }
    
    func testManagerShouldEndGameWinning() {
        let expectation = XCTestExpectation(description: "Start game")
        var win: GameScore!
        sut = GameManager(with: game, gameTimeInSeconds: 10, finishHandler: { (gameScore) in
            switch gameScore {
            case .win:
                win = gameScore
            case .loss(_):
                XCTFail("Loss is not expected in this test")
            }
            XCTAssertNotNil(win)
            expectation.fulfill()
        }, scoreHandler: {_ in}, timeHandler: {_ in})
        
        sut.startGame()
        XCTAssertTrue(sut.isGameRunning() == true)
        XCTAssertTrue(sut.timer.isValid)
        
        //Not going to implement Equatable in Enums, just to prevent excessive and possible increase of complexity in implementation
        
        //forcing right answers in the game
        sut.correctAnswers = sut.game.gameData.answers
        
        sut.endGame()
        wait(for: [expectation], timeout: 15)
    }
    
    func testManagerShouldEndGameLosing() {
        let expectation = XCTestExpectation(description: "Start game")
        var loss: Int = 0
    
        sut = GameManager(with: game, gameTimeInSeconds: 10, finishHandler: { (gameScore) in
            switch gameScore {
            case .win:
                XCTFail("Loss is not expected in this test")
            case .loss(let scoreCount):
                loss = scoreCount
            }
            //Not going to implement Equatable in Enums, just to prevent excessive and possible increase of complexity in implementation
            XCTAssertNotNil(loss)
            XCTAssertEqual(49, self.sut.totalOfCorrectAnswers)
            expectation.fulfill()
        }, scoreHandler: {_ in}, timeHandler: {_ in})
        
        //forcing right answers in the game
        var correctAnswers = sut.game.gameData.answers!
        //force lose
        correctAnswers.removeLast()
        sut.correctAnswers = correctAnswers
        
        sut.startGame()
        XCTAssertTrue(sut.isGameRunning() == true)
        XCTAssertTrue(sut.timer.isValid)
        sut.endGame()
        wait(for: [expectation], timeout: 15)
    }
    
    func testKeywordShouldBeAddedIfCorrectInCorrectAnswersArray() {
        let correctAnswer = "abstract"
        sut = GameManager(with: game, gameTimeInSeconds: 10, finishHandler: {_ in}, scoreHandler: {_ in}, timeHandler: {_ in})
        
        //forcing to have the first answer "Abstract off" so I can add it.
        var correctAnswers = sut.game.gameData.answers!
        correctAnswers.removeFirst() //49
        sut.correctAnswers = correctAnswers
        sut.startGame()
        sut.checkKeyword(with: correctAnswer)
        
        XCTAssertTrue(sut.correctAnswers.contains(correctAnswer))
        XCTAssertTrue(sut.correctAnswers.count == 50) //50
        XCTAssertTrue(sut.gameStatus == .finished)
    }
    
    func testKeywordShouldNotBeAddedIfValidAndAlreadyPresentInCorrectAnswers() {
        let correctAnswer = "abstract"
        sut = GameManager(with: game, gameTimeInSeconds: 10, finishHandler: {_ in}, scoreHandler: {_ in}, timeHandler: {_ in})
        
        //forcing to have the first answer "Abstract off" so I can add it.
        var correctAnswers = sut.game.gameData.answers!
        correctAnswers.removeLast() //49
        sut.correctAnswers = correctAnswers
        
        sut.startGame()
        sut.checkKeyword(with: correctAnswer)
        
        XCTAssertTrue(sut.correctAnswers.contains(correctAnswer))
        XCTAssertTrue(sut.correctAnswers.count == 49) //50
        XCTAssertTrue(sut.game.gameState == .started)
    }
    
    func testKeywordShouldNotBeAddedIfIncorrectAnswer() {
        let incorrectAnswer = "publik"
        sut = GameManager(with: game, gameTimeInSeconds: 10, finishHandler: {_ in}, scoreHandler: {_ in}, timeHandler: {_ in})
        
        var correctAnswers = sut.game.gameData.answers!
        correctAnswers.removeLast()
        sut.correctAnswers = correctAnswers
        
        sut.startGame()
        sut.checkKeyword(with: incorrectAnswer)
        
        XCTAssertFalse(sut.correctAnswers.contains(incorrectAnswer))
        XCTAssertTrue(sut.correctAnswers.count == 49) //50
        XCTAssertTrue(sut.game.gameState == .started)
    }
    
    func testKeywordShouldNotBeAddedInCaseOfIncorrectAnswerAndNoCorrectAnswersInserted(){
        let incorrectAnswer = "publik"
        sut = GameManager(with: game, gameTimeInSeconds: 10, finishHandler: {_ in}, scoreHandler: {_ in}, timeHandler: {_ in})
        
        sut.startGame()
        sut.checkKeyword(with: incorrectAnswer)
        
        XCTAssertFalse(sut.correctAnswers.contains(incorrectAnswer))
        XCTAssertTrue(sut.correctAnswers.count == 0)
        XCTAssertTrue(sut.game.gameState == .started)
    }
    
    func testKeywordShouldBeAddedInCaseOfCorrectAnswerAndNoCorrectAnswersInserted(){
        let correctAnswer = "public"
        sut = GameManager(with: game, gameTimeInSeconds: 10, finishHandler: {_ in}, scoreHandler: {_ in}, timeHandler: {_ in})
        
        sut.startGame()
        sut.checkKeyword(with: correctAnswer)
        
        XCTAssertTrue(sut.correctAnswers.contains(correctAnswer))
        XCTAssertTrue(sut.correctAnswers.count == 1)
        XCTAssertTrue(sut.game.gameState == .started)
    }

}




