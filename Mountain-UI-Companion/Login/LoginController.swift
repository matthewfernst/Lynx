//
//  LoginController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 3/14/23.
//

import Foundation
import OSLog

class LoginController {
    let loginViewController: LoginViewController
    var profileModel: Profile?
    
    init(loginViewController: LoginViewController) {
        self.loginViewController = loginViewController
    }
    
    func handleCommonSignIn(uuid: String, firstName: String? = nil, lastName: String? = nil, email: String? = nil, profilePictureURL: String = "") async {
        if let profileAttributes = try? await self.getExistingUser(uuid: uuid) {
            loginUser(userInfo: profileAttributes)
        } else if let firstName = firstName, let lastName = lastName, let email = email {
            await self.createNewUser(profileAttributes: ProfileAttributes(uuid: uuid,
                                                                          firstName: firstName,
                                                                          lastName: lastName,
                                                                          email: email,
                                                                          profilePictureURL: profilePictureURL))
        }
    }
    
    private func getExistingUser(uuid: String) async throws -> ProfileAttributes? {
        if let dynamoDBUserInfo = await DynamoDBUtils.getDynamoDBItem(uuid: uuid) {
            var profileAttributes = ProfileAttributes()
            for (key, value) in dynamoDBUserInfo {
                if case let .s(value) = value {
                    switch key {
                    case "uuid":
                        profileAttributes.uuid = value
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
            Logger.dynamoDB.debug("User info being returned.")
            return profileAttributes
        }
        Logger.dynamoDB.debug("Nil being returned for user info")
        return nil
    }
    
    private func loginUser(userInfo: ProfileAttributes) {
        Logger.userInfo.info("Existing user found.")
        self.signInUser(profileAttributes: userInfo)
    }
    
    private func createNewUser(profileAttributes: ProfileAttributes) async {
        Logger.userInfo.info("User does not exist. Creating User.")
        
        self.signInUser(profileAttributes: profileAttributes)
        
        await DynamoDBUtils.putDynamoDBItem(profileAttributes: profileAttributes)
    }
    
    private func signInUser(profileAttributes: ProfileAttributes) {
        Profile.createProfile(uuid: profileAttributes.uuid,
                              firstName: profileAttributes.firstName,
                              lastName: profileAttributes.lastName,
                              email: profileAttributes.email,
                              profilePictureURL: profileAttributes.profilePictureURL) { profile in
            self.profileModel = profile
        }
    }
}

// MARK: ProfileAttributes
struct ProfileAttributes {
    var uuid: String
    var firstName: String
    var lastName: String
    var email: String
    var profilePictureURL: String
    
    init(uuid: String, firstName: String, lastName: String, email: String, profilePictureURL: String = "") {
        self.uuid = uuid
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.profilePictureURL = profilePictureURL
    }
    
    init() {
        self.uuid = ""
        self.firstName = ""
        self.lastName = ""
        self.email = ""
        self.profilePictureURL = ""
    }
}
