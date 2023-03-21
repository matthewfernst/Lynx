//
//  SignInViewController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/26/23.
//
import AuthenticationServices
import AWSClientRuntime
import AWSDynamoDB
import ClientRuntime
import GoogleSignIn
import UIKit
import OSLog

class LoginViewController: UIViewController
{
    @IBOutlet var appLabel: UILabel!
    @IBOutlet var learnMoreButton: UIButton!
    
    lazy var loginController = LoginController(loginViewController: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .signBackgroundLavendar
        self.appLabel.clipsToBounds = true
        self.appLabel.layer.borderColor = UIColor.black.cgColor
        self.learnMoreButton.addTarget(self, action: #selector(showMountainUIDisplayPage), for: .touchUpInside)
        
        setupSignInWithAppleButton()
        setupSignInWithGoogleButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        performExistingAccountSetupFlows()
    }
    
    @objc func showMountainUIDisplayPage() {
        if let url = URL(string: Constants.mountainUIDisplayGitub) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: DEBUG login for working on other parts of the app and bypassing login
    private func debugLogin() {
        #if DEBUG
        print("DEBUG MODE!")
        loginController.profile = Profile.sampleProfile
        self.goToMainApp()
        #endif
    }
    
    // MARK: Apple Sign In
    func setupSignInWithAppleButton() {
        let signInWithAppleButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .white)
        signInWithAppleButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.view.addSubview(signInWithAppleButton)
        
        signInWithAppleButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signInWithAppleButton.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor),
            signInWithAppleButton.centerYAnchor.constraint(equalTo: self.appLabel.bottomAnchor, constant: 50),
            signInWithAppleButton.widthAnchor.constraint(equalToConstant: 250),
            signInWithAppleButton.heightAnchor.constraint(equalToConstant: 37)
        ])
    }
    
    @objc func handleAuthorizationAppleIDButtonPress() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.delegate = self
        controller.presentationContextProvider = self
        
        controller.performRequests()
    }
    
    func performExistingAccountSetupFlows() {
        // Prepare the request for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        // Need to store password for this to work
                        // https://developer.apple.com/forums/thread/131624
                        ASAuthorizationPasswordProvider().createRequest()
        ]
        
        // Create an authorization controller with given requests.
        let controller = ASAuthorizationController(authorizationRequests: requests)
        
        controller.delegate = self
        controller.presentationContextProvider = self
        
        controller.performRequests()
    }
    
    // MARK: Google Sign In
    func setupSignInWithGoogleButton() {
        let signInWithGoogleButton = getSignInWithGoogleButton()
        
        signInWithGoogleButton.addTarget(self, action: #selector(handleAuthorizationGoogleButtonPress), for: .touchUpInside)
        self.view.addSubview(signInWithGoogleButton)
        
        signInWithGoogleButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signInWithGoogleButton.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor),
            signInWithGoogleButton.centerYAnchor.constraint(equalTo: self.appLabel.bottomAnchor, constant: 95),
            signInWithGoogleButton.widthAnchor.constraint(equalToConstant: 250),
            signInWithGoogleButton.heightAnchor.constraint(equalToConstant: 37)
        ])
    }
    
    @objc func handleAuthorizationGoogleButtonPress() {
        debugLogin()
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] signInResult, error in
            guard error == nil else {
                showErrorWithSignIn()
                return
            }
            guard let uuid = signInResult?.user.userID else {
                showErrorWithSignIn()
                return
            }
            guard let profile = signInResult?.user.profile else {
                showErrorWithSignIn()
                return
            }
            
            Task {
                let name = profile.name.components(separatedBy: " ")
                let (firstName, lastName) = (name[0], name[1])
                await loginController.handleCommonSignIn(uuid: uuid,
                                                         firstName: firstName,
                                                         lastName: lastName,
                                                         email: profile.email,
                                                         profilePictureURL: profile.imageURL(withDimension: 320)?.absoluteString ?? "")
            
                self.updateViewFromModel()
            }
        }
    }
    
    func updateViewFromModel() {
        guard let _ = loginController.profile else {
            showErrorWithSignIn()
            return
        }
        
        self.goToMainApp()
    }
    
    func goToMainApp() {
        
        if let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "TabController") as? TabViewController {
            tabBarController.profile = loginController.profile
            tabBarController.modalTransitionStyle = .flipHorizontal
            tabBarController.modalPresentationStyle = .fullScreen
            
            self.present(tabBarController, animated: true)
        }
    
    }

    
    func showErrorWithSignIn() {
        let message = """
                      It looks like we weren't able to log you in. Please try again. If the issue continues, please contact the developers.
                      """
        let ac = UIAlertController(title: "Well, This is Awkward...", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(ac, animated: true)
    }
}


extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            Task {
                await loginController.handleCommonSignIn(uuid: appleIdCredential.user,
                                                         firstName: appleIdCredential.fullName?.givenName,
                                                         lastName: appleIdCredential.fullName?.familyName,
                                                         email: appleIdCredential.email)
                
                self.updateViewFromModel()
            }
            break
            
        // TODO: Needed for existing sign in
//        case let passwordCredential as ASPasswordCredential:
//            // Sign in using exisiting iCloud Keychain credential.
//            // For the purpose of this demo app, show alert
//            self.updateViewFromModel()
//            break
        default:
            showErrorWithSignIn()
            Swift.debugPrint("Not ready yet")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error
        print(error.localizedDescription)
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
