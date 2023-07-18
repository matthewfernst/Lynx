//
//  Profile.swift
//  Lynx
//
//  Created by Matthew Ernst on 1/25/23.
//

import Foundation
import Security
import UIKit
import Apollo

class Profile {
    var type: String
    var oauthToken: String
    var id: String
    var firstName, lastName: String
    var name: String { firstName + " " + lastName }
    var email: String
    var profilePicture: UIImage?
    var profilePictureURL: String?
    var appTheme: String = "System"
    var measurementSystem: MeasurementSystem = Profile.getDefaultMeasurementSystem()
    var notificationsAllowed: Bool?
    
    init(type: String, oauthToken: String, id: String, firstName: String, lastName: String, email: String, profilePicture: UIImage? = nil, profilePictureURL: String? = "") {
        self.type = type
        self.oauthToken = oauthToken
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.profilePicture = profilePicture
        self.profilePictureURL = profilePictureURL
    }
    
    private static func getDefaultMeasurementSystem() -> MeasurementSystem {
        let locale = Locale.current
        if let countryCode = locale.language.region?.identifier, countryCode == "US" {
            return .imperial
        } else {
            return .metric
        }
    }
    
    public static func createProfile(type: String, oauthToken: String, id: String, firstName: String, lastName: String, email: String, profilePictureURL: String? = nil, completion: @escaping (Profile) -> Void) {
        guard let profilePictureURL = URL(string: profilePictureURL ?? "") else {
            completion(Profile(type: type, oauthToken: oauthToken, id: id, firstName: firstName, lastName: lastName, email: email))
            return
        }
        
        ProfilePictureUtils.downloadProfilePicture(with: profilePictureURL) { profilePicture in
            let profile = Profile(type: type,
                                  oauthToken: oauthToken,
                                  id: id,
                                  firstName: firstName,
                                  lastName: lastName,
                                  email: email,
                                  profilePicture: profilePicture,
                                  profilePictureURL: profilePictureURL.absoluteString)
            completion(profile)
        }
    }
    
    public func editAttributes(newFirstName: String?, newLastName: String?, newEmail: String?, newProfilePicture: UIImage?, newProfilePictureURL: String?) {
        self.firstName = newFirstName ?? self.firstName
        self.lastName = newLastName ?? self.lastName
        self.email = newEmail ?? self.email
        self.profilePicture = newProfilePicture ?? self.profilePicture
        self.profilePictureURL = newProfilePictureURL ?? self.profilePictureURL
    }
    
}

// MARK: - Extensions for Debugging
#if DEBUG
extension Profile: CustomDebugStringConvertible
{
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
#endif
