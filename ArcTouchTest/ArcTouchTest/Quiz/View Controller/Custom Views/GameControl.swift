//
//  GameControl.swift
//  ArcTouchTest
//
//  Created by Rafael  Hieda on 2/9/20.
//  Copyright © 2020 Rafael_Hieda. All rights reserved.
//

import UIKit

protocol GameControlDelegate {
    func didClickButton(_ sender: Any)
}

class GameControl: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var gameStats: GameStatsView!
    @IBOutlet weak var gameButton: UIButton!
    var delegate: GameControlDelegate!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.customInit()
    }

    //  init used if the view is created through IB
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.customInit()
    }

    //  Do custom initialization here
    private func customInit()
    {
        self.isUserInteractionEnabled = true
        let bundle = Bundle(for: GameControl.self)
        bundle.loadNibNamed("GameControl", owner: self, options: nil)
        self.addSubview(self.contentView)
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.contentView.isUserInteractionEnabled = true
        
        gameButton.layer.cornerRadius = 10
        self.gameButton.layer.masksToBounds = true
        
    }
        
    @IBAction func didClickGameButton(_ sender: Any) {
        delegate.didClickButton(sender)
    }
    
    func resetUI() {
        gameStats.currentScoreLabel.text = "00/50"
        gameStats.timeLeftLabel.text = "05:00"

        updateButtonLabel(with: "Start")
    }
    
    func updateButtonLabel(with message: String) {
        gameButton.setTitle(message, for: .normal)
    }
    
}
