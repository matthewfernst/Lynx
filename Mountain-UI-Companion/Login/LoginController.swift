//
//  LoginController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 3/14/23.
//

import Foundation
import OSLog

class LoginController {
    let loginViewController: LoginViewController
    static var profile: Profile?
    
    init(loginViewController: LoginViewController) {
        self.loginViewController = loginViewController
    }
    
    static func handleCommonSignIn(type: String, id: String, token: String, email: String? = nil, firstName: String? = nil, lastName: String? = nil, profilePictureURL: String = "", completion: @escaping (Result<Void, Error>) -> Void) {
        ApolloMountainUIClient.loginOrCreateUser(type: type,
                                                 id: id,
                                                 token: token,
                                                 email: email,
                                                 firstName: firstName,
                                                 lastName: lastName,
                                                 profilePictureUrl: profilePictureURL) { result in
            switch result {
            case .success:
                Logger.loginController.info("Authorization Token successfully recieved.")
                self.loginUser(completion: completion)
            case .failure:
                fatalError("Failed to retrieve Authorization Token.")
            }
        }
    }
    
    private static func loginUser(completion: @escaping (Result<Void, Error>) -> Void) {
        ApolloMountainUIClient.getProfileInformation() { result in
            switch result {
            case .success(let profileAttributes):
                self.signInUser(profileAttributes: profileAttributes, completion: completion)
            case .failure(let error):
                Logger.loginController.error("Failed to login user. \(error)")
                completion(.failure(error))
            }
        }
    }
    
    private static func signInUser(profileAttributes: ProfileAttributes, completion: @escaping (Result<Void, Error>) -> Void) {
        let group = DispatchGroup()
        var createdProfile: Profile?
        group.enter()
        
        UserDefaults.standard.setValue(profileAttributes.type, forKey: UserDefaultsKeys.loginType)
        Profile.createProfile(type: profileAttributes.type,
                              oauthToken: profileAttributes.oauthToken,
                              id: profileAttributes.id,
                              firstName: profileAttributes.firstName,
                              lastName: profileAttributes.lastName,
                              email: profileAttributes.email,
                              profilePictureURL: profileAttributes.profilePictureURL) { profile in
            createdProfile = profile
            group.leave()
        }
        group.wait()
        
        if let profile = createdProfile {
            LoginController.profile = profile
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isSignedIn)
            profile.saveToKeychain()
            completion(.success(()))
        } else {
            let error = NSError(domain: Constants.bundleID, code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create profile"])
            completion(.failure(error))
        }
    }
}
