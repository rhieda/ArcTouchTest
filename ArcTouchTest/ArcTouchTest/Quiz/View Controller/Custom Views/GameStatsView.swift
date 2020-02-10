//
//  GameStatsView.swift
//  ArcTouchTest
//
//  Created by Rafael  Hieda on 2/9/20.
//  Copyright © 2020 Rafael_Hieda. All rights reserved.
//

import Foundation
import UIKit

class GameStatsView: UIView {
    @IBOutlet weak var currentScoreLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializer()
    }
    
    func initializer() {
        let bundle = Bundle(for: GameStatsView.self)
        bundle.loadNibNamed("GameStatsView", owner: self, options: nil)
        self.addSubview(self.contentView)
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

    }
    
}
