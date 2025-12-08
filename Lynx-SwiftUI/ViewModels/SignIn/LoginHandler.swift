import SwiftUI
import OSLog
import GoogleSignIn

enum ProfileError: Error {
    case profileCreationFailed
}

/// Class for handling the Login of OAuth Clients.
final class LoginHandler {
    
    /// Common sign in for all OAuth clients.
    /// - Parameters:
    ///   - attributes: OAuth attributes of the user.
    ///   - oauthToken: OAuth token for verification.
    ///   - showInvitationSheet: Binding for showing the Invitation Sheet View.
    ///   - showSignInError: Binding for showing signing in error.
    func commonSignIn(
        withOAuthAttributes attributes: ProfileAttributes,
        oauthToken: String,
        showInvitationSheet: Binding<Bool>,
        showSignInError: Binding<Bool>
    ) {
#if DEBUG
        ProfileManager.shared.update(newProfileWith: Profile.debugProfile)
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
                ApolloLynxClient.getProfileInformation { result in
                    switch result {
                    case .success(let profileAttributes):
                        if profileAttributes.validatedInvite {
                            self.loginUser() { result in
                                switch result {
                                case .success(_):
                                    ProfileManager.shared.update(signInWith: true)
                                case .failure(_):
                                    showSignInError.wrappedValue = true
                                }
                            }
                        } else {
                            showInvitationSheet.wrappedValue = true
                        }
                    case .failure(_):
                        showSignInError.wrappedValue = true
                    }
                }

            case .failure:
                showSignInError.wrappedValue = true
            }
        }
#endif
    }
    
    /// Public login call into the App. This is used when logging in through the Invitaiton Sheet or through the normal OAuth flow.
    /// - Parameter completion: A completion handler of the success or failure of creating a profile.
    func loginUser(completion: @escaping (Result<Bool, Error>) -> Void) {
        ApolloLynxClient.getProfileInformation { result in
            switch result {
            case .success(let profileAttributes):
                self.signInUser(
                    profileAttributes: profileAttributes,
                    completion: completion
                )
            case .failure(let error):
                Logger.loginHandler.error("Failed to login user. \(error)")
                completion(.failure(error))
            }
        }
    }
    
    
    /// Private handling of signing in the user. Use profile attributes to update the profile for the user.
    /// - Parameters:
    ///   - profileAttributes: Attributes from the profile information lookup.
    ///   - completion: Success or failure of creating the profile.
    private func signInUser(
        profileAttributes: ProfileAttributes,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        ProfileManager.shared.update(
            newProfileWith: Profile(
                id: profileAttributes.id,
                oauthType: profileAttributes.oauthType,
                firstName: profileAttributes.firstName!,
                lastName: profileAttributes.lastName!,
                email: profileAttributes.email!,
                profilePictureURL: profileAttributes.profilePictureURL
            )
        )
        
        if let _ = ProfileManager.shared.profile {
            completion(.success((true)))
        } else {
            completion(.failure(ProfileError.profileCreationFailed))
        }
    }
    
    /// Static sign out of the user.
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
