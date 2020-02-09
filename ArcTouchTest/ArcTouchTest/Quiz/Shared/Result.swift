//
//  Result.swift
//  ArcTouchTest
//
//  Created by Rafael  Hieda on 2/8/20.
//  Copyright © 2020 Rafael_Hieda. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case error(Error)
}
