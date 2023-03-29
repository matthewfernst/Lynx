//
//  Profile.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/25/23.
//

import Foundation
import Security
import UIKit

class Profile
{
    var id: String
    var firstName, lastName: String
    var name: String { firstName + " " + lastName }
    var email: String
    var profilePicture: UIImage?
    var profilePictureURL: String?
    var appTheme: String = "System"
    var units: String = "Imperial"
    var notificationsAllowed: Bool?
    
    init(id: String, firstName: String, lastName: String, email: String, profilePicture: UIImage? = nil, profilePictureURL: String? = "") {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.profilePicture = profilePicture
        self.profilePictureURL = profilePictureURL
    }
    
    public static func createProfile(uuid: String, firstName: String, lastName: String, email: String, profilePictureURL: String? = nil, completion: @escaping (Profile) -> Void) {
        guard let profilePictureURL = URL(string: profilePictureURL ?? "") else {
            completion(Profile(id: id, firstName: firstName, lastName: lastName, email: email))
            return
        }
        
        URLSession.shared.dataTask(with: profilePictureURL) { (data, response, error) in
            if let error = error {
                print("Error downloading profile picture: \(error.localizedDescription)")
                completion(Profile(id: id, firstName: firstName, lastName: lastName, email: email))
                return
            }
            
            guard let data = data, let profilePicture = UIImage(data: data) else {
                completion(Profile(id: id, firstName: firstName, lastName: lastName, email: email))
                return
            }
            
            let profile = Profile(id: id,
                                  firstName: firstName,
                                  lastName: lastName,
                                  email: email,
                                  profilePicture: profilePicture,
                                  profilePictureURL: profilePictureURL.absoluteString)
            completion(profile)
        }.resume()
    }
}

// MARK: - Extensions for Debugging
#if DEBUG
extension Profile: CustomDebugStringConvertible
{
    var debugDescription: String {
        return """
               id: \(self.id)
               firstName: \(self.firstName)
               lastName: \(self.lastName)
               email: \(self.email)
               profilePictureURL: \(String(describing: self.profilePictureURL))
               """
    }
}
extension Profile {
    static var sampleProfile = Profile(id: "1234",
                                       firstName: "John",
                                       lastName: "AppleSeed",
                                       email: "johnappleseed@icloud.com")
}
#endif
