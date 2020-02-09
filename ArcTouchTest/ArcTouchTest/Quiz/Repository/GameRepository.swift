//
//  GameRepository.swift
//  ArcTouchTest
//
//  Created by Rafael  Hieda on 2/8/20.
//  Copyright © 2020 Rafael_Hieda. All rights reserved.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidStatusCode(Int)
    case noResponse
    case noDataFromServer
    case invalidParsingData(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Invalid URL", comment: "")
        case .invalidStatusCode(let code):
            return NSLocalizedString("Invalid HTTP Status Code: \(code)", comment: "")
        case .noDataFromServer:
            return NSLocalizedString("Received no data from server", comment: "")
        case .noResponse:
            return NSLocalizedString("Received no response from server", comment: "")
        case .invalidParsingData(let className):
            return NSLocalizedString("Could not parse \(className)", comment: "")
        }
    }
}

protocol GameRepositoryProtocol: class {
    var url: URL? { get }
    func fetchGameData(completionHandler: @escaping (Result<GameResponse>) -> ())
}

final class GameRepository: GameRepositoryProtocol {
    
    var url: URL?
    
    init(stringURL: String) {
        guard let url = URL(string: stringURL) else { return }
        self.url = url
    }
    
    func fetchGameData(completionHandler: @escaping (Result<GameResponse>) -> ()) {
        guard let url = self.url else {
            completionHandler(.error(NetworkError.invalidURL))
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, responseError) in
            if let error = responseError {
                completionHandler(.error(error))
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completionHandler(.error(NetworkError.noResponse))
                return
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                do {
                    guard let data = data else {
                        completionHandler(.error(NetworkError.noDataFromServer))
                        return
                    }
                    if let gameResponse = try? JSONDecoder().decode(GameResponse.self, from: data) {
                        completionHandler(.success(gameResponse))
                    } else {
                        completionHandler(.error(NetworkError.invalidParsingData(String(describing: GameResponse.self))))
                    }
                }
            } else {
                completionHandler(.error(NetworkError.invalidStatusCode(httpResponse.statusCode)))
            }
        }.resume()
    }
}
