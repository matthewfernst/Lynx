//
//  SignInViewController.swift
//  Lynx
//
//  Created by Matthew Ernst on 1/26/23.
//
import AuthenticationServices
import GoogleSignIn
import UIKit
import OSLog

class LoginViewController: UIViewController {
    @IBOutlet var loginWallpaper: UIImageView!
    @IBOutlet var appLabel: UILabel!
    @IBOutlet var invisibleViewForCenteringSignInButtons: UIView!
    
    static let identitfier = "LoginViewController"
    
    private lazy var loginController = LoginController(loginControllerCaller: self)
    private let activityIndicator = UIActivityIndicatorView()
    private lazy var loadingBackground = UIView(frame: self.view.frame)
    private var signInWithAppleButton: ASAuthorizationAppleIDButton!
    private var signInWithGoogleButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWallpaperAndInvisibleView()
        setupAppLabel()
        setupSignInWithAppleButton()
        setupSignInWithGoogleButton()
        
                
        signInExistingUser() { [weak self] in
            self?.animateLoginView()
        }
        
        if UIScreen.main.bounds.height <= 680 { // For tiny screens
            appLabel.transform = CGAffineTransform(translationX: 0, y: -80)
        }
    }
    
    // MARK: - Notifications
    private func registerLocal() {
        // request permission
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                Logger.loginViewController.debug("Notifications granted")
            } else {
                Logger.loginViewController.debug("User has defined notificaitons")
            }
        }
    }
    
    private func animateLoginView() {
        appLabel.alpha = 0
        signInWithAppleButton.alpha = 0
        signInWithGoogleButton.alpha = 0
        
        self.signInWithAppleButton.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        self.signInWithGoogleButton.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        
        UIView.animate(withDuration: 1.0, delay: 0.75, options: [.curveEaseIn], animations: {
            self.appLabel.alpha = 1
            self.appLabel.transform = .identity
        }, completion: {_ in
            UIView.animate(withDuration: 0.75, delay: 0.0, options: [.transitionCurlUp], animations: {
                self.signInWithAppleButton.alpha = 1
                self.signInWithAppleButton.transform = .identity
            }, completion: { _ in
                UIView.animate(withDuration: 0.75, delay: 0.0, options: [.transitionCurlUp], animations: {
                    self.signInWithGoogleButton.alpha = 1
                    self.signInWithGoogleButton.transform = .identity
                })
            })
        })
    }
    
    private func scheduleNotificationsForRemindingToUpload() {
        registerLocal()
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "It's been a minute"
        content.body = "Just a little reminder to come back and link your any new files."
        content.categoryIdentifier = "recall"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 2
        dateComponents.month = 1
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request)
    }
    
    @objc private func showMountainUIDisplayPage() {
        if let url = URL(string: Constants.mountainUIDisplayGitub) {
            UIApplication.shared.open(url)
        }
    }
    
    private func setupWallpaperAndInvisibleView() {
        loginWallpaper.translatesAutoresizingMaskIntoConstraints = false
        invisibleViewForCenteringSignInButtons.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginWallpaper.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginWallpaper.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loginWallpaper.topAnchor.constraint(equalTo: view.topAnchor),
            loginWallpaper.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            
            invisibleViewForCenteringSignInButtons.centerXAnchor.constraint(equalTo: appLabel.centerXAnchor),
            invisibleViewForCenteringSignInButtons.heightAnchor.constraint(equalToConstant: 100),
            invisibleViewForCenteringSignInButtons.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            invisibleViewForCenteringSignInButtons.topAnchor.constraint(equalTo: appLabel.bottomAnchor)
        ])
    }
    
    private func setupAppLabel() {
        appLabel.textColor = .white
        appLabel.clipsToBounds = true
        appLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            appLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: view.center.y / 3),
            appLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 40),
        ])
    }
    
    
    // MARK: Apple Sign In
    private func setupSignInWithAppleButton() {
        signInWithAppleButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .white)
        signInWithAppleButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.view.addSubview(signInWithAppleButton)
        
        signInWithAppleButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signInWithAppleButton.centerXAnchor.constraint(equalTo: appLabel.centerXAnchor),
            signInWithAppleButton.bottomAnchor.constraint(equalTo: invisibleViewForCenteringSignInButtons.centerYAnchor, constant: -5),
            signInWithAppleButton.widthAnchor.constraint(equalToConstant: invisibleViewForCenteringSignInButtons.frame.width / 1.75),
            signInWithAppleButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc public func handleAuthorizationAppleIDButtonPress() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.delegate = self
        controller.presentationContextProvider = self
        
        controller.performRequests()
    }
    
    // MARK: Google Sign In
    private func setupSignInWithGoogleButton() {
        signInWithGoogleButton = getSignInWithGoogleButton(baseBackgroundColor: .white)
        
        signInWithGoogleButton.addTarget(self, action: #selector(handleAuthorizationGoogleButtonPress), for: .touchUpInside)
        self.view.addSubview(signInWithGoogleButton)
        
        signInWithGoogleButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signInWithGoogleButton.centerXAnchor.constraint(equalTo: appLabel.centerXAnchor),
            signInWithGoogleButton.topAnchor.constraint(equalTo: invisibleViewForCenteringSignInButtons.centerYAnchor, constant: 5),
            signInWithGoogleButton.widthAnchor.constraint(equalToConstant: invisibleViewForCenteringSignInButtons.frame.width / 1.75),
            signInWithGoogleButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func handleAuthorizationGoogleButtonPress() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] signInResult, error in
            guard error == nil else {
                showErrorWithSignIn()
                return
            }
            guard let googleId = signInResult?.user.userID else {
                showErrorWithSignIn()
                return
            }
            guard let profile = signInResult?.user.profile else {
                showErrorWithSignIn()
                return
            }
            guard let token = signInResult?.user.idToken?.tokenString else {
                showErrorWithSignIn()
                return
            }
            
            
            let name = profile.name.components(separatedBy: " ")
            let (firstName, lastName) = (name[0], name[1])
            let email = profile.email
            let activityIndicator = self.showSignInActivityIndicator()
            
            loginController.handleCommonSignIn(type: SignInType.google.rawValue,
                                               id: googleId,
                                               token: token,
                                               email: email,
                                               firstName: firstName,
                                               lastName: lastName,
                                               profilePictureURL: profile.imageURL(withDimension: 320)?.absoluteString ?? "") { _ in
                activityIndicator.startAnimating()
                self.updateViewFromModel()
            }
        }
    }
    
    private func updateViewFromModel() {
        guard let _ = LoginController.profile else {
            showErrorWithSignIn()
            return
        }
        scheduleNotificationsForRemindingToUpload()
        self.goToMainApp()
    }
    
    public func goToMainApp() {
        if let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: TabViewController.identifier) as? TabViewController {
            
            let defaults = UserDefaults.standard
            if defaults.object(forKey: UserDefaultsKeys.notificationsTurnedOnOrOff) == nil {
                let center = UNUserNotificationCenter.current()
                center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                    defaults.set(granted, forKey: UserDefaultsKeys.notificationsTurnedOnOrOff)
                }
            }
            
            TabViewController.profile = LoginController.profile
            tabBarController.modalTransitionStyle = .flipHorizontal
            tabBarController.modalPresentationStyle = .fullScreen
            
            self.present(tabBarController, animated: true)
        }
    }
    
    private func showErrorWithSignIn() {
        self.activityIndicator.stopAnimating()
        self.loadingBackground.removeFromSuperview()
        let message = """
                      It looks like we weren't able to sign you in. Please try again. If the issue continues, please contact the developers.
                      """
        let ac = UIAlertController(title: "Failed to Sign in", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(ac, animated: true)
    }
    
    private func showSignInActivityIndicator() -> UIActivityIndicatorView {
        
        loadingBackground.backgroundColor = .black.withAlphaComponent(0.5)
        
        self.view.addSubview(loadingBackground)
        
        activityIndicator.color = .white
        activityIndicator.transform = CGAffineTransformMakeScale(2, 2)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        loadingBackground.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
        activityIndicator.startAnimating()
        
        return activityIndicator
    }
    
    private func signInExistingUser(completion: (() -> Void)? ) {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: UserDefaultsKeys.isSignedIn),
           let type = defaults.string(forKey: UserDefaultsKeys.loginType),
           let id = defaults.string(forKey: UserDefaultsKeys.appleOrGoogleId) {
            let activityIndicator = showSignInActivityIndicator()
            
            switch SignInType(rawValue: type) {
            case .apple:
                ASAuthorizationAppleIDProvider().getCredentialState(forUserID: id) { [weak self] credentialState, error in
                    switch(credentialState) {
                    case .authorized:
                        self?.loginController.loginUser { _ in
                            self?.updateViewFromModel()
                        }
                    default:
                        self?.performExistingAppleAccountSetupFlows()
                    }
                }
                
            case .google:
                GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
                    if error != nil || user == nil {
                        // Show the app's signed-out state.
                    } else {
                        // Show the app's signed-in state.
                        if let token = user?.idToken?.tokenString,
                           let googleId = user?.userID {
                            self?.loginController.handleCommonSignIn(type: SignInType.google.rawValue, id: googleId, token: token) { result in
                                activityIndicator.startAnimating()
                                self?.updateViewFromModel()
                            }
                        }
                    }
                }
            default:
                break
            }
        } else {
            completion?()
        }
    }
}


extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            Logger.loginViewController.debug("Sign in with Apple: Credential Sign in")
            guard let appleJWT = String(data:appleIdCredential.identityToken!, encoding: .utf8) else {
                Logger.loginViewController.error("Apple JWT was not returned.")
                return
            }
            
            let activityIndicator = self.showSignInActivityIndicator()
            loginController.handleCommonSignIn(type: SignInType.apple.rawValue,
                                               id: appleIdCredential.user,
                                               token: appleJWT,
                                               email: appleIdCredential.email,
                                               firstName: appleIdCredential.fullName?.givenName,
                                               lastName: appleIdCredential.fullName?.familyName) { _ -> Void in
                activityIndicator.stopAnimating()
                self.updateViewFromModel()
            }
            
        default:
            Logger.loginViewController.error("AppleCredential did not return.")
            self.showErrorWithSignIn()
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
        
        self.showErrorWithSignIn()
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension LoginViewController {
    func performExistingAppleAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest()]
        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}
