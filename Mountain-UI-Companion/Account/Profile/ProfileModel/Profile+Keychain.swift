//
//  Porfile+Keychain.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 3/22/23.
//

import AuthenticationServices
import Foundation
import GoogleSignIn

extension Profile
{
    
    static func loadProfileFromKeychain(completion: @escaping (Profile?) -> Void) {
        
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrService as String: Constants.bundleID,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String : Any] as CFDictionary
        
        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query, &dataTypeRef)
        if status == errSecSuccess {
            if let data = dataTypeRef as? Data,
               let id = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSString.self, from: data) as? String {
                GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                    if error != nil || user == nil {
                        // Show the app's signed-out state.
                    } else {
                        // Show the app's signed-in state.
                        if let token = user?.idToken?.tokenString {
                            LoginController.handleCommonSignIn(type: SignInType.google.rawValue, id: id, token: token) { result in
                                switch result {
                                case .success:
                                    completion(LoginController.profile)
                                case .failure(_):
                                    completion(nil)
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    
    public func saveToKeychain() {
        let data = try? NSKeyedArchiver.archivedData(withRootObject: self.id, requiringSecureCoding: false)
        
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrService as String: Constants.bundleID,
            kSecValueData as String: data!
        ] as [String : Any] as CFDictionary
        
        SecItemDelete(query) // Delete any existing item
        
        let status = SecItemAdd(query, nil)
        if status != errSecSuccess {
            print("Failed to save profile to Keychain with error: \(status)")
        }
    }
    
    
    public func signOut() {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrService as String: Constants.bundleID
        ] as CFDictionary
        
        let status = SecItemDelete(query)
        if status != errSecSuccess && status != errSecItemNotFound {
            print("Failed to delete profile from Keychain with error: \(status)")
        }
        let defaults = UserDefaults.standard
        
        for key in UserDefaultsKeys.allKeys {
            defaults.removeObject(forKey: key)
        }
    }
}
