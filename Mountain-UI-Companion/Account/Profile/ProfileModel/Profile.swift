//
//  Profile.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/25/23.
//

import Foundation
import UIKit

class Profile: NSObject, NSCoding
{
    var uuid: String
    var firstName, lastName: String
    var name: String {
        return firstName + " " + lastName
    }
    var email: String
    var profilePicture: UIImage?
    var profilePictureURL: String?
    var appTheme: String = "System"
    var units: String = "Imperial"
    
    init(uuid: String, firstName: String, lastName: String, email: String, profilePicture: UIImage? = nil, profilePictureURL: String? = "") {
        self.uuid = uuid
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.profilePicture = profilePicture
        self.profilePictureURL = profilePictureURL
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
    
    // MARK: - NSCoding
    
    func encode(with coder: NSCoder) {
        coder.encode(uuid, forKey: "uuid")
        coder.encode(firstName, forKey: "firstName")
        coder.encode(lastName, forKey: "lastName")
        coder.encode(email, forKey: "email")
        coder.encode(profilePicture, forKey: "profilePicture")
        coder.encode(profilePictureURL, forKey: "profilePictureURL")
        coder.encode(appTheme, forKey: "appTheme")
        coder.encode(units, forKey: "units")
    }
    
    required convenience init?(coder: NSCoder) {
        let uuid = coder.decodeObject(forKey: "uuid") as! String
        let firstName = coder.decodeObject(forKey: "firstName") as! String
        let lastName = coder.decodeObject(forKey: "lastName") as! String
        let email = coder.decodeObject(forKey: "email") as! String
        let profilePicture = coder.decodeObject(forKey: "profilePicture") as? UIImage
        let profilePictureURL = coder.decodeObject(forKey: "profilePictureURL") as? String
        let appTheme = coder.decodeObject(forKey: "appTheme") as! String
        let units = coder.decodeObject(forKey: "units") as! String
        
        self.init(uuid: uuid, firstName: firstName, lastName: lastName, email: email, profilePicture: profilePicture, profilePictureURL: profilePictureURL)
        self.appTheme = appTheme
        self.units = units
    }
    
    static func loadProfileFromUserDefaults() -> Profile? {
        guard let data = UserDefaults.standard.object(forKey: Profile.profileSignedInKey) as? Data,
              let profile = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Profile
        else {
            return nil
        }
        return profile
    }
    
    func saveToUserDefaults() {
        let data = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        UserDefaults.standard.set(data, forKey: Profile.profileSignedInKey)
    }
    
    override var description: String {
        // For debugging purposes
        return """
               UUID: \(self.uuid)
               firstName: \(self.firstName)
               lastName: \(self.lastName)
               email: \(self.email)
               profilePictureURL: \(String(describing: self.profilePictureURL))
               """
    }
    
}

// MARK: - Extensions

extension Profile { // Constants
    static let isSignedInKey = "isSignedIn"
    static let profileSignedInKey = "profileSignedIn"
}

#if DEBUG
extension Profile {
    static var sampleProfile = Profile(uuid: "1234",
                                       firstName: "John",
                                       lastName: "AppleSeed",
                                       email: "johnappleseed@icloud.com")
}
#endif
