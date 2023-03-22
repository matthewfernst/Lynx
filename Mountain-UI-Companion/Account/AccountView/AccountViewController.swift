//
//  ProfileViewController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/22/23.
//

import UIKit
import AWSDynamoDB
import ClientRuntime

enum AllSettingsSections: Int, CaseIterable {
    case profile = 0
    case general = 1
    case support = 2
}

enum GeneralSettinsSections: Int, CaseIterable {
    case app = 0
    case notifications = 1
}

class AccountViewController: UITableViewController, EditProfileDelegate
{
    
    var profile: Profile!
    
    private var generalSettings = Setting.settingOptions
    private var supportSettings = Support.supportOptions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBarController = self.tabBarController as! TabViewController
        self.profile = tabBarController.profile
        
        self.title = "Account"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        tableView.register(MadeWithLoveFooterView.self, forHeaderFooterViewReuseIdentifier: MadeWithLoveFooterView.identifier)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let tabBarController = self.tabBarController as! TabViewController
        tabBarController.profile = self.profile
    }
    
    func editProfileCompletionHandler(profile: Profile) {
        DispatchQueue.main.async {
            let tabBarController = self.tabBarController as! TabViewController
            tabBarController.profile = profile
            self.profile = profile
            self.tableView.reloadData()
        }
    }
    
    // MARK: - UITableViewController Functions
    override func numberOfSections(in tableView: UITableView) -> Int {
        return AllSettingsSections.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch AllSettingsSections(rawValue: section) {
        case .profile:
            return 1
        case .general:
            return generalSettings.count
        case .support:
            return supportSettings.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch AllSettingsSections(rawValue: indexPath.section) {
        case .profile:
            return 88.0
        default:
            return 44.0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch AllSettingsSections(rawValue: indexPath.section) {
        case .profile:
            guard let profileCell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as? ProfileTableViewCell else {
                return UITableViewCell()
            }
            
            profileCell.configure(withProfile: profile)
            
            return profileCell
            
        case .general:
            guard let generalSettingCell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath) as? SettingTableViewCell else {
                return UITableViewCell()
            }
            generalSettingCell.configure(with: generalSettings[indexPath.row])
            return generalSettingCell
            
        case .support:
            guard let supportCell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath) as? SettingTableViewCell else {
                return UITableViewCell()
            }
            supportCell.configure(with: supportSettings[indexPath.row].setting)
            return supportCell
            
        default:
            return UITableViewCell()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch AllSettingsSections(rawValue: section) {
        case .general:
            return "Settings"
        case .support:
            return "Show your support"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch AllSettingsSections(rawValue: section) {
        case .support:
            let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: MadeWithLoveFooterView.identifier) as! MadeWithLoveFooterView
            footer.appVersionLabel.text = "Version 1.0.0"
            footer.madeWithLoveLabel.text = "Made with ❤️+☕️ in San Diego, CA and Seattle, WA"
            return footer
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch AllSettingsSections(rawValue: section) {
        case .support:
            return 100
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch AllSettingsSections(rawValue: indexPath.section) {
        case .profile:
            if let editProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: EditProfileTableViewController.identifier) as? EditProfileTableViewController {
                
                editProfileViewController.profile = self.profile
                editProfileViewController.delegate = self

                self.navigationController?.pushViewController(editProfileViewController, animated: true)
            }
            
        case .general:
            switch GeneralSettinsSections(rawValue: indexPath.row) {
            case .app:
                if let appSettingsViewController = self.storyboard?.instantiateViewController(withIdentifier: AppSettingTableViewController.identitifer) as? AppSettingTableViewController {
                    appSettingsViewController.profile = profile
                    self.navigationController?.pushViewController(appSettingsViewController, animated: true)
                }
                
            case .notifications:
                if let notificationViewController = self.storyboard?.instantiateViewController(withIdentifier: NotificationSettingsTableViewController.identifier) as? NotificationSettingsTableViewController {
                    self.navigationController?.pushViewController(notificationViewController, animated: true)
                }
                
            default:
                return
            }
            
            
        case .support:
            if let url = URL(string: self.supportSettings[indexPath.row].link) {
                UIApplication.shared.open(url)
            }
            
        default:
            break
        }
        
    }
}

