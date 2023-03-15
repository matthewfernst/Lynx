//
//  Profile.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/25/23.
//

import Foundation
import UIKit

class Profile
{
    var uuid: String
    var firstName, lastName: String
    var name: String {
        return firstName + " " + lastName
    }
    var email: String
    var profilePicture: UIImage?
    var profilePictureURL: String?
    var isSignedIn: Bool
    
    // TODO: Season Stats in different place?
    // var seasonSummary = [SessionSummary?]()
    // var mostRecentSessionSummary = [SessionSummary?]()
    
    init(uuid: String, firstName: String, lastName: String, email: String, profilePicture: UIImage? = nil, profilePictureURL: String? = "", isSignedIn: Bool = true) {
        self.uuid = uuid
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.profilePicture = profilePicture
        self.profilePictureURL = profilePictureURL
        self.isSignedIn = isSignedIn
    }
    
    func getDefaultProfilePicture(fontSize: CGFloat, size: CGSize, move: CGPoint) -> UIImage {
        return (name.initials.image(withAttributes: [
            .font: UIFont.systemFont(ofSize: fontSize, weight: .medium),
        ], size: size, move: move)?.withTintColor(.label))!
    }
    
    static func createProfile(uuid: String, firstName: String, lastName: String, email: String, profilePictureURL: String? = nil, completion: @escaping (Profile) -> Void) {
        guard let profilePictureURL = URL(string: profilePictureURL ?? "") else {
            completion(Profile(uuid: uuid, firstName: firstName, lastName: lastName, email: email))
            return
        }

        URLSession.shared.dataTask(with: profilePictureURL) { (data, response, error) in
            if let error = error {
                print("Error downloading profile picture: \(error.localizedDescription)")
                completion(Profile(uuid: uuid, firstName: firstName, lastName: lastName, email: email))
                return
            }
            
            guard let data = data, let profilePicture = UIImage(data: data) else {
                completion(Profile(uuid: uuid, firstName: firstName, lastName: lastName, email: email))
                return
            }
            
            let profile = Profile(uuid: uuid,
                                  firstName: firstName,
                                  lastName: lastName,
                                  email: email,
                                  profilePicture: profilePicture,
                                  profilePictureURL: profilePictureURL.absoluteString)
            completion(profile)
        }.resume()
    }

}

#if DEBUG
extension Profile {
    static var sampleProfile = Profile(uuid: UUID().uuidString,
                                       firstName: "John",
                                       lastName: "AppleSeed",
                                       email: "johnappleseed@icloud.com")
}
#endif
