//
//  DeleteAccountViewController.swift
//  Mountain-UI-Companion
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
        button.tintColor = .systemRed
        button.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        return button
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
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.color = .white
        activityIndicator.color = .white
        activityIndicator.transform = CGAffineTransformMakeScale(2, 2)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let loadingBackground = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        loadingBackground.backgroundColor = .black.withAlphaComponent(0.5)
        
        loadingBackground.addSubview(activityIndicator)
        
        self.view.addSubview(loadingBackground)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
        activityIndicator.startAnimating()
        
        ApolloMountainUIClient.deleteAccount() { result in
            activityIndicator.stopAnimating()
            loadingBackground.removeFromSuperview()
            
            switch result {
            case .success(_):
                let ac = UIAlertController(title: "Successfully Deleted Account", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel) { _ in
                    LoginController.signOut()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    
                    if let vc = storyboard.instantiateInitialViewController() as? LoginViewController {
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
                    }
                })
                self.present(ac, animated: true)

            case .failure(_):
                let ac = UIAlertController(title: "Failed to Delete Account", message: "Our systems were not able to delete your account. Please try again. If the error persists, please contact the developers.", preferredStyle: .alert)
                
                ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                
                self.present(ac, animated: true)
            }
        }
    }
    
}
