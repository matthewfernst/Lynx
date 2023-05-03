//
//  UserDefaultsKeys.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 3/26/23.
//

import Foundation

enum UserDefaultsKeys
{
    // TabViewController
    static let theme = "theme"
    
    // Profile
    static let profileIsSignedInKey = "isSignedIn"
    
    // NotificationSettingsTableViewController
    static let notificationsTurnedOnOrOff = "notificationsAllowed"
    
    // Apollo Authorization Token
    static let authorizationToken = "authorizationToken"
    static let authorizationTokenExpirationDate = "authorizationTokenExpirationDate"
}
