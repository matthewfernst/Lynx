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
    @IBOutlet var invisibleViewForCenteringSignInButtons: UIView!
    
    static let identitfier = "LoginViewController"
    
    private lazy var loginController = LoginController(loginViewController: self)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.signInExistingUser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .signBackgroundLavendar
        self.appLabel.clipsToBounds = true
        self.appLabel.layer.borderColor = UIColor.black.cgColor
        
        setupLearnMoreButton()
        
        setupSignInWithAppleButton()
        setupSignInWithGoogleButton()
    }
    
    @objc private func showMountainUIDisplayPage() {
        if let url = URL(string: Constants.mountainUIDisplayGitub) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: DEBUG login for working on other parts of the app and bypassing login
    private func debugLogin() {
#if DEBUG
        Logger.loginViewController.debug("DEBUG MODE!")
        LoginController.profile = Profile.sampleProfile
        self.goToMainApp()
#endif
    }
    
    private func setupLearnMoreButton() {
        let learnMoreButtonTitle = NSMutableAttributedString(string: "What is Mountain UI? Learn More")
        learnMoreButtonTitle.addAttributes([.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 11)], range: NSRange(location: 0, length: 20))
        learnMoreButtonTitle.addAttributes([.foregroundColor: UIColor.link, .font: UIFont.systemFont(ofSize: 11)], range: NSRange(location: 21, length: 10))

        self.learnMoreButton.setAttributedTitle(learnMoreButtonTitle, for: .normal)
        self.learnMoreButton.addTarget(self, action: #selector(showMountainUIDisplayPage), for: .touchUpInside)
    }
    
    // MARK: Apple Sign In
    private func setupSignInWithAppleButton() {
        let signInWithAppleButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .white)
        signInWithAppleButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.view.addSubview(signInWithAppleButton)
        
        signInWithAppleButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signInWithAppleButton.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor),
            signInWithAppleButton.bottomAnchor.constraint(equalTo: self.invisibleViewForCenteringSignInButtons.centerYAnchor, constant: -5),
            signInWithAppleButton.widthAnchor.constraint(equalToConstant: self.invisibleViewForCenteringSignInButtons.frame.width / 1.25),
            signInWithAppleButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func handleAuthorizationAppleIDButtonPress() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.delegate = self
        controller.presentationContextProvider = self
        
        controller.performRequests()
    }
    
    // MARK: Google Sign In
    private func setupSignInWithGoogleButton() {
        let signInWithGoogleButton = getSignInWithGoogleButton()
        
        signInWithGoogleButton.addTarget(self, action: #selector(handleAuthorizationGoogleButtonPress), for: .touchUpInside)
        self.view.addSubview(signInWithGoogleButton)
        
        signInWithGoogleButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signInWithGoogleButton.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor),
            signInWithGoogleButton.topAnchor.constraint(equalTo: self.invisibleViewForCenteringSignInButtons.centerYAnchor, constant: 5),
            signInWithGoogleButton.widthAnchor.constraint(equalToConstant: self.invisibleViewForCenteringSignInButtons.frame.width / 1.25),
            signInWithGoogleButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func handleAuthorizationGoogleButtonPress() {
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
                let activityIndicator = self.showSignInActivityIndicator()
                await LoginController.handleCommonSignIn(uuid: uuid,
                                                         firstName: firstName,
                                                         lastName: lastName,
                                                         email: profile.email,
                                                         profilePictureURL: profile.imageURL(withDimension: 320)?.absoluteString ?? "")
                activityIndicator.stopAnimating()
                self.updateViewFromModel()
            }
        }
    }
    
    private func updateViewFromModel() {
        guard let _ = LoginController.profile else {
            showErrorWithSignIn()
            return
        }
        
        self.goToMainApp()
    }
    
    private func goToMainApp() {
        
        if let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: TabViewController.identifier) as? TabViewController {
            tabBarController.profile = LoginController.profile
            tabBarController.modalTransitionStyle = .flipHorizontal
            tabBarController.modalPresentationStyle = .fullScreen
            
            self.present(tabBarController, animated: true)
        }
        
    }
    
    private func showErrorWithSignIn() {
        let message = """
                      It looks like we weren't able to log you in. Please try again. If the issue continues, please contact the developers.
                      """
        let ac = UIAlertController(title: "Well, This is Awkward...", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(ac, animated: true)
    }
    
    private func showSignInActivityIndicator() -> UIActivityIndicatorView {
        let background = UIView(frame: self.view.frame)
        background.backgroundColor = .black.withAlphaComponent(0.5)
        
        self.view.addSubview(background)
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.color = .white
        activityIndicator.transform = CGAffineTransformMakeScale(2, 2)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        background.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
        activityIndicator.startAnimating()
        
        return activityIndicator
    }
    
    private func signInExistingUser() {
        self.debugLogin()
//        let isSignedIn = UserDefaults.standard.bool(forKey: Profile.isSignedInKey)
//        
//        if isSignedIn {
//            let activityIndicator = showSignInActivityIndicator()
//            Task {
//                await Profile.loadProfileFromKeychain { [unowned self] profile in
//                    activityIndicator.stopAnimating()
//                    
//                    self.goToMainApp()
//                }
//            }
//        }
    }
}


extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            Logger.loginViewController.debug("Sign in with Apple: Credential Sign in")
            Task {
                let activityIndicator = self.showSignInActivityIndicator()
                await LoginController.handleCommonSignIn(uuid: appleIdCredential.user,
                                                         firstName: appleIdCredential.fullName?.givenName,
                                                         lastName: appleIdCredential.fullName?.familyName,
                                                         email: appleIdCredential.email)
                activityIndicator.stopAnimating()
                self.updateViewFromModel()
            }
            
        default:
            showErrorWithSignIn()
            Swift.debugPrint("Not ready yet")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Logger.loginViewController.debug("Error with login for Sign in with Apple -> \(error)")
        guard let error = error as? ASAuthorizationError else {
            return
        }
        
        let baseErrorAreaMessage = "Error in Sign in with Apple:"
        
        switch error.code {
        case .canceled:
            Logger.loginViewController.debug("\(baseErrorAreaMessage) Login request was canceled")
        case .unknown:
            Logger.loginViewController.debug("\(baseErrorAreaMessage) User didn't login their Apple ID on device.")
        case .invalidResponse:
            Logger.loginViewController.debug("\(baseErrorAreaMessage) Invalid response for login.")
        case .notHandled:
            Logger.loginViewController.debug("\(baseErrorAreaMessage) Request not handled.")
        case .failed:
            Logger.loginViewController.debug("\(baseErrorAreaMessage) Authorization failed.")
        case .notInteractive:
            Logger.loginViewController.debug("\(baseErrorAreaMessage) Authorization request is not interactive.")
        @unknown default:
            Logger.loginViewController.debug("\(baseErrorAreaMessage) Unknown error.")
        }
        
        showErrorWithSignIn()
    }
    
    
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
