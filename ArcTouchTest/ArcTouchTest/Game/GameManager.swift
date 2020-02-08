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
    func checkKeyword(with inputValue: String)
    func startGame()
    func endGame()
    func prepareGame()
}
