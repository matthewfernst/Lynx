//
//  InvitationKeyHandler.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 1/5/24.
//

import SwiftUI
import OSLog

@Observable class InvitationKeyHandler {
    var key = ""
    
    func submitKey(completion: @escaping (Bool) -> Void) {
        guard !key.isEmpty else { return }
        
        if keyLengthEqualToInputLength {
            ApolloLynxClient.submitInviteKey(with: key) { result in
                switch result {
                case .success(_):
                    Logger.invitationKeyHandler.info("Invitation successfully validated.")
                    completion(true)
                case .failure(_):
                    Logger.invitationKeyHandler.error("Invitation failed to validate.")
                    completion(false)
                }
            }
        }
        
        // If the user pastes in a code, we truncate the string to the first inputLength characters
        if key.count > Constants.inputLength {
            key = String(key.prefix(Constants.inputLength))
            submitKey(completion: completion)
        }
    }
    
    func getDigit(forKeyIndex index: Int) -> String? {
        if !key.isEmpty,
           let currentIndex = key.index(key.startIndex, offsetBy: index, limitedBy: key.index(before: key.endIndex)) {
            return String(key[currentIndex])
        }
        return nil
    }
    
    var keyLengthEqualToInputLength: Bool {
        withAnimation {
            key.count == Constants.inputLength
        }
    }
    
    func resetKey() {
        key = ""
    }
    
    struct Constants {
        static let inputLength: Int = 6
    }
}
