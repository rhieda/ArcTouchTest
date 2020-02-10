//
//  SearchTableViewCell.swift
//  ArcTouchTest
//
//  Created by Rafael  Hieda on 2/9/20.
//  Copyright © 2020 Rafael_Hieda. All rights reserved.
//

import UIKit

protocol RequestSearchKeywordDelegate {
    func requestSearch(with word: String)
}

protocol SetFocusDelegate {
    func requestFocusOnTextField()
}

class SearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var searchTextField: UITextField!
    var delegate: RequestSearchKeywordDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        guard let text = sender.text else { return }
        delegate.requestSearch(with: text)
    }
}

extension SearchTableViewCell: SetFocusDelegate {
    func requestFocusOnTextField() {
        searchTextField.text = ""
        searchTextField.becomeFirstResponder()
    }
    
    
}



