import SwiftUI
import SwiftData
import OSLog

struct HomeView: View {
    @Environment(\.colorScheme) private var systemTheme
    @Environment(ProfileManager.self) private var profileManager
    
    @State private var folderConnectionHandler = FolderConnectionHandler()
    @State private var logbookStats = LogbookStats()
        
    var body: some View {
        TabView {
            LogbookView(
                folderConnectionHandler: folderConnectionHandler,
                logbookStats: logbookStats
            )
            .tabItem {
                Label("Logbook", systemImage: "book.pages")
            }

            PartyView()
                .tabItem {
                    Label("Parties", systemImage: "person.3.fill")
                }
        }
        .onAppear {
            scheduleNotificationsForRemindingToUpload()
        }
    }
    
    // MARK: - Notifications
    private func registerLocal() {
        // request permission
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                profileManager.update(notifcationsAllowedWith: granted)
            }
            if granted {
                Logger.homeView.debug("Notifications granted")
            } else {
                Logger.homeView.debug("User has defined notificaitons")
            }
        }
    }
    
    private func scheduleNotificationsForRemindingToUpload() {
        registerLocal()
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "It's been a minute"
        content.body = "Just a little reminder to come back and upload any new files."
        content.categoryIdentifier = "recall"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 2
        dateComponents.month = 1
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request)
    }
}

#Preview {
    HomeView()
}
