import SwiftUI
import GoogleSignIn
import FBSDKLoginKit
import OSLog

final class UserManager {
    static let shared = UserManager()
        
    var lynxToken: ExpirableLynxToken? {
        get {
            do {
                return try KeychainManager.get() // will return nil if no lynxToken is available
            } catch {
                Logger.userManager.error("KeychainManager failed to handle getting the ExpirableLynxToken. Please check the logs.")
                cleanUpFailedReAuth()
                return nil
            }
        }
        set { // if we do UserManager.shared.lynxToken = nil -> we want to delete the lynxToken
            do {
                try (newValue == nil ? KeychainManager.delete() : KeychainManager.save(token: newValue!))
            } catch {
                Logger.userManager.error("KeychainManager failed to handle setting the ExpirableLynxToken. Please check the logs.")
                cleanUpFailedReAuth()
            }
        }
    }
    
    
    private func cleanUpFailedReAuth() {
        ProfileManager.shared.deleteProfile()
    }
    
    func renewToken(completion: @escaping (Result<String, Error>) -> Void) {
        enum RenewTokenErrors: Error {
            case noProfileSaved
            case noOauthTokenSaved
        }

        if let refreshToken = lynxToken?.refreshToken {
            ApolloLynxClient.refreshAccessToken(refreshToken: refreshToken) { result in
                switch result {
                case .success(_):
                    break
                case .failure(_):
                    Logger.userManager.info("Failed to refresh token.")
                    self.cleanUpFailedReAuth()
                }
            }
        } else {
            Logger.userManager.error("Could not refresh access token. No refresh token saved!")
            cleanUpFailedReAuth()
        }
    }
}


struct ExpirableLynxToken: Codable {
    let accessToken: String
    let expirationDate: Date
    let refreshToken: String
    
    var isExpired: Bool {
        return Date().timeIntervalSince1970 >= expirationDate.timeIntervalSince1970
    }
}
