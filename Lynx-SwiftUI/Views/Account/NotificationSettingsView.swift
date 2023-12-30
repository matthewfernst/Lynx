//
//  NotificationSettingsView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/29/23.
//

import SwiftUI
import OSLog

struct NotificationSettingsView: View {
    @State private var allowNotifications = false
    @State private var showDeniedAlert = false

    var body: some View {
        Form {
            Section {
                Toggle("Allow Notifications", isOn: $allowNotifications)
                    .onChange(of: allowNotifications) { _, newValue in
                        updateNotificationSettings(allow: newValue)
                    }
            } footer: {
                Text("Notifications sent from this app are to remind users to come back to upload potential new files.")
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            checkNotificationSettings()
        }
        .alert(isPresented: $showDeniedAlert) {
            Alert(
                title: Text("Notifications Denied"),
                message: Text("Please enable notifications for this app in your device settings."),
                primaryButton: .default(Text("Settings"), action: openSettings),
                secondaryButton: .cancel()
            )
            
        }
    }

    private func checkNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                allowNotifications = settings.authorizationStatus == .authorized
            }
        }
    }

    private func updateNotificationSettings(allow: Bool) {
        let center = UNUserNotificationCenter.current()

        if allow {
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("Error requesting notification authorization: \(error.localizedDescription)")
                } else if granted {
                    print("Notification authorization granted")
                } else {
                    print("Notification authorization denied")
                    showDeniedAlert = true
                    allowNotifications = false
                }
            }
        } else {
            center.removeAllPendingNotificationRequests()
            center.removeAllDeliveredNotifications()
        }
    }

    private func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
    }
}

#Preview {
    NotificationSettingsView()
}
