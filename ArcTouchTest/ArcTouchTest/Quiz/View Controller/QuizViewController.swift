//
//  QuizViewController.swift
//  ArcTouchTest
//
//  Created by Rafael  Hieda on 2/9/20.
//  Copyright © 2020 Rafael_Hieda. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController {

    @IBOutlet weak var gameControl: GameControl!
    @IBOutlet weak var tableView: UITableView!
    var viewModel: QuizViewModel!
    var focusDelegate: SetFocusDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCell()
        setupDelegates()
        viewModel = QuizViewModel(uiDelegate: self)
        viewModel.fetchGameData()
        registerNotificationForKeyboardChanges()
        
    }
    
    func registerCell() {
        tableView.register(UINib(nibName: "TitleTableViewCell", bundle: .main), forCellReuseIdentifier: "TitleTableViewCell")
        tableView.register(UINib(nibName: "SearchTableViewCell", bundle: .main), forCellReuseIdentifier: "SearchTableViewCell")
        tableView.register(UINib(nibName: "CorrectAnswersTableViewCell", bundle: .main), forCellReuseIdentifier: "CorrectAnswersTableViewCell")
    }
    
    func setupDelegates() {
        tableView.dataSource = self
        tableView.delegate = self
        gameControl.delegate = self
    }
    
    func registerNotificationForKeyboardChanges() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                let bottomHeightConstant = keyboardSize.height
                gameControl.frame.origin.y -= bottomHeightConstant
            }
        }
        
    }
    
    deinit {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: UIApplication.keyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIApplication.keyboardWillHideNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIApplication.keyboardWillChangeFrameNotification, object: nil)
    }
    
}

extension QuizViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 1 {
            return 1
        } else {
            if viewModel.gameManager == nil {
                return 0
            } else {
                return viewModel.totalOfCorrectAnswers()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleTableViewCell") as! TitleTableViewCell
            cell.questionLabel.text = viewModel.gameManager == nil ? "" : viewModel.gameManager.gameQuestion
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell") as! SearchTableViewCell
            cell.delegate = self
            focusDelegate = cell
                return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CorrectAnswersTableViewCell") as! CorrectAnswersTableViewCell
            cell.answerLabel.text = viewModel.gameManager.correctAnswers[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension QuizViewController: QuizUIDelegate {
    func updateScore(with updatedScore: Int) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.gameControl.gameStats.currentScoreLabel.text = "\(updatedScore)/\(self.viewModel.gameManager.totalOfAnswers)"
            self.focusDelegate.requestFocusOnTextField()
        }
    }
    
    func updateTime(with labeledTime: String) {
        DispatchQueue.main.async {
            self.gameControl.gameStats.timeLeftLabel.text = labeledTime
        }
        
    }
    
    func finishGame(with gameState: GameScore) {
        switch gameState {
        case .win:
            let alertController = AlertControllerBuilder()
                .getAlertController(title: "Congratulations", message: "Good job, You found all the answers on time. Keep up with the great work", style: .alert)
                .includeAlertAction(title: "Play again", style: .default, completionHandler: nil)
                .build()
            self.present(alertController, animated: true, completion: {
                self.gameControl.resetUI()
                self.viewModel.resetGame()
            })
        case .loss(let score):
            let alertController = AlertControllerBuilder()
                .getAlertController(title: "Time finished", message: "Sorry this is time up! You got \(score) out of \(viewModel.totalOfAnswers())", style: .alert)
                .includeAlertAction(title: "Play again", style: .default, completionHandler: nil)
                .build()
            self.present(alertController, animated: true, completion: {
                self.gameControl.resetUI()
                self.viewModel.resetGame()
            })
        }
    }
    
    func displayGameDataError(with stringError: String) {
        let alertController = AlertControllerBuilder()
            .getAlertController(title: "Error", message: stringError, style: .alert)
            .includeAlertAction(title: "Ok, got it.", style: .default, completionHandler: nil)
            .build()
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}

extension QuizViewController: RequestSearchKeywordDelegate {
    func requestSearch(with word: String) {
        if viewModel.gameState == .started {
            viewModel.submitWord(with: word)
        }
    }
}

extension QuizViewController: GameControlDelegate {
    func didClickButton(_ sender: Any) {
        if viewModel.gameState == .started {
            viewModel.resetGame()
            gameControl.resetUI()
        } else {
            //should start
            viewModel.startGame()
            gameControl.updateButtonLabel(with: "Reset")
        }
    }
}

final class AlertControllerBuilder {
    private var alertController: UIAlertController!
    init(){}
    func getAlertController(title: String, message: String, style: UIAlertController.Style) -> Self {
        self.alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        return self
    }
    func includeAlertAction(title: String, style: UIAlertAction.Style, completionHandler: ((UIAlertAction) -> Void)?) -> Self {
        let alertAction = UIAlertAction(title: title, style: style, handler: completionHandler)
        guard let alertController = self.alertController else { return self }
        alertController.addAction(alertAction)
        return self
    }
    
    func build() -> UIAlertController {
        return alertController
    }
}
