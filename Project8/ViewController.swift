//
//  ViewController.swift
//  Project8
//
//  Created by Macedo on 24/02/26.
//

import UIKit

class ViewController: UIViewController {
    private let answersLabel = UILabel()
    private let cluesLabel = UILabel()
    private let scoreLabel = UILabel()
    
    private let currentAnswer = UITextField()
    
    private let clearButton = UIButton(type: .system)
    private let submitButton = UIButton(type: .system)
    private var letterButtons = [UIButton]()
    private var activatedButtons = [UIButton]()
    
    private var solutions = [String]()
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    private var level = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        configureScoreLabel()
        configureCluesLabel()
        configureAnswersLabel()
        configureCurrentAnswerTextField()
        configureSubmitAndClearButtonsStackView()
        configureButtonsView()
        
        loadLevel()
    }
    
    func loadLevel() {
        var clueString = ""
        var solutionString = ""
        var letterBits = [String]()
        
        if let levelFileURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") {
            if let levelContents = try? String(contentsOf: levelFileURL, encoding: .utf8) {
                var lines = levelContents.components(separatedBy: "\n")
                lines.shuffle()
                
                for (index, line) in lines.enumerated() {
                    let parts = line.components(separatedBy: ": ")
                    let answer = parts.first!
                    let clue = parts.last!
                    
                    clueString += "\(index + 1). \(clue)\n"
                    
                    let solutionWord = answer.replacingOccurrences(of: "|", with: "")
                    solutionString += "\(solutionWord.count) letters\n"
                    solutions.append(solutionWord)
                    
                    let bits = answer.components(separatedBy: "|")
                    letterBits += bits
                }
            }
        }
        
        cluesLabel.text = clueString.trimmingCharacters(in: .newlines)
        answersLabel.text = solutionString.trimmingCharacters(in: .newlines)
        
        letterBits.shuffle()
        
        if letterBits.count == letterButtons.count {
            for i in 0..<letterButtons.count {
                letterButtons[i].setTitle(letterBits[i], for: .normal)
            }
        }
    }
    
    func configureScoreLabel() {
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score: 0"
        
        view.addSubview(scoreLabel)
        
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
    }
    
    func configureCluesLabel() {
        cluesLabel.translatesAutoresizingMaskIntoConstraints = false
        cluesLabel.font = .preferredFont(forTextStyle: .title2)
        cluesLabel.text = "Clues"
        cluesLabel.numberOfLines = 0
        
        view.addSubview(cluesLabel)
        
        NSLayoutConstraint.activate([
            cluesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            cluesLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 80),
            cluesLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -80)
        ])
        
        cluesLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
    }
    
    func configureAnswersLabel() {
        answersLabel.translatesAutoresizingMaskIntoConstraints = false
        answersLabel.font = .preferredFont(forTextStyle: .title2)
        answersLabel.text = "Answers"
        answersLabel.numberOfLines = 0
        answersLabel.textAlignment = .right
        
        view.addSubview(answersLabel)
        
        NSLayoutConstraint.activate([
            answersLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            answersLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -80),
            answersLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -80),
            answersLabel.heightAnchor.constraint(equalTo: cluesLabel.heightAnchor)
        ])
        
        answersLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
    }
    
    func configureCurrentAnswerTextField() {
        currentAnswer.translatesAutoresizingMaskIntoConstraints = false
        currentAnswer.placeholder = "Tap letters to guess"
        currentAnswer.textAlignment = .center
        currentAnswer.font = .preferredFont(forTextStyle: .largeTitle)
        currentAnswer.isUserInteractionEnabled = false
        
        view.addSubview(currentAnswer)
        
        NSLayoutConstraint.activate([
            currentAnswer.topAnchor.constraint(equalTo: cluesLabel.bottomAnchor, constant: 20),
            currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentAnswer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        ])
    }
    
    func configureSubmitAndClearButtonsStackView() {
        submitButton.setTitle("Submit", for: .normal)
        submitButton.titleLabel?.font = .preferredFont(forTextStyle: .title3)
        submitButton.addAction(UIAction { [weak self] action in
            guard let self = self,
                  let answerText = self.currentAnswer.text,
                  !answerText.isEmpty else {return}
            
            if let solutionPosition = self.solutions.firstIndex(of: answerText) {
                self.activatedButtons.removeAll()
                
                var splitAnswers = answersLabel.text?.components(separatedBy: "\n")
                splitAnswers?[solutionPosition] = answerText
                answersLabel.text = splitAnswers?.joined(separator: "\n")
                
                currentAnswer.text = ""
                score += solutions[solutionPosition].count
                
                if letterButtons.allSatisfy({ $0.isHidden }) {
                    showNextLevelAlert()
                }
            } else {
                score -= 1
                showWrongAnswerAlert()
            }
        }, for: .touchUpInside)
        
        clearButton.setTitle("Clear", for: .normal)
        clearButton.titleLabel?.font = .preferredFont(forTextStyle: .title3)
        clearButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }

            self.currentAnswer.text = ""
            self.activatedButtons.forEach { $0.isHidden = false }
            self.activatedButtons.removeAll()
        }, for: .touchUpInside)
        
        let buttonsStackView = UIStackView(arrangedSubviews: [submitButton, clearButton])
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 24
        buttonsStackView.distribution = .fillEqually
        
        view.addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            buttonsStackView.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor),
            buttonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 44),
            buttonsStackView.widthAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    func showNextLevelAlert() {
        let ac = UIAlertController(title: "Well done!", message: "Are you ready for the next level?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Let's go!", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.level += 1
            self.solutions.removeAll(keepingCapacity: true)
            self.loadLevel()
            self.letterButtons.forEach { $0.isHidden = false }
        })
        
        present(ac, animated: true)
    }
    
    func showWrongAnswerAlert() {
        let ac = UIAlertController(title: "Oops!", message: "That's not quite right. Try again!", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(ac, animated: true)
    }
    
    func configureButtonsView() {
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(buttonsView)
        
        NSLayoutConstraint.activate([
            buttonsView.widthAnchor.constraint(equalToConstant: 600),
            buttonsView.heightAnchor.constraint(equalToConstant: 320),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 20),
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
        ])
        
        let buttonWidth = 120
        let buttonHeight = 80
        
        for row in 0..<4 {
            for col in 0..<5 {
                let letterButton = UIButton(type: .system)
                letterButton.titleLabel?.font = .preferredFont(forTextStyle: .title1)
                letterButton.setTitle("WWW", for: .normal)
                letterButton.layer.borderWidth = 1
                letterButton.layer.borderColor = UIColor.systemGray3.cgColor
                letterButton.clipsToBounds = true
                letterButton.addAction(UIAction { [weak self] action in
                    guard let self = self,
                          let button = action.sender as? UIButton,
                          let title = button.currentTitle
                    else { return }
                    
                    self.currentAnswer.text = self.currentAnswer.text?.appending(title)
                    self.activatedButtons.append(action.sender as! UIButton)
                    button.isHidden = true
                }, for: .touchUpInside)
                
                let frame = CGRect(x: col * buttonWidth, y: row * buttonHeight, width: buttonWidth, height: buttonHeight)
                letterButton.frame = frame
                
                buttonsView.addSubview(letterButton)
                
                letterButtons.append(letterButton)
            }
        }
    }
}
