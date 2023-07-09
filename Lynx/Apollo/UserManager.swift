//
//  UserManager.swift
//  Lynx
//
//  Created by Matthew Ernst on 4/30/23.
//

import Foundation

class UserManager {
    static let shared = UserManager()
    
    private init() {}
    
    var token: ExpirableAuthorizationToken? {
        get {
            guard let savedAuthorizationToken = UserDefaults.standard.string(forKey: UserDefaultsKeys.authorizationToken),
                  let savedExpireDate = UserDefaults.standard.object(forKey: UserDefaultsKeys.authorizationTokenExpirationDate) as? Date,
                  let savedOauthToken = UserDefaults.standard.string(forKey: UserDefaultsKeys.oauthToken) else {
                UserDefaults.standard.set(false, forKey: UserDefaultsKeys.isSignedIn)
                return nil
            }
            return ExpirableAuthorizationToken(authorizationToken: savedAuthorizationToken, expirationDate: savedExpireDate, oauthToken: savedOauthToken)
        }
        set {
            UserDefaults.standard.set(newValue?.authorizationToken, forKey: UserDefaultsKeys.authorizationToken)
            UserDefaults.standard.set(newValue?.expirationDate, forKey: UserDefaultsKeys.authorizationTokenExpirationDate)
            UserDefaults.standard.set(newValue?.oauthToken, forKey: UserDefaultsKeys.oauthToken)
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isSignedIn)
        }
    }
    
    func renewToken(completion: @escaping (Result<String, Error>) -> Void) {
        enum RenewTokenErrors: Error
        {
            case noProfileSaved
            case noOauthTokenSaved
        }

        guard let profile = LoginController.profile else {
            return completion(.failure(RenewTokenErrors.noProfileSaved))
        }
        
        guard let oauthToken = UserDefaults.standard.string(forKey: UserDefaultsKeys.oauthToken) else {
            return completion(.failure(RenewTokenErrors.noOauthTokenSaved))
        }
        
        ApolloLynxClient.loginOrCreateUser(type: profile.type,
                                                 id: profile.id,
                                                 token: oauthToken,
                                                 email: profile.email,
                                                 firstName: profile.firstName,
                                                 lastName: profile.lastName,
                                                 profilePictureUrl: profile.profilePictureURL) { result in
            switch result {
            case .success:
                completion(.success((UserManager.shared.token!.authorizationTokenValue)))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

struct ExpirableAuthorizationToken
{
    let authorizationToken: String
    let expirationDate: Date
    let oauthToken: String
    
    var isExpired: Bool {
        return Date().timeIntervalSince1970 >= expirationDate.timeIntervalSince1970
    }
    
    var authorizationTokenValue: String {
        return authorizationToken
    }
    
    var oauthTokenValue: String {
        return oauthToken
    }
}
