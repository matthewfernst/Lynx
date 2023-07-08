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
        label.text = "Invitation Key"
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private let explainationLabelView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = """
                     Lynx only supports select users. An invitation key is needed to create an account. Enter your key below.
                     """
        label.textAlignment = .center
        label.numberOfLines = 6
        return label
    }()
    
    
    private let invitationKeyInputView: InvitationKeyInputUIView = {
        let view = InvitationKeyInputUIView(frame: .init(x: 0, y: 0, width: 300, height: 44))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dontHaveAnInviteKeyButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Don't have an invite key?", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return button
    }()
    
    @objc private func dontHaveAnInviteKeyButtonPressed() {
        let ac = UIAlertController(title: "Need an Invitation Key?",
                                   message: """
                                            Invitation keys are required to create an account with Lynx. If you don't have an invitation key, you can request one from a friend who already has an account.
                                            """,
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        self.present(ac, animated: true)
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
                                   message: "The key entered is not recognized in our system. This could be because your invitation has expired. Please double-check the key and try again. If you believe there is an error, please contact our developers for assistance.",
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
        self.view.addSubview(invitationKeyInputView)
        self.view.addSubview(titleLabel)
        self.view.addSubview(explainationLabelView)
        self.view.addSubview(invitationKeyInputView)
        self.view.addSubview(dontHaveAnInviteKeyButton)
        
        invitationKeyInputView.didFinishEnteringKey = { [unowned self] key in
            startLoadingAnimation()
            ApolloMountainUIClient.submitInviteKey(with: key) { [unowned self] result in
                switch result {
                case .success(_):
                    Logger.invitationKeySheet.debug("Successfully validated invitation key.")
                    self.dismiss(animated: true, completion: nil)
                    self.completion()
                case .failure(let error):
                    invitationKeyInputView.key = ""
                    Logger.invitationKeySheet.error("Error: \(error)")
                    showInvitationKeyIsInvalidAlert()
                }
                stopLoadingAnimation()
            }
        }
        
        dontHaveAnInviteKeyButton.addTarget(self, action: #selector(dontHaveAnInviteKeyButtonPressed), for: .touchUpInside)
        
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
            titleLabel.heightAnchor.constraint(equalToConstant: 150),
            
            explainationLabelView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 20),
            explainationLabelView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor, constant: -20),
            explainationLabelView.heightAnchor.constraint(equalToConstant: 150),
            explainationLabelView.bottomAnchor.constraint(equalTo: invitationKeyInputView.topAnchor, constant: -20),
            
            invitationKeyInputView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            invitationKeyInputView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            invitationKeyInputView.widthAnchor.constraint(equalToConstant: 320),
            invitationKeyInputView.heightAnchor.constraint(equalToConstant: 44),
            
            dontHaveAnInviteKeyButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            dontHaveAnInviteKeyButton.topAnchor.constraint(equalTo: invitationKeyInputView.bottomAnchor, constant: 10),
            
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
    }
}
