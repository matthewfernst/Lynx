//
//  InvitationKeySheetViewController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 6/24/23.
//

import Foundation
import UIKit
import OSLog

class InvitationKeySheetViewController: UIViewController {
    
    init(completion: @escaping () -> Void) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public let completion: (()-> Void)
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Enter Your Invitation Key"
        label.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private let appIconImageView: UIImageView = {
        let image = UIImage(named: "AppIcon")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.clear.cgColor
        return imageView
    }()
    
    private let explainationLabelView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = """
                     Mountain-UI-Companion App only supports select users. An invitation key is needed to create an account.
                     Please enter your key below.
                     """
        label.textAlignment = .center
        label.numberOfLines = 6
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    private let invitationKeyTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter Key"
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.spellCheckingType = .no
        textField.enablesReturnKeyAutomatically = true
        textField.autocapitalizationType = .allCharacters
        textField.autocorrectionType = .no
        return textField
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Submit"
        configuration.baseForegroundColor = .white
        configuration.baseBackgroundColor = .systemBlue
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        
        button.configuration = configuration
        
        return button
    }()
    
    
    @objc private func submitButtonTapped() {
        startLoadingAnimation()
        guard let invitationKey = self.invitationKeyTextField.text else {
            showInvitationKeyIsInvalidAlert()
            return
        }
        self.invitationKeyTextField.text = ""
        ApolloMountainUIClient.submitInviteKey(with: invitationKey) { [unowned self] result in
            switch result {
            case .success(_):
                Logger.invitationKeySheet.debug("Successfully validated invite key.")
                self.dismiss(animated: true, completion: nil)
                self.completion()
            case .failure(let error):
                Logger.invitationKeySheet.error("Error: \(error)")
                showInvitationKeyIsInvalidAlert()
            }
            stopLoadingAnimation()
        }
    }
    
    private let loadingBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        
        activityIndicator.color = .white
        activityIndicator.transform = CGAffineTransformMakeScale(2, 2)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return activityIndicator
    }()
    
    private func startLoadingAnimation() {
        loadingBackground.isHidden = false
        activityIndicator.isHidden = false
        
        activityIndicator.startAnimating()
    }
    
    private func stopLoadingAnimation() {
        activityIndicator.stopAnimating()
        
        activityIndicator.removeFromSuperview()
        loadingBackground.removeFromSuperview()
    }
    
    private func showInvitationKeyIsInvalidAlert() {
        let ac = UIAlertController(title: "Invalid Key",
                                   message: "The key entered is not recongized in our system. Please try again.",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        self.present(ac, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSheet()
    }
    
    
    private func setupSheet() {
        self.view.backgroundColor = UIColor.systemBackground
        self.view.layer.cornerRadius = 12
        self.view.layer.masksToBounds = true
        self.isModalInPresentation = true
        setupSheetCompenets()
    }
    
    private func setupSheetCompenets() {
        self.view.addSubview(titleLabel)
        self.view.addSubview(appIconImageView)
        self.view.addSubview(explainationLabelView)
        self.view.addSubview(invitationKeyTextField)
        self.view.addSubview(submitButton)
        
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        invitationKeyTextField.delegate = self
        loadingBackground.frame = self.view.frame
        
        self.view.addSubview(loadingBackground)
        self.view.addSubview(activityIndicator)
        
        loadingBackground.isHidden = true
        activityIndicator.isHidden = true
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 50),
            
            appIconImageView.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor),
            appIconImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            appIconImageView.heightAnchor.constraint(equalToConstant: 100),
            appIconImageView.widthAnchor.constraint(equalToConstant: 100),
            
            explainationLabelView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 20),
            explainationLabelView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor, constant: -20),
            explainationLabelView.heightAnchor.constraint(equalToConstant: 150),
            explainationLabelView.topAnchor.constraint(equalTo: appIconImageView.bottomAnchor, constant: 20),
            
            
            invitationKeyTextField.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor),
            invitationKeyTextField.topAnchor.constraint(equalTo: explainationLabelView.bottomAnchor, constant: 20),
            invitationKeyTextField.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 20),
            invitationKeyTextField.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor, constant: -20),
            
            submitButton.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor),
            submitButton.topAnchor.constraint(equalTo: invitationKeyTextField.bottomAnchor, constant: 20),
            submitButton.heightAnchor.constraint(equalToConstant: 44),
            submitButton.widthAnchor.constraint(equalToConstant: 100),
            
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
}


extension InvitationKeySheetViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == invitationKeyTextField {
            submitButtonTapped()
            return true
        }
        return false
    }
}