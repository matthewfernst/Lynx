//
//  LoginController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 3/14/23.
//

import Foundation
import OSLog

class LoginController
{
    let loginViewController: LoginViewController
    static var profile: Profile?
    
    init(loginViewController: LoginViewController) {
        self.loginViewController = loginViewController
    }
    
    static func handleCommonSignIn(id: String, firstName: String? = nil, lastName: String? = nil, email: String? = nil, profilePictureURL: String = "") async {
        if let profileAttributes = try? await self.getExistingUser(id: id) {
            loginUser(profileAttributes: profileAttributes)
        } else if let firstName = firstName, let lastName = lastName, let email = email {
            await self.createNewUser(profileAttributes: ProfileAttributes(id: id,
                                                                          firstName: firstName,
                                                                          lastName: lastName,
                                                                          email: email,
                                                                          profilePictureURL: profilePictureURL))
        }
    }
    
    private static func getExistingUser(id: String) async throws -> ProfileAttributes? {
        if let dynamoDBUserInfo = await DynamoDBUtils.getDynamoDBItem(id: id) {
            var profileAttributes = ProfileAttributes()
            for (key, value) in dynamoDBUserInfo {
                if case let .s(value) = value {
                    switch key {
                    case "id":
                        profileAttributes.id = value
                    case "firstName":
                        profileAttributes.firstName = value
                    case "lastName":
                        profileAttributes.lastName = value
                    case "email":
                        profileAttributes.email = value
                    case "profilePictureURL":
                        profileAttributes.profilePictureURL = value
                    default:
                        break
                    }
                }
            }
            Logger.dynamoDB.debug("Profile Attributes being returned.")
            return profileAttributes
        }
        Logger.dynamoDB.debug("Nil being returned for user info")
        return nil
    }
    
    private static func loginUser(profileAttributes: ProfileAttributes) {
        Logger.loginController.info("Existing user found.")
        self.signInUser(profileAttributes: profileAttributes)
    }
    
    private static func createNewUser(profileAttributes: ProfileAttributes) async {
        Logger.loginController.info("User does not exist. Creating User.")
        
        self.signInUser(profileAttributes: profileAttributes)
        
        await DynamoDBUtils.putDynamoDBItem(profileAttributes: profileAttributes)
    }
    
    private static func signInUser(profileAttributes: ProfileAttributes) {
        let group = DispatchGroup()
        
        var createdProfile: Profile?
        
        group.enter()
        
        Profile.createProfile(id: profileAttributes.id,
                              firstName: profileAttributes.firstName,
                              lastName: profileAttributes.lastName,
                              email: profileAttributes.email,
                              profilePictureURL: profileAttributes.profilePictureURL) { profile in
            createdProfile = profile
            group.leave()
        }
        
        group.wait()
        
        if let profile = createdProfile {
            LoginController.profile = profile
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.profileIsSignedInKey)
            profile.saveToKeychain()
        }
    }
    
}

// MARK: - ProfileAttributes
struct ProfileAttributes: CustomDebugStringConvertible
{
    
    var id: String
    var firstName: String
    var lastName: String
    var email: String
    var profilePictureURL: String
    
    init(id: String, firstName: String, lastName: String, email: String, profilePictureURL: String = "") {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.profilePictureURL = profilePictureURL
    }
    
    init() {
        self.id = ""
        self.firstName = ""
        self.lastName = ""
        self.email = ""
        self.profilePictureURL = ""
    }
    
    var debugDescription: String {
       """
       id: \(self.id)
       firstName: \(self.firstName)
       lastName: \(self.lastName)
       email: \(self.email)
       profilePictureURL: \(String(describing: self.profilePictureURL))
       """
    }
}
