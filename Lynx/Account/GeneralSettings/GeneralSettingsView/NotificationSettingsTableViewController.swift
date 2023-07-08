//
//  NotificationTableViewController.swift
//  Lynx
//
//  Created by Matthew Ernst on 1/25/23.
//

import UIKit

class NotificationSettingsTableViewController: UITableViewController
{
    static var identifier = "NotificationSettingsTableView"
    var notificationSwitch: UISwitch!
    
    var profile: Profile!
    
    private var notificationsNotAllowedFooter: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Notifications"
        
        createNotificationSwitch()
        
        updateNotificationSwitch(switchIsOn: UserDefaults.standard.bool(forKey: UserDefaultsKeys.notificationsTurnedOnOrOff))
        
        getNotificationSettings { [weak self] allowed in
            DispatchQueue.main.async {
                self?.notificationsNotAllowedFooter = allowed ? nil : "Your current settings do not allow this app to send notifications. If you would like to turn them on, please go to iPhone Settings."
                self?.tableView.reloadData()
            }
        }
    }
    
    private func getNotificationSettings(completion: @escaping (_ allowed: Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .denied {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func createNotificationSwitch() {
        notificationSwitch = UISwitch()
        notificationSwitch.sizeToFit()
        notificationSwitch.addTarget(self, action: #selector(notificationSwitchChanged), for: .valueChanged)
    }
    
    @objc private func notificationSwitchChanged(_ sender: UISwitch) {
        let center = UNUserNotificationCenter.current()
        if sender.isOn {
            center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if let error = error {
                    print("Error requesting notification authorization: \(error.localizedDescription)")
                } else if granted {
                    print("User granted notification authorization")
                    self.updateNotificationSwitch(switchIsOn: true)
                } else {
                    print("User denied notification authorization")
                }
            }
        } else {
            center.removeAllPendingNotificationRequests() // remove pending notifications when switch is turned off
            self.updateNotificationSwitch(switchIsOn: false)
        }
    }
    
    private func updateNotificationSwitch(switchIsOn: Bool) {
        profile.notificationsAllowed = switchIsOn
        UserDefaults.standard.set(switchIsOn, forKey: UserDefaultsKeys.notificationsTurnedOnOrOff)
        
        getNotificationSettings { [weak self] allowed in
            DispatchQueue.main.async {
                self?.notificationSwitch.isOn = switchIsOn
                self?.notificationSwitch.isEnabled = allowed
            }
        }
    }
    
    // MARK: - TableViewController
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footerText = notificationsNotAllowedFooter else { return nil }
        
        let attributedText = NSMutableAttributedString(string: footerText)
        let range = (footerText as NSString).range(of: "Settings.")
        
        attributedText.addAttributes([
            .font: UIFont.preferredFont(forTextStyle: .footnote),
            .foregroundColor: UIColor.secondaryLabel,
            ],
                                     range: NSRange(location: 0, length: attributedText.length))
        attributedText.addAttribute(.link, value: URL(string: UIApplication.openSettingsURLString)!, range: range)
        attributedText.addAttribute(.foregroundColor, value: UIColor.blue, range: range)
    
        let label = UILabel()
        label.numberOfLines = 4
        label.attributedText = attributedText
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openSettings)))
        
        return label
    }

    @objc private func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
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
}
