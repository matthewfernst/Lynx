//
//  Porfile+Keychain.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 3/22/23.
//

import Foundation

extension Profile
{
    
    static func loadProfileFromKeychain(completion: @escaping (Profile?) -> Void) async {
        
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
                await LoginController.handleCommonSignIn(id: id)
                DispatchQueue.main.async {
                    completion(LoginController.profile)
                }
                return
            }
        }
        DispatchQueue.main.async {
            completion(nil)
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
    }
}
