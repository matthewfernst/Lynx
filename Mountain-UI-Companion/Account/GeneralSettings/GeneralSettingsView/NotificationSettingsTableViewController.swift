//
//  NotificationTableViewController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/25/23.
//

import UIKit

class NotificationSettingsTableViewController: UITableViewController
{
    static var identifier = "NotificationSettingsTableView"
    var notificationSwitch: UISwitch!
    
    var profile: Profile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Notifications"
        
        createNotificationSwitch()
        
        // save switch based on profile.
        updateNotificationSwitch(switchIsOn: profile.notificationsAllowed)
    }

    func createNotificationSwitch() {
        notificationSwitch = UISwitch()
        notificationSwitch.sizeToFit()
        notificationSwitch.addTarget(self, action: #selector(notificationSwitchChanged), for: .valueChanged)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func updateNotificationSwitch(switchIsOn: Bool) {
        profile.notificationsAllowed = switchIsOn
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationSwitch.isOn = switchIsOn
                self.notificationSwitch.isEnabled = (settings.authorizationStatus != .denied)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath)
        var configuration = cell.defaultContentConfiguration()
        
        configuration.text = "Allow Notifications"
        
        cell.accessoryView = notificationSwitch
        cell.backgroundColor = .secondarySystemBackground
        cell.contentConfiguration = configuration
        cell.selectionStyle = .none
        
        return cell
    }
    
    @objc func notificationSwitchChanged(_ sender: UISwitch) {
        let center = UNUserNotificationCenter.current()
        if sender.isOn {
            center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if let error = error {
                    print("Error requesting notification authorization: \(error.localizedDescription)")
                } else if granted {
                    print("User granted notification authorization")
                } else {
                    print("User denied notification authorization")
                }
                print("Turning on notifications")
                self.updateNotificationSwitch(switchIsOn: true)
            }
        } else {
            center.removeAllPendingNotificationRequests() // remove pending notifications when switch is turned off
            self.updateNotificationSwitch(switchIsOn: false)
        }
    }
}
