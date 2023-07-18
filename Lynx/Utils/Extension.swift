//
//  Extension.swift
//  Lynx
//
//  Created by Matthew Ernst on 1/23/23.
//

import Foundation
import UIKit
import OSLog

extension UIImage
{
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )
        
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
}

extension UIImageView
{
    
    func makeRounded() {
        layer.masksToBounds = false
        layer.cornerRadius = self.frame.height / 2
        clipsToBounds = true
    }
}

extension String
{
    
    /// Generates a `UIImage` instance from this string using a specified
    /// attributes and size.
    ///
    /// - Parameters:
    ///     - attributes: to draw this string with. Default is `nil`.
    ///     - size: of the image to return.
    /// - Returns: a `UIImage` instance from this string using a specified
    /// attributes and size, or `nil` if the operation fails.
    func image(withAttributes attributes: [NSAttributedString.Key: Any]? = nil, size: CGSize? = nil, move: CGPoint) -> UIImage? {
        let size = size ?? (self as NSString).size(withAttributes: attributes)
        return UIGraphicsImageRenderer(size: size).image { _ in
            (self as NSString).draw(in: CGRect(origin: move, size: size),
                                    withAttributes: attributes)
        }
    }
    
    var initials: String {
        let splitName = self.components(separatedBy: .whitespaces)
        var initials = ""
        for name in splitName {
            if let namesFirstLetter = name.first {
                initials += namesFirstLetter.uppercased()
            }
        }
        return initials
    }
    
}

extension UIColor
{
    private static let base: CGFloat = 255.0
    static var twitterBlue: UIColor {
        return UIColor(red: 29 / base, green: 161 / base, blue: 242 / base, alpha: 1)
    }
    
    static var inviteKeyGreen: UIColor {
        return UIColor(red: 50 / base, green: 205 / base, blue: 50 / base, alpha: 1)
    }
    
    static var gold: UIColor {
        return UIColor(red: 219 / base, green: 172 / base, blue: 52 / base, alpha: 1)
    }
    
    static var silver: UIColor {
        return UIColor(red: 170 / base , green: 169 / base, blue: 173 / base, alpha: 1)
    }
    
    static var bronze: UIColor {
        return UIColor(red: 205 / base , green: 127 / base, blue: 50 / base, alpha: 1)
    }
}

extension Logger
{
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let loginController = Logger(subsystem: subsystem, category: "UserInfo")
    
    static let loginViewController = Logger(subsystem: subsystem, category: "LoginViewController")
    
    static let invitationKeySheet = Logger(subsystem: subsystem, category: "InvitationKeySheet")
    
    static let editProfileTableViewController = Logger(subsystem: subsystem, category: "EditProfileTableViewController")
    
    static let mergeAccountsViewController = Logger(subsystem: subsystem, category: "MergeAccountsViewController")
    
    static let apollo = Logger(subsystem: subsystem, category: "Apollo")
    
    static let folderConnection = Logger(subsystem: subsystem, category: "FolderConnection")
    
    static let bookmarkManager = Logger(subsystem: subsystem, category: "BookmarkManager")
}
