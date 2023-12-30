//
//  EditProfileHandler.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/1/23.
//

import SwiftUI
import PhotosUI
import OSLog

class EditProfileHandler {
    
    func saveEdits(
        profileManager: ProfileManager,
        withFirstName firstName: String,
        lastName: String,
        email: String,
        profilePictureData: Data? = nil,
        completion: @escaping () -> Void
    ) {
        profileManager.edit(
            newFirstName: firstName,
            newLastName: lastName,
            newEmail: email
        )
#if DEBUG
        completion()
#else
        var profileChanges: [String: Any] = [:]
        profileChanges[ProfileChangesKeys.firstName.rawValue]  = firstName
        profileChanges[ProfileChangesKeys.lastName.rawValue] = lastName
        profileChanges[ProfileChangesKeys.email.rawValue] = email
        
        var waitForPicturePropogate = false
        if let profilePictureData {
            putRequest(newProfilePictureData: profilePictureData)
            waitForPicturePropogate = true
        }
        
        ApolloLynxClient.editUser(profileChanges: profileChanges) { result in
            switch result {
            case .success(let newProfilePictureURL):
                Logger.editProfileHandler.info("Retrieved new profile picture URL: \(newProfilePictureURL)")
                if let newURL = URL(string: newProfilePictureURL) {
                    // Poll profile pic until it's different or time limit is up
                    if waitForPicturePropogate {
                        self.pollProfilePictureChange(
                            profileManager: profileManager,
                            newProfilePictureData: profilePictureData!,
                            newProfilePictureURL: newURL,
                            completion: completion
                        )
                    } else {
                        completion()
                    }
                }
            case .failure(_):
                Logger.editProfileHandler.error("Failed to get new profile picture URL. Using old picture.")
                completion() // Dismiss view and stops ProgressView
            }
        }
#endif
    }
    
    private func putRequest(newProfilePictureData data: Data) {
        Task {
            ApolloLynxClient.createUserProfilePictureUploadUrl { result in
                switch result {
                case .success(let url):
                    Logger.editProfileHandler.info("Successfully retrieved new URL: \(url)")
                    guard let url = URL(string: url) else {
                        Logger.editProfileHandler.error("Failed to convert String URL into URL coming back from createUserProfilePictureUploadURL")
                        return
                    }
                    
                    var request = URLRequest(url: url)
                    request.httpMethod = "PUT"
                    
                    // Set the content type for the request
                    let contentType = "image/jpeg"
                    request.setValue(contentType, forHTTPHeaderField: "Content-Type")
                    
                    request.httpBody = data
                    URLSession.shared.reset { [request] in
                        URLSession.shared.dataTask(with: request) { data, response, error in
                            if let error = error {
                                Logger.editProfileHandler.error("Failed to upload new profile picture to S3: \(error)")
                                return
                            }
                            
                            if let response = response as? HTTPURLResponse {
                                Logger.editProfileHandler.info("Response status code: \(response.statusCode)")
                            }
                        }.resume()
                    }
                case .failure(_):
                    Logger.editProfileHandler.error("Failed to retrieve URL.")
                }
            }
        }
    }
    
    private func pollProfilePictureChange(
        profileManager: ProfileManager,
        newProfilePictureData newData: Data,
        newProfilePictureURL: URL,
        completion: @escaping () -> Void
    ) {
        let pollInterval: TimeInterval = 2.0
        let maxAttempts = 10
        
        var attempts = 0
        
        // Start the polling loop
        func poll() {
            Logger.editProfileHandler.error("Polling attempt #\(attempts)")
            // Check if the profile picture has changed
            getDataAsync(from: newProfilePictureURL) { currentData in
                if newData == currentData {
                    DispatchQueue.main.async {
                        profileManager.update(newProfilePictureURLWith: newProfilePictureURL)
                        completion() // Dismiss view and stop ProgressView
                    }
                } else {
                    // Profile picture hasn't changed yet
                    if attempts < maxAttempts {
                        // Schedule the next poll
                        DispatchQueue.main.asyncAfter(deadline: .now() + pollInterval) {
                            attempts += 1
                            poll()
                        }
                    } else {
                        // Maximum attempts reached, stop polling
                        DispatchQueue.main.async {
                            profileManager.update(newProfilePictureURLWith: newProfilePictureURL)
                            completion()
                        }
                    }
                }
            }
        }
        
        // Initial poll
        poll()
    }
    
    private func getDataAsync(from url: URL, completion: @escaping (Data?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil, let data = data else {
                print("Error fetching data from URL: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            completion(data)
        }
        task.resume()
    }
    
    
    func deleteAccount(
        profileManager: ProfileManager,
        completion: @escaping ((Result<Void,
                                Error>) -> Void)
    ) {
//        ApolloLynxClient.deleteAccount(
//            token: profileManager.profile!.oauthToken,
//            type: .init(rawValue: profileManager.profile!.oauthType)!,
//            completion: completion
//        )
    }
}

enum ProfileChangesKeys: String {
    case firstName = "firstName"
    case lastName = "lastName"
    case email = "email"
}

