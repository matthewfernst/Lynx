//
//  Lynx_SwiftUIApp.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/24/23.
//

import SwiftUI
import SwiftData
import GoogleSignIn
import FBSDKLoginKit
@main
struct Lynx_SwiftUIApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var profileManager = ProfileManager.shared
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            Group {
                if profileManager.isSignedIn {
                    HomeView()
                } else {
                    LoginView()
                }
            }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
        .modelContainer(for: Profile.self) { result in
            switch result {
            case .success(let container):
                profileManager.modelContext = container.mainContext
            case .failure(let error):
                print("Failed in setup of model container: \(error)")
            }
        }
        .environment(profileManager)
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                // Save profile if the app goes in the background
                profileManager.saveProfile()
            }
        }
    }
}
