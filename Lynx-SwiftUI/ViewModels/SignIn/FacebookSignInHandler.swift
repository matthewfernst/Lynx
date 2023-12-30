//
//  FacebookSignInHandler.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/29/23.
//

import Foundation
import SwiftUI
import FacebookLogin
import OSLog
import FBSDKCoreKit_Basics

class FacebookSignInHandler {
    private var fbLoginManager = LoginManager()
    
    func signIn(
        isSigningIn: Binding<Bool>,
        showErrorSigningIn: Binding<Bool>,
        completion: @escaping (ProfileAttributes, String) -> Void
    ) {
        fbLoginManager.logIn(
            permissions: ["public_profile", "email", ],
            from: nil
        ) { result, error in
            if error != nil {
                showErrorSigningIn.wrappedValue = true
                Logger.facebookSignInHandler.error("Error login in with Facebook: \(error)")
                return
            }
            
            let request = GraphRequest(
                graphPath: "me",
                parameters: ["fields": "id, first_name, last_name, email, picture.width(320).height(320)"]
            )
            
            if !result!.isCancelled {
                request.start { _, res, _ in
                    guard let profileInfo = res as? [String : Any] else {
                        showErrorSigningIn.wrappedValue = true
                        Logger.facebookSignInHandler.error("Error login in with Facebook. Unable to get profile data.")
                        return
                    }
                    var profilePictureURL: URL? = nil
                    if let profilePictureURLString = ((profileInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                        profilePictureURL = URL(string: profilePictureURLString)
                    }
                    completion(
                        ProfileAttributes(
                            id: profileInfo["id"] as! String,
                            oauthType: OAuthType.facebook.rawValue,
                            email: profileInfo["email"] as? String,
                            firstName: profileInfo["first_name"] as? String,
                            lastName: profileInfo["last_name"] as? String,
                            profilePictureURL: profilePictureURL
                        ), AccessToken.current!.tokenString
                    )
                }
            } else {
                isSigningIn.wrappedValue = false
            }
        }
    }
}

