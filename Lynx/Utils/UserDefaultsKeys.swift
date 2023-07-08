//
//  UserDefaultsKeys.swift
//  Lynx
//
//  Created by Matthew Ernst on 3/26/23.
//

import Foundation

struct UserDefaultsKeys
{
    // TabViewController
    static let theme = "theme"
    
    // Connected Folder
    static let connectedFolderNickname = "connectedFolderNickname"
    
    // Profile
    static let isSignedIn = "isSignedIn"
    static let appleOrGoogleId = "appleOrGoogleId"
    
    // NotificationSettingsTableViewController
    static let notificationsTurnedOnOrOff = "notificationsAllowed"
    
    // Apollo Authorization Token
    static let authorizationToken = "authorizationToken"
    static let authorizationTokenExpirationDate = "authorizationTokenExpirationDate"
    static let oauthToken = "oauthToken"
    static let loginType = "loginType"
    
    // All Keys
    static let allKeys: [String] = [
        theme,
        connectedFolderNickname,
        isSignedIn,
        appleOrGoogleId,
        notificationsTurnedOnOrOff,
        authorizationToken,
        authorizationTokenExpirationDate,
        oauthToken,
        loginType
    ]
}
