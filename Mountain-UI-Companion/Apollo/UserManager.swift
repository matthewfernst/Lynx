//
//  UserManager.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 4/30/23.
//

import Foundation

class UserManager {
    static let shared = UserManager()
    
    private init() {}
    
    var token: ExpirableAuthorizationToken? {
        get {
            guard let savedToken = UserDefaults.standard.string(forKey: UserDefaultsKeys.authorizationToken),
                  let savedExpireDate = UserDefaults.standard.object(forKey: UserDefaultsKeys.authorizationTokenExpirationDate) as? Date else {
                return nil
            }
            return ExpirableAuthorizationToken(token: savedToken, expirationDate: savedExpireDate)
        }
        set {
            UserDefaults.standard.set(newValue?.token, forKey: UserDefaultsKeys.authorizationToken)
            UserDefaults.standard.set(newValue?.expirationDate, forKey: UserDefaultsKeys.authorizationTokenExpirationDate)
        }
    }
    
    func renewToken(completion: @escaping (Result<String, Error>) -> Void) {
        //TODO: Add Profile!
        ApolloMountainUIClient.loginOrCreateUser(type: "APPLE",
                                                 id: "9702145508",
                                                 token: "1234",
                                                 email: "sully@apple.com",
                                                 firstName: "Sully",
                                                 lastName: "Perich",
                                                 profilePictureUrl: "sully-wully.sullysullivan.com") { result in
            switch result {
            case .success:
                completion(.success((UserManager.shared.token!.value)))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

struct ExpirableAuthorizationToken {
    let token: String
    let expirationDate: Date
    
    var isExpired: Bool {
        return Date() >= expirationDate
    }
    
    var value: String {
        return token
    }
}
