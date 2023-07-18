//
//  ProfilePictureUtils.swift
//  Lynx
//
//  Created by Matthew Ernst on 3/28/23.
//

import Foundation
import UIKit

struct ProfilePictureUtils
{
    public static func getDefaultProfilePicture(name: String, fontSize: CGFloat) -> UILabel {
        let initialsLabel = UILabel()
        
        initialsLabel.text = name.initials
        initialsLabel.textColor = .label
        initialsLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        
        return initialsLabel
    }
    
    public static func setupDefaultProfilePicture(profile: Profile, profilePictureImageView: UIImageView, defaultProfilePictureLabel: UILabel?, fontSize: CGFloat) -> UILabel? {
        if defaultProfilePictureLabel == nil {
            profilePictureImageView.image = nil
            
            let defaultProfilePictureLabel = ProfilePictureUtils.getDefaultProfilePicture(name: profile.name, fontSize: fontSize)
            
            profilePictureImageView.addSubview(defaultProfilePictureLabel)
            
            defaultProfilePictureLabel.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                defaultProfilePictureLabel.centerXAnchor.constraint(equalTo: profilePictureImageView.centerXAnchor),
                defaultProfilePictureLabel.centerYAnchor.constraint(equalTo: profilePictureImageView.centerYAnchor)
            ])
            return defaultProfilePictureLabel
        }
        return nil
    }
    
    public static func downloadProfilePicture(with url: URL, completion: @escaping (UIImage) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error downloading profile picture: \(error)")
                return
            }

            guard let data = data, let profilePicture = UIImage(data: data) else {
                print("Unable to extract data to create picture")
                return
            }

            print("Picture being returned.")
            completion(profilePicture)
        }.resume()
    }

}
