//
//  LoginController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 3/14/23.
//

import Foundation
import OSLog

class LoginController
{
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
                                                 lastName: lastName) { result in
            switch result {
            case .success:
                Logger.loginController.info("Token successfully recieved.")
                
                self.loginUser()
                completion(.success(()))
            case .failure:
                Logger.loginController.error("User not logged in.")
            }
        }
    }
    
    
    private static func loginUser() {
        ApolloMountainUIClient.getProfileInformation() { result in
            switch result {
            case .success(let profileAttributes):
                self.signInUser(profileAttributes: profileAttributes)
            case .failure(let error):
                Logger.loginController.error("No profile attributes returned. \(error)")
            }
            
        }
    }
    
    
    private static func signInUser(profileAttributes: ProfileAttributes) {
        let group = DispatchGroup()
        
        var createdProfile: Profile?
        
        group.enter()
        
        Profile.createProfile(id: profileAttributes.id,
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
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.profileIsSignedInKey)
            profile.saveToKeychain()
        }
    }
    
}

