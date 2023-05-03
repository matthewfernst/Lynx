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
            guard let savedToken = UserDefaults.standard.string(forKey: UserDefaultsKeys.authorizationToken) else {
                return nil
            }
            return ExpirableAuthorizationToken(token: savedToken)
        }
        set {
            UserDefaults.standard.set(newValue?.token, forKey: UserDefaultsKeys.authorizationToken)
            UserDefaults.standard.set(newValue?.expirationDate, forKey: UserDefaultsKeys.authorizationTokenExpirationDate)
        }
    }
    
    func renewToken(completion: @escaping (Result<ExpirableAuthorizationToken, Error>) -> Void) {
         ApolloMountainUIClient.loginOrCreateUser(type: "APPLE",
                                                 id: "9702145508",
                                                 token: "1234",
                                                 email: "sully@apple.com",
                                                 firstName: "Sully",
                                                 lastName: "Perich") { result in
            switch result {
            case .success(let token):
                let expirableToken = ExpirableAuthorizationToken(token: token)
                self.token = expirableToken
                completion(.success(expirableToken))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

struct ExpirableAuthorizationToken {
    let token: String
    let expirationDate: Date
    
    init(token: String) {
        self.token = token
        
        let currentDate = Date()
        let expirationDate = Calendar.current.date(byAdding: .day, value: 3, to: currentDate)!
        
        self.expirationDate = expirationDate
    }
    
    var isExpired: Bool {
        return Date() >= expirationDate
    }
    
    var value: String {
        return token
    }
}
