//
//  UserManager.swift
//  Lynx
//
//  Created by Matthew Ernst on 4/30/23.
//

import SwiftUI
import GoogleSignIn
import FBSDKLoginKit
import OSLog

class UserManager {
    static let shared = UserManager()
        
    var token: ExpirableAuthorizationToken? {
        get {
            do {
                return try KeychainManager.get() // will return nil if no token is available
            } catch {
                Logger.userManager.error("KeychainManager failed to handle getting the ExpirableToken. Please check the logs.")
                cleanUpFailedReAuth()
                return nil
            }
        }
        set { // if we do UserManager.shared.token = nil -> we want to delete the token
            do {
                try (newValue == nil ? KeychainManager.delete() : KeychainManager.save(token: newValue!))
            } catch {
                Logger.userManager.error("KeychainManager failed to handle setting the ExpirableToken. Please check the logs.")
                cleanUpFailedReAuth()
            }
        }
    }
    
    
    private func cleanUpFailedReAuth() {
        ProfileManager.shared.deleteProfile()
    }
    
    func renewToken(completion: @escaping (Result<String, Error>) -> Void) {
        enum RenewTokenErrors: Error {
            case noProfileSaved
            case noOauthTokenSaved
        }
        
        guard let profile = ProfileManager.shared.profile else {
            return completion(.failure(RenewTokenErrors.noProfileSaved))
        }
        
        func handleLoginOrCreateUser(oauthToken: String) {
            ApolloLynxClient.loginOrCreateUser(
                id: profile.id,
                oauthType: profile.oauthType,
                oauthToken: oauthToken,
                email: profile.email,
                firstName: profile.firstName,
                lastName: profile.lastName,
                profilePictureURL: profile.profilePictureURL
            ) { result in
                switch result {
                case .success:
                    Logger.userManager.info("Successfully re-authorized authorization token.")
                    completion(.success((UserManager.shared.token!.authorizationToken)))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        
        switch OAuthType(rawValue: profile.oauthType) {
        case .apple:
            // TODO: Needs the backend to support this :(
            cleanUpFailedReAuth()
        case .google:
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                // Currently fails with simulator? But shouldn't fail on device. Needs more investigation.
                if error != nil {
                    Logger.userManager.error("Restore of previous Google Sign In failed with: \(error)")
                    self.cleanUpFailedReAuth()
                    return
                }
                if let oauthToken = user?.idToken?.tokenString {
                    handleLoginOrCreateUser(oauthToken: oauthToken)
                }
            }
            
        case .facebook:
            // Facebook gives a 60-day life token and automatically updates when sending requests
            // to Facebook servers. If it does expire, then we have to re login.
            
            AccessToken.refreshCurrentAccessToken { _, _, error in
                if error != nil {
                    Logger.userManager.error("Restore of previous Facebook Sign In failed with: \(error)")
                    self.cleanUpFailedReAuth()
                    return
                }
                
                if let oauthToken = AccessToken.current?.tokenString {
                    handleLoginOrCreateUser(oauthToken: oauthToken)
                }
            }
            
        case .none:
            self.cleanUpFailedReAuth()
            fatalError("OAuth type is not supported. Got: \(profile.oauthType)")
        }
    }
}


struct ExpirableAuthorizationToken: Codable {
    let authorizationToken: String
    let expirationDate: Date
    
    var isExpired: Bool {
        return Date().timeIntervalSince1970 >= expirationDate.timeIntervalSince1970
    }
}
