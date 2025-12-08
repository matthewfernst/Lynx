import Foundation
import SwiftUI
import GoogleSignIn

final class GoogleSignInHandler {
    
    func signIn(
        isSigningIn: Binding<Bool>,
        showErrorSigningIn: Binding<Bool>,
        completion: @escaping (ProfileAttributes, String) -> Void
    ) {
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
                guard error == nil else {
                    let err = error as? NSError
                    if err!.domain == kGIDSignInErrorDomain && err!.code == -5 {
                        isSigningIn.wrappedValue = false
                    } else {
                        showErrorSigningIn.wrappedValue = true
                    }
                    return
                }
                
                guard let googleId = signInResult?.user.userID,
                      let profile = signInResult?.user.profile,
                      let oauthToken = signInResult?.user.idToken?.tokenString else {
                    showErrorSigningIn.wrappedValue = true
                    return
                }
                
                let name = profile.name.components(separatedBy: " ")
                let (firstName, lastName) = (name[0], name[1])
                let email = profile.email
                
                var pictureURL: URL? = nil
                if let urlString = profile.imageURL(withDimension: 320)?.absoluteString {
                    pictureURL = URL(string: urlString)
                }
                
                completion(
                    ProfileAttributes(
                        id: googleId,
                        oauthType: OAuthType.google.rawValue,
                        validatedInvite: true, // TODO: - FIX ME
                        email: email,
                        firstName: firstName,
                        lastName: lastName,
                        profilePictureURL: pictureURL
                    ),
                    oauthToken
                )
            }
        }
    }
}
