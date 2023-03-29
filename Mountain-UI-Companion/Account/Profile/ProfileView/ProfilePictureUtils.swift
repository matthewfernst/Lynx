//
//  ProfilePictureUtils.swift
//  Mountain-UI-Companion
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
}
