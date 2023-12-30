//
//  ProfileManager.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/26/23.
//

import SwiftUI
import SwiftData
import OSLog

@Observable final class ProfileManager {
    var modelContext: ModelContext? = nil {
        didSet {
            if modelContext != nil {
                fetchProfile()
            }
        }
    }
    
    static var shared: ProfileManager = ProfileManager()
    
    private(set) var profile: Profile? {
        didSet {
            if profile != nil {
                downloadProfilePicture(
                    withURL: profile?.profilePictureURL ?? Constants.defaultProfilePictureURL
                )
            }
        }
    }
    
    private(set) var profilePicture: Image?
    
    // MARK: - Intent's
    var isSignedIn: Bool {
        profile?.isSignedIn ?? false
    }
    
    var measurementSystem: MeasurementSystem {
        profile?.measurementSystem ?? .imperial
    }
    
    func fetchProfile() {
        let fetchDescriptor = FetchDescriptor<Profile>()
        profile = try? modelContext?.fetch(fetchDescriptor).first
    }
    
    func edit(newFirstName: String, newLastName: String, newEmail: String) {
        profile?.edit(
            newFirstName: newFirstName,
            newLastName: newLastName,
            newEmail: newEmail
        )
        saveProfile()
    }
    
    func update(loginWith loggedIn: Bool) {
        if let profile {
            profile.isSignedIn = loggedIn
        }
    }
    
    func update(newProfileWith newProfile: Profile) {
        deleteProfile()
        modelContext?.insert(newProfile)
        fetchProfile()
    }
    
    func update(newProfilePictureURLWith newURL: URL) {
        profile?.profilePictureURL = newURL
        downloadProfilePicture(withURL: newURL)
    }
    
    func update(measurementSystemWith newSystem: MeasurementSystem) {
        profile?.measurementSystem = newSystem
    }
    
    func update(notifcationsAllowedWith allowed: Bool) {
        profile?.notificationsAllowed = allowed
    }
    
    func deleteProfile() {
        if let profile {
            modelContext?.delete(profile)
            Logger.profileManager.info("Successfully deleted profile.")
        }
        profile = nil
    }
    
    func saveProfile() {
        do {            
            try modelContext?.save()
            Logger.profileManager.debug("Successfully saved profile.")
        } catch {
            // Handle the error appropriately (e.g., print or log it)
            Logger.profileManager.error("Error saving changes: \(error)")
        }
    }
    
    // MARK: - Helpers
    private func downloadProfilePicture(withURL url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let uiImage = UIImage(data: data) {
                // Convert the downloaded data to an Image
                let image = Image(uiImage: uiImage)
                
                // Update the profilePicture property on the main thread
                Task { @MainActor in
                    self.profilePicture = image
                }
            }
        }.resume()
    }
    
    struct Constants {
        static let defaultProfilePictureURL = URL(string: "https://thumbs.dreamstime.com/b/european-teenager-beanie-profile-portrait-male-cartoon-character-blonde-man-avatar-social-network-vector-flat-271205345.jpg")!
    }
}
