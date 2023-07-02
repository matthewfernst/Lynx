//
//  LoginController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 3/14/23.
//

import Foundation
import OSLog

enum ProfileError: Error
{
    case profileCreationFailed
}

class LoginController
{
    let loginViewController: LoginViewController
    static var profile: Profile?
    
    init(loginViewController: LoginViewController) {
        self.loginViewController = loginViewController
    }
    
    public func handleCommonSignIn(type: String, id: String, token: String, email: String? = nil, firstName: String? = nil, lastName: String? = nil, profilePictureURL: String = "", completion: @escaping (Result<Void, Error>) -> Void) {
        ApolloMountainUIClient.loginOrCreateUser(type: type,
                                                 id: id,
                                                 token: token,
                                                 email: email,
                                                 firstName: firstName,
                                                 lastName: lastName,
                                                 profilePictureUrl: profilePictureURL) { result in
            switch result {
            case .success(let validatedInvite):
                Logger.loginController.info("Authorization Token successfully recieved.")
                if validatedInvite {
                    self.loginUser(completion: completion)
                } else {
                    self.loginViewController.setupInvitationSheet { [weak self] in
                        self?.loginUser(completion: completion)
                    }
                }
            case .failure:
                completion(.failure(UserError.noAuthorizationTokenReturned))
            }
        }
    }
    
    private func loginUser(completion: @escaping (Result<Void, Error>) -> Void) {
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
    
    private func signInUser(profileAttributes: ProfileAttributes, completion: @escaping (Result<Void, Error>) -> Void) {
        let group = DispatchGroup()
        var createdProfile: Profile?
        group.enter()
        
        let defaults = UserDefaults.standard
        defaults.setValue(profileAttributes.type, forKey: UserDefaultsKeys.loginType)
        defaults.setValue(profileAttributes.id, forKey: UserDefaultsKeys.appleOrGoogleId)
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
            completion(.success(()))
        } else {
            completion(.failure(ProfileError.profileCreationFailed))
        }
    }
    
    public static func signOut() {
        UserManager.shared.token = nil
        ApolloMountainUIClient.clearCache()
        
        let defaults = UserDefaults.standard
        for key in UserDefaultsKeys.allKeys {
            defaults.removeObject(forKey: key)
        }
        
        BookmarkManager.removeAllBookmarks()
    }
}

