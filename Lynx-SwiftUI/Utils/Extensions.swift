import OSLog
import SwiftUI

extension Logger {
  private static var subsystem = Bundle.main.bundleIdentifier!

  static let apollo = Logger(subsystem: subsystem, category: "Apollo")

  static let bookmarkManager = Logger(subsystem: subsystem, category: "BookmarkManager")

  static let editProfileHandler = Logger(subsystem: subsystem, category: "EditProfileHandler")

  static let editProfileView = Logger(subsystem: subsystem, category: "EditProfileView")

  static let folderConnectionHandler = Logger(
    subsystem: subsystem, category: "FolderConnectionHandler")

  static let folderConnectionView = Logger(subsystem: subsystem, category: "FolderConnectionView")

  static let homeView = Logger(subsystem: subsystem, category: "HomeView")

  static let keychainManager = Logger(subsystem: subsystem, category: "KeychainManager")

  static let leaderboard = Logger(subsystem: subsystem, category: "Leaderboard")

  static let logbook = Logger(subsystem: subsystem, category: "LogbookView")

  static let logbookStats = Logger(subsystem: subsystem, category: "LogbookStats")

  static let logbookView = Logger(subsystem: subsystem, category: "LogbookView")

  static let loginView = Logger(subsystem: subsystem, category: "LoginView")

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

  var sanitize: String {
    self.replacingOccurrences(of: "_", with: " ")
  }
}
