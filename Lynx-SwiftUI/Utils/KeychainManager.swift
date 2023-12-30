//
//  KeychainManager.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/16/23.
//

import Foundation
import OSLog

class KeychainManager {
    enum KeychainError: Error {
        case duplicateEntry
        case unknown(OSStatus)
        case dataConversionError
        case itemNotFound
    }
    
    static func save(token: ExpirableAuthorizationToken) throws {
        let tokenData = try JSONEncoder().encode(token)
        
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecValueData as String: tokenData as AnyObject,
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status != errSecDuplicateItem else {
            throw KeychainError.duplicateEntry
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
        
        Logger.keychainManager.info("Successfully saved ExpirableToken.")
    }
    
    static func get() throws -> ExpirableAuthorizationToken? {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(
            query as CFDictionary, &result
        )
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                Logger.keychainManager.error("Error in getting ExpirableToken: Item Not Found")
                throw KeychainError.itemNotFound
            } else {
                Logger.keychainManager.error("Error in getting ExpirableToken OSStatus: \(status)")
                throw KeychainError.unknown(status)
            }
        }
        
        guard let tokenData = result as? Data else {
            Logger.keychainManager.error("Error in getting ExpirableToken: Data conversion error")
            throw KeychainError.dataConversionError
        }
        
        do {
            let token = try JSONDecoder().decode(ExpirableAuthorizationToken.self, from: tokenData)
            return token
        } catch {
            Logger.keychainManager.error("Error in getting ExpirableToken: Data conversion error")
            throw KeychainError.dataConversionError
        }
    }
    
    static func delete() throws {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unknown(status)
        }
        
        if status == errSecItemNotFound {
            throw KeychainError.itemNotFound
        }
        
        Logger.keychainManager.info("Successfully deleted ExpirableToken.")
    }
}
