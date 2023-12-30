//
//  AppleSignInHandler.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/11/23.
//

import Foundation
import AuthenticationServices
import SwiftUI
import OSLog

class AppleSignInHandler {
    
    func onCompletion(
        _ result: Result<ASAuthorization,
        Error>,
        showErrorSigningIn: Binding<Bool>,
        completion: @escaping (ProfileAttributes,
        String) -> Void
    ) {
#if DEBUG
        completion(
            ProfileAttributes( id: "123456", oauthType: OAuthType.apple.rawValue), "1234"
        )
#endif
        switch result {
        case .success(let authorization):
            switch authorization.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                guard let appleJWT = String(data: appleIDCredential.identityToken!, encoding: .utf8) else {
                    Logger.appleSignInHandler.error("Unable to get Apple ID JWT.")
                    showErrorSigningIn.wrappedValue = true
                    return
                }
                
                Logger.appleSignInHandler.info("Successfully authorized Apple ID credentials.")
                completion(
                    .init(
                        id: appleIDCredential.user,
                        oauthType: OAuthType.apple.rawValue,
                        email: appleIDCredential.email,
                        firstName: appleIDCredential.fullName?.givenName,
                        lastName: appleIDCredential.fullName?.familyName
                    ),
                    appleJWT
                )
                
            default:
                showErrorSigningIn.wrappedValue = true
                Logger.appleSignInHandler.error("Failed to authorize Apple ID Credential.")
            }
        case .failure(let error):
            showErrorSigningIn.wrappedValue = true
            Logger.appleSignInHandler.error("Failed to authorize request: \(error)")
        }
    }
}
