//
//  InvitationKeyInputUIView.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 6/30/23.
//

import UIKit

class InvitationKeyInputUIView: UIView, UITextInputTraits {
    var keyboardType: UIKeyboardType = .numberPad
    
    var didFinishEnteringKey:((String)-> Void)?
    
    var key: String = "" {
        didSet {
            updateStack(by: key)
            if key.count == maxLength, let didFinishEnteringKey = didFinishEnteringKey {
                self.resignFirstResponder()
                didFinishEnteringKey(key)
            }
        }
    }
    var maxLength = 6
    
    //MARK: - UI
    let leftStack = UIStackView()
    let rightStack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        showKeyboardIfNeeded()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension InvitationKeyInputUIView {
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    private func showKeyboardIfNeeded() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showKeyboard))
        self.addGestureRecognizer(tapGesture)
    }
    @objc private func showKeyboard() {
        self.becomeFirstResponder()
    }
}


extension InvitationKeyInputUIView: UIKeyInput {
    var hasText: Bool {
        return key.count > 0
    }
    func insertText(_ text: String) {
        if key.count == maxLength {
            return
        }
        key.append(contentsOf: text)
    }
    
    func deleteBackward() {
        if hasText {
            key.removeLast()
        }
    }
}

extension InvitationKeyInputUIView {
    private func setupUI() {
        addSubview(leftStack)
        addSubview(rightStack)
        
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            leftStack.trailingAnchor.constraint(equalTo: self.centerXAnchor, constant: -10),
            leftStack.topAnchor.constraint(equalTo: self.topAnchor),
            leftStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            rightStack.leadingAnchor.constraint(equalTo: self.centerXAnchor, constant: 10),
            rightStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            rightStack.topAnchor.constraint(equalTo: self.topAnchor),
            rightStack.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        leftStack.axis = .horizontal
        leftStack.distribution = .fillEqually
        
        rightStack.axis = .horizontal
        rightStack.distribution = .fillEqually
        
        updateStack(by: key)
    }
    
    private func emptyDash() -> UIView {
        let dashes = InvitationKeyDashesUIView()
        dashes.dashes.backgroundColor = UIColor.label
        return dashes
    }
    
    private func dash() -> UIView {
        let dashes = InvitationKeyDashesUIView()
        dashes.dashes.backgroundColor = .green
        return dashes
    }
    
    private func updateStack(by key: String) {
        var emptyDashesLeft: [UIView] = Array(0..<maxLength/2).map { _ in emptyDash() }
        var emptyDashesRight: [UIView] = Array(0..<maxLength/2).map { _ in emptyDash() }
        
        let keyLabels: [UILabel] = Array(key).map { character in
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 30)
            label.text = String(character)
            return label
        }
        
        for (index, element) in keyLabels.enumerated() {
            if index < maxLength / 2 {
                emptyDashesLeft[index] = element
            } else {
                emptyDashesRight[index - maxLength / 2] = element
            }
        }
        
        leftStack.removeAllArrangedSubviews()
        for view in emptyDashesLeft {
            leftStack.addArrangedSubview(view)
        }
        
        rightStack.removeAllArrangedSubviews()
        for view in emptyDashesRight {
            rightStack.addArrangedSubview(view)
        }
    }
    
}

extension UIStackView {
    func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}
