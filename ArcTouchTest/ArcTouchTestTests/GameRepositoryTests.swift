//
//  GameRepositoryTests.swift
//  ArcTouchTestTests
//
//  Created by Rafael  Hieda on 2/8/20.
//  Copyright © 2020 Rafael_Hieda. All rights reserved.
//

import XCTest
@testable import ArcTouchTest

class GameRepositoryTests: XCTestCase {
    
    var sut: GameRepositoryProtocol!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testRepositoryShouldFetchValidResultsIfValidURL() {
        var gameResp: GameResponse!
        var err: Error!
        sut = GameRepository(stringURL: "https://codechallenge.arctouch.com/quiz/1")
        let expectation = XCTestExpectation(description: "Should fetch data from server")
        sut.fetchGameData { (response) in
            XCTAssertNotNil(response, "Expected to have not empty responses if valid url")
            switch response {
            case .success(let gameResponse):
                gameResp = gameResponse
            case .error(let error):
                err = error
            }
            
            XCTAssertNil(err, "Expect no errors")
            XCTAssertNotNil(gameResp, "A valid game response is desired")
                        
            expectation.fulfill()
            
        }
        wait(for: [expectation], timeout: 15)
    }
    
    func testRepositoryShouldReturnErrorInvalidPathInURL() {
        var gameResp: GameResponse!
        var err: Error!
        sut = GameRepository(stringURL: "https://codechallenge.arctouch.com/quiz/xxxxxx")
        let expectation = XCTestExpectation(description: "Should try to fetch data from server")
        sut.fetchGameData { (response) in
            XCTAssertNotNil(response, "Should return a error")
            switch response {
            case .success(let gameResponse):
                gameResp = gameResponse
            case .error(let error):
                err = error
            }
            
            XCTAssertNotNil(err, "Expect no errors")
            XCTAssertTrue(err.localizedDescription == NetworkError.invalidStatusCode(403).localizedDescription)
            XCTAssertNil(gameResp, "A valid game is not expected")
                        
            expectation.fulfill()
            
        }
        wait(for: [expectation], timeout: 15)
    }
    
    func testRepositoryShouldReturnErrorInvalidURL() {
        var gameResp: GameResponse!
        var err: Error!
        sut = GameRepository(stringURL: "no url")
        let expectation = XCTestExpectation(description: "Should try to fetch data from server")
        sut.fetchGameData { (response) in
            XCTAssertNotNil(response, "Should return a error")
            switch response {
            case .success(let gameResponse):
                gameResp = gameResponse
            case .error(let error):
                err = error
            }
            
            XCTAssertNotNil(err, "Expect no errors")
            XCTAssert(err.localizedDescription == NetworkError.invalidURL.localizedDescription)
            XCTAssertNil(gameResp, "A valid game response is not expected")
                        
            expectation.fulfill()
            
        }
        wait(for: [expectation], timeout: 15)
    }
}
