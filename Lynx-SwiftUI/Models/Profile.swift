//
//  Profile.swift
//  Lynx
//
//  Created by Matthew Ernst on 1/25/23.
//

import Foundation
import SwiftData

@Model
final class Profile {
    private(set) var id: String
    private(set) var oauthType: String
    private(set) var firstName: String
    private(set) var lastName: String
    var name: String { firstName + " " + lastName }
    private(set) var email: String
    var profilePictureURL: URL?
    var measurementSystem: MeasurementSystem = Profile.getDefaultMeasurementSystem()
    var notificationsAllowed: Bool?
    var isSignedIn = false
    
    init(
        id: String,
        oauthType: String,
        firstName: String,
        lastName: String,
        email: String,
        profilePictureURL: URL? = nil
    ) {
        self.oauthType = oauthType
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.profilePictureURL = profilePictureURL
    }
    
    convenience init(profileAttributes: ProfileAttributes) {
        self.init(
            id: profileAttributes.id,
            oauthType: profileAttributes.oauthType,
            firstName: profileAttributes.firstName!,
            lastName: profileAttributes.lastName!,
            email: profileAttributes.email!,
            profilePictureURL: profileAttributes.profilePictureURL
        )
    }
    
    private static func getDefaultMeasurementSystem() -> MeasurementSystem {
        let locale = Locale.current
        if let countryCode = locale.language.region?.identifier, countryCode == "US" {
            return .imperial
        } else {
            return .metric
        }
    }
    
    func edit(newFirstName: String?, newLastName: String?, newEmail: String?) {
        self.firstName = newFirstName ?? self.firstName
        self.lastName = newLastName ?? self.lastName
        self.email = newEmail ?? self.email
    }
    
#if DEBUG
    static let debugProfile = Profile(
        id: "123456890",
        oauthType: OAuthType.apple.rawValue,
        firstName: "Johnny",
        lastName: "Appleseed",
        email: "johnnyappleseed@apple.com",
        profilePictureURL: ProfileManager.Constants.defaultProfilePictureURL
    )
#endif
}

extension Profile: Identifiable { }

// MARK: - Extensions for Debugging
#if DEBUG
extension Profile: CustomDebugStringConvertible {
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
