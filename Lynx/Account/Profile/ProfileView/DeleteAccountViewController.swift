//
//  DeleteAccountViewController.swift
//  Lynx
//
//  Created by Matthew Ernst on 7/4/23.
//

import UIKit

class DeleteAccountViewController: UIViewController {
    
    public let explanationTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = """
                    This will permanently delete all of your data that you have uploaded for Mountain-UI and any account information we have with you. This includes your profile information, uploaded files, and any associated data.
                    
                    Please note that this action cannot be undone or recovered. It is recommended to download any important data before proceeding with the account deletion.
                    
                    Are you sure you want to proceed with deleting your account? This action cannot be undone.
                    """
        
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = .label
        textView.textAlignment = .center
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isSelectable = false
        return textView
    }()
    
    private let confirmDeletionOfAccountButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Confirm Deletion of My Account", for: .normal)
        button.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        button.tintColor = .systemRed
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Delete My Account"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.view.backgroundColor = .systemBackground
        
        self.view.addSubview(explanationTextView)
        self.view.addSubview(confirmDeletionOfAccountButton)
        
        confirmDeletionOfAccountButton.addTarget(self, action: #selector(deleteAccount), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            explanationTextView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 20),
            explanationTextView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
            explanationTextView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
            explanationTextView.bottomAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -40),
            
            confirmDeletionOfAccountButton.topAnchor.constraint(equalTo: explanationTextView.bottomAnchor),
            confirmDeletionOfAccountButton.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
            confirmDeletionOfAccountButton.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
            
        ])
        
    }
    
    @objc private func deleteAccount() {
        confirmDeletionOfAccountButton.isUserInteractionEnabled = false
        confirmDeletionOfAccountButton.addSubview(activityIndicator)
        confirmDeletionOfAccountButton.titleLabel?.isHidden = true
        confirmDeletionOfAccountButton.imageView?.isHidden = true
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: confirmDeletionOfAccountButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: confirmDeletionOfAccountButton.centerYAnchor)
        ])
        
        activityIndicator.startAnimating()
        
        ApolloMountainUIClient.deleteAccount() { result in
            switch result {
            case .success(_):
                let ac = UIAlertController(title: "Successfully Deleted Account", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel) { [weak self] _ in
                    self?.resetConfirmDeletionButton()
                    LoginController.signOut()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)

                    if let vc = storyboard.instantiateInitialViewController() as? LoginViewController {
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
                    }
                })
                self.present(ac, animated: true)

            case .failure(_):
                let ac = UIAlertController(title: "Failed to Delete Account", message: "Our systems were not able to delete your account. Please try again. If the error persists, please contact the developers.", preferredStyle: .alert)

                ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel) {[weak self] _ in
                    self?.resetConfirmDeletionButton()
                })

                self.present(ac, animated: true)
            }
        }
    }
    
    func resetConfirmDeletionButton() {
        self.activityIndicator.stopAnimating()
        confirmDeletionOfAccountButton.titleLabel?.isHidden = false
        confirmDeletionOfAccountButton.imageView?.isHidden = false
        self.confirmDeletionOfAccountButton.isUserInteractionEnabled = true
    }
    
}
