//
//  Game.swift
//  ArcTouchTest
//
//  Created by Rafael  Hieda on 2/8/20.
//  Copyright © 2020 Rafael_Hieda. All rights reserved
//

import Foundation

struct Game {
    var gameState: GameState
    var gameData: GameResponse
    init(with gameData: GameResponse) {
        gameState = .finished
        self.gameData = gameData
    }
}

struct GameResponse: Decodable {
    var question: String?
    var answers: [String]?
    
    enum CodingKeys: String, CodingKey {
        case question
        case answers = "answer"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        question = try container.decode(String.self, forKey: .question)
        answers = try container.decode([String].self, forKey: .answers)
    }
}

enum GameState {
    case started
    case finished
}

enum GameScore {
    case win
    case loss(Int)
}

