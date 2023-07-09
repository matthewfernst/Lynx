//
//  MergeAccountsViewController.swift
//  Lynx
//
//  Created by Matthew Ernst on 7/4/23.
//


import UIKit
import AuthenticationServices
import GoogleSignIn
import OSLog

class MergeAccountsViewController: UIViewController {
    
    private let explanationTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = """
        If you have signed in with multiple methods, such as Google and Apple, you can merge these accounts together to consolidate your information and access all your data from a single account. This allows you to have a unified experience and avoid maintaining separate accounts.
        
        To merge your accounts, sign in below with the account you are currently NOT logged into and want to merge with.
        
        Please note that merging accounts is irreversible. Once accounts are merged, the associated data and login methods will be consolidated, and you will no longer be able to separate them.
        
        If you need further assistance or have any questions, please reach out to our support team.
        """
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = .label
        textView.textAlignment = .center
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isSelectable = false
        return textView
    }()
    
    private var loginController: LoginController!
    
    private var signInWithGoogleButton: UIButton?
    private var appleSignInButton: ASAuthorizationAppleIDButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Merge Accounts"
        view.backgroundColor = .systemBackground
        loginController = LoginController(loginControllerCaller: self)
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.addSubview(explanationTextView)
        ApolloLynxClient.clearCache()
        ApolloLynxClient.getOAuthLoginTypes { [weak self] result in
            guard case let .success(oauthLoginTypes) = result else {
                // Handle the failure case
                return
            }
            
            switch (oauthLoginTypes.contains(ApolloGeneratedGraphQL.LoginType.apple.rawValue),
                    oauthLoginTypes.contains(ApolloGeneratedGraphQL.LoginType.google.rawValue)) {
                
            case (true, true):
                self?.explanationTextView.text = "You have already connected your Apple and Google accounts. There are no more accounts to merge."
                
            case (false, true):
                self?.addAppleSignInButton()
                
            case (true, false):
                self?.addSignInWithGoogleButton()
                
            default:
                break
            }
            
        }
    }
    
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            explanationTextView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
            explanationTextView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            explanationTextView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            explanationTextView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -40)
        ])
    }
    
    private func addSignInWithGoogleButton() {
        signInWithGoogleButton?.removeFromSuperview()
        let style: UIColor = traitCollection.userInterfaceStyle == .dark ? .white : .black
        signInWithGoogleButton = getSignInWithGoogleButton(baseBackgroundColor: style)
        signInWithGoogleButton?.translatesAutoresizingMaskIntoConstraints = false
        signInWithGoogleButton?.addTarget(self, action: #selector(googleSignInButtonTapped), for: .touchUpInside)
        guard let button = signInWithGoogleButton else { return }
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: appleSignInButton?.bottomAnchor ?? explanationTextView.bottomAnchor, constant: 20),
            button.widthAnchor.constraint(equalToConstant: 280),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func addAppleSignInButton() {
        appleSignInButton?.removeFromSuperview()
        let style: ASAuthorizationAppleIDButton.Style = traitCollection.userInterfaceStyle == .dark ? .white : .black
        appleSignInButton = ASAuthorizationAppleIDButton(type: .signIn, style: style)
        appleSignInButton?.translatesAutoresizingMaskIntoConstraints = false
        appleSignInButton?.addTarget(self, action: #selector(appleSignInButtonTapped), for: .touchUpInside)
        guard let button = appleSignInButton else { return }
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: explanationTextView.bottomAnchor, constant: 20),
            button.widthAnchor.constraint(equalToConstant: 280),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Update the button's appearance for light and dark mode
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            addAppleSignInButton()
            addSignInWithGoogleButton()
        }
    }
    
    @objc private func appleSignInButtonTapped() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.delegate = self
        controller.presentationContextProvider = self
        
        controller.performRequests()
    }
    
    @objc private func googleSignInButtonTapped() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] signInResult, error in
            guard error == nil else {
                showErrorWithSignIn()
                return
            }
            guard let googleId = signInResult?.user.userID else {
                showErrorWithSignIn()
                return
            }
            
            guard let token = signInResult?.user.idToken?.tokenString else {
                showErrorWithSignIn()
                return
            }
            
            let graphQLWrappedToken = GraphQLNullable<ApolloGeneratedGraphQL.ID>(stringLiteral: token)
            let account: ApolloGeneratedGraphQL.LoginTypeCorrelationInput = .init(type:GraphQLEnum<ApolloGeneratedGraphQL.LoginType>(rawValue: "GOOGLE"), id: googleId, token: graphQLWrappedToken)
            
            ApolloLynxClient.mergeAccount(with: account) { result in
                switch result {
                case .success(_):
                    self.showSuccessfullyMerged()
                    
                case .failure(_):
                    self.showFailedToMerge()
                }
            }
        }
    }
    
    private func showErrorWithSignIn() {
        let ac = UIAlertController(title: "Failed to Sign in", message: "We were unable to sign you in. Please try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(ac, animated: true)
    }
    
    private func showFailedToMerge() {
        let ac = UIAlertController(title: "Failed to Merge Accounts", message: "We were unable to merge your account. Please try again", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(ac, animated: true)
    }
    
    private func showSuccessfullyMerged() {
        let ac = UIAlertController(title: "Successfully Merged Accounts", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel) {_ in
            guard let accountSettingsViewController = self.navigationController?.viewControllers[0] as? AccountViewController else {
                return
            }
            self.navigationController?.popToViewController(accountSettingsViewController, animated: true)
        })
        present(ac, animated: true)
    }
    
}


extension MergeAccountsViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            Logger.mergeAccountsViewController.debug("Sign in with Apple: Credential Sign in")
            guard let appleJWT = String(data:appleIdCredential.identityToken!, encoding: .utf8) else {
                Logger.mergeAccountsViewController.error("Apple JWT was not returned.")
                return
            }
            
            let graphQLWrappedToken = GraphQLNullable<ApolloGeneratedGraphQL.ID>(stringLiteral: appleJWT)
            let account: ApolloGeneratedGraphQL.LoginTypeCorrelationInput = .init(type:GraphQLEnum<ApolloGeneratedGraphQL.LoginType>(rawValue: "APPLE"), id: appleIdCredential.user, token: graphQLWrappedToken)
            
            ApolloLynxClient.mergeAccount(with: account) { result in
                switch result {
                case .success(_):
                    self.showSuccessfullyMerged()
                    
                case .failure(_):
                    self.showFailedToMerge()
                }
            }
            
        default:
            Logger.mergeAccountsViewController.error("AppleCredential did not return.")
            self.showErrorWithSignIn()
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Logger.mergeAccountsViewController.debug("Error with login for Sign in with Apple -> \(error)")
        guard let error = error as? ASAuthorizationError else {
            return
        }
        
        let baseErrorAreaMessage = "Error in Sign in with Apple:"
        
        switch error.code {
        case .canceled:
            Logger.mergeAccountsViewController.debug("\(baseErrorAreaMessage) Login request was canceled")
        case .unknown:
            Logger.mergeAccountsViewController.debug("\(baseErrorAreaMessage) User didn't login their Apple ID on device.")
        case .invalidResponse:
            Logger.mergeAccountsViewController.debug("\(baseErrorAreaMessage) Invalid response for login.")
        case .notHandled:
            Logger.mergeAccountsViewController.debug("\(baseErrorAreaMessage) Request not handled.")
        case .failed:
            Logger.mergeAccountsViewController.debug("\(baseErrorAreaMessage) Authorization failed.")
        case .notInteractive:
            Logger.mergeAccountsViewController.debug("\(baseErrorAreaMessage) Authorization request is not interactive.")
        @unknown default:
            Logger.mergeAccountsViewController.debug("\(baseErrorAreaMessage) Unknown error.")
        }
        
        self.showErrorWithSignIn()
    }
}

extension MergeAccountsViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

