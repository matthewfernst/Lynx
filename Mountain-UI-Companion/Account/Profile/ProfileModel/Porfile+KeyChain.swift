//
//  Porfile+KeyChain.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 3/22/23.
//

import Foundation

extension Profile
{
    
    func encode(with coder: NSCoder) {
        coder.encode(uuid, forKey: "uuid")
        coder.encode(firstName, forKey: "firstName")
        coder.encode(lastName, forKey: "lastName")
        coder.encode(email, forKey: "email")
        coder.encode(profilePicture, forKey: "profilePicture")
        coder.encode(profilePictureURL, forKey: "profilePictureURL")
        coder.encode(appTheme, forKey: "appTheme")
        coder.encode(units, forKey: "units")
    }
    
    static func loadProfileFromKeychain() -> Profile? {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrService as String: "com.yourcompany.yourapp.profileservice",
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as CFDictionary

        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query, &dataTypeRef)
        if status == errSecSuccess {
            if let data = dataTypeRef as? Data,
               let profile = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Profile {
                return profile
            }
        }
        return nil
    }

    public func saveToKeychain() {
        let data = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)

        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrService as String: Constants.bundleID,
            kSecValueData as String: data!
        ] as CFDictionary

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
