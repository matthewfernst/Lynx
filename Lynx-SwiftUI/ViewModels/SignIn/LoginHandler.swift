//
//  LoginHandler.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/25/23.
//

import SwiftUI
import OSLog
import GoogleSignIn

enum ProfileError: Error {
    case profileCreationFailed
}

class LoginHandler {
    func commonSignIn(
        profileManager: ProfileManager,
        withProfileAttributes attributes: ProfileAttributes,
        oauthToken: String,
        showInvitationSheet: Binding<Bool>,
        showSignInError: Binding<Bool>
    ) {
        
#if DEBUG
        profileManager.update(newProfileWith: Profile.debugProfile)
#else
        ApolloLynxClient.oauthSignIn(
            id: attributes.id,
            oauthType: attributes.oauthType,
            oauthToken: oauthToken,
            email: attributes.email,
            firstName: attributes.firstName,
            lastName: attributes.lastName,
            profilePictureURL: attributes.profilePictureURL
        ) { result in
            switch result {
            case .success(_):
                Logger.loginHandler.info("Authorization Token successfully received.")
                ApolloLynxClient.hasValidatedInviteKey { keyResult in
                    switch keyResult {
                    case .success(let validatedInvite):
                        if validatedInvite {
                            self.loginUser(profileManager: profileManager) { result in
                                switch result {
                                case .success(_):
                                    profileManager.update(signInWith: true)
                                case .failure(_):
                                    showSignInError.wrappedValue = true
                                }
                            }
                        } else { // Show Invitation Sheet
                            showInvitationSheet.wrappedValue = true
                        }
                    case .failure(_):
                        // TODO: Say fail of querying?
                        showSignInError.wrappedValue = true
                    }
                }

            case .failure:
                showSignInError.wrappedValue = true
            }
        }
        
#endif
    }
    
    func loginUser(
        profileManager: ProfileManager,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        ApolloLynxClient.getProfileInformation { result in
            switch result {
            case .success(let profileAttributes):
                self.signInUser(
                    profileManager: profileManager,
                    profileAttributes: profileAttributes,
                    completion: completion
                )
            case .failure(let error):
                Logger.loginHandler.error("Failed to login user. \(error)")
                completion(.failure(error))
            }
        }
    }
    
    
    private func signInUser(
        profileManager: ProfileManager,
        profileAttributes: ProfileAttributes,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        profileManager.update(
            newProfileWith: Profile(
                id: profileAttributes.id,
                oauthType: profileAttributes.oauthType,
                firstName: profileAttributes.firstName!,
                lastName: profileAttributes.lastName!,
                email: profileAttributes.email!,
                profilePictureURL: profileAttributes.profilePictureURL
            )
        )
        
        
        if let _ = profileManager.profile {
            completion(.success((true)))
        } else {
            completion(.failure(ProfileError.profileCreationFailed))
        }
    }
    
    static func signOut() {
        UserManager.shared.lynxToken = nil
        if ProfileManager.shared.profile?.oauthType == OAuthType.google.rawValue {
            GIDSignIn.sharedInstance.signOut()
        }
        ApolloLynxClient.clearCache()
        BookmarkManager.shared.removeAllBookmarks()
        ProfileManager.shared.update(signInWith: false) // Keychain clean up deletes profile 🤷‍♂️
    }
}
