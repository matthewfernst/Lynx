//
//  Extensions.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/24/23.
//

import SwiftUI
import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let apollo = Logger(subsystem: subsystem, category: "Apollo")
    
    static let appleSignInHandler = Logger(subsystem: subsystem, category: "AppleSignInHandler")
    
    static let bookmarkManager = Logger(subsystem: subsystem, category: "BookmarkManager")
    
    static let editProfileHandler = Logger(subsystem: subsystem, category: "EditProfileHandler")
    
    static let editProfileView = Logger(subsystem: subsystem, category: "EditProfileView")
    
    static let facebookSignInHandler = Logger(subsystem: subsystem, category: "FacebookSignInHandler")
    
    static let folderConnectionHandler = Logger(subsystem: subsystem, category: "FolderConnectionHandler")
    
    static let folderConnectionView = Logger(subsystem: subsystem, category: "FolderConnectionView")
    
    static let homeView = Logger(subsystem: subsystem, category: "HomeView")
    
    static let invitationKeySheet = Logger(subsystem: subsystem, category: "InvitationKeySheet")
    
    static let keychainManager = Logger(subsystem: subsystem, category: "KeychainManager")
    
    static let logbook = Logger(subsystem: subsystem, category: "LogbookView")
    
    static let loginHandler = Logger(subsystem: subsystem, category: "LoginHandler")
    
    static let notifications = Logger(subsystem: subsystem, category: "Notifications")
    
    static let profileManager = Logger(subsystem: subsystem, category: "ProfileManager")
    
    static let userManager = Logger(subsystem: subsystem, category: "UserManager")
}

extension String {
    var initials: String {
        let splitName = self.components(separatedBy: .whitespaces)
        var initials = ""
        for name in splitName {
            if let namesFirstLetter = name.first {
                initials += namesFirstLetter.uppercased()
            }
        }
        return initials
    }
}
