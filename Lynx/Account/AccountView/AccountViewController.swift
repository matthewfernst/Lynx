//
//  ProfileViewController.swift
//  Lynx
//
//  Created by Matthew Ernst on 1/22/23.
//

import UIKit
import MessageUI

enum AllSettingsSections: Int, CaseIterable
{
    case profile = 0
    case general = 1
    case inviteKey = 2
    case support = 3
    case contactDevelopers = 4
}

enum GeneralSettinsSections: Int, CaseIterable
{
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
        
        self.profile = TabViewController.profile
        
        self.title = "Account"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        tableView.register(MadeWithLoveFooterView.self, forHeaderFooterViewReuseIdentifier: MadeWithLoveFooterView.identifier)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        TabViewController.profile = self.profile
    }
    
    func editProfileCompletionHandler(profile: Profile) {
        DispatchQueue.main.async {
            TabViewController.profile = profile
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
        case .inviteKey:
            return 1
        case .support:
            return supportSettings.count
        case .contactDevelopers:
            return 1
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
            
        case .inviteKey:
            guard let inviteKeyCell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath) as? SettingTableViewCell else {
                return UITableViewCell()
            }
            
            inviteKeyCell.configure(with: Setting.inviteKeySetting)
            
            return inviteKeyCell
            
        case .support:
            guard let supportCell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath) as? SettingTableViewCell else {
                return UITableViewCell()
            }
            supportCell.configure(with: supportSettings[indexPath.row].setting)
            return supportCell
            
        case .contactDevelopers:
            guard let contactDevelopers = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath) as? SettingTableViewCell else {
                return UITableViewCell()
            }
            
            contactDevelopers.configure(with: Setting.contactDevelopers)
            return contactDevelopers
            
        default:
            return UITableViewCell()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch AllSettingsSections(rawValue: section) {
        case .general:
            return "Settings"
        case .inviteKey:
            return "Invitation key"
        case .support:
            return "Show your support"
        case .contactDevelopers:
            return "Found an Issue or Need Help?"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch AllSettingsSections(rawValue: section) {
        case .contactDevelopers:
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
        case .contactDevelopers:
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
                if let appSettingsViewController = self.storyboard?.instantiateViewController(withIdentifier: AppSettingTableViewController.identifier) as? AppSettingTableViewController {
                    appSettingsViewController.profile = profile
                    self.navigationController?.pushViewController(appSettingsViewController, animated: true)
                }
                
            case .notifications:
                if let notificationViewController = self.storyboard?.instantiateViewController(withIdentifier: NotificationSettingsTableViewController.identifier) as? NotificationSettingsTableViewController {
                    notificationViewController.profile = profile
                    self.navigationController?.pushViewController(notificationViewController, animated: true)
                }
                
            default:
                return
            }
            
            
        case .inviteKey:
            ApolloLynxClient.createInviteKey { [weak self] result in
                switch result {
                case .success(let inviteKey):
                    
                    guard let firstName = self?.profile.firstName else {
                        return
                    }
                    
                    guard let lastName = self?.profile.lastName else {
                        return
                    }
                    
                    let message = """
                                  \(firstName) \(lastName) has shared an invitation key to Lynx. Open the app and enter the key below. This invitation key will expire in 24 hours.
                                  
                                  Invitation Key: \(inviteKey)
                                  """
                    
                    if MFMessageComposeViewController.canSendText() {
                        let messageController = MFMessageComposeViewController()
                        messageController.body = message
                        messageController.messageComposeDelegate = self
                        self?.present(messageController, animated: true, completion: nil)
                    } else {
                        let ac = UIAlertController(title: "Failed to Open Messages", message: "We were unable to open the Messages app. Please try again or copy the invitation key.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "Copy Invitation Key", style: .default) {_ in
                            let pasteboard = UIPasteboard.general
                            pasteboard.string = message
                        })
                        ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                        self?.present(ac, animated: true)
                    }
                    
                case .failure(_):
                    let ac = UIAlertController(title: "Failed to Create Invite Key", message: "Our systems were not able to create an invite key. Please try again.", preferredStyle: .alert)
                    
                    ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                    self?.present(ac, animated: true)
                }
            }
        case .support:
            if let url = URL(string: self.supportSettings[indexPath.row].link) {
                UIApplication.shared.open(url)
            }
            
        case .contactDevelopers:
            let body = """
               Hello,
               
               I would like to report a bug in the app. Here are the details:
               
               - App Version: [App Version]
               - Device: [Device Model]
               - iOS Version: [iOS Version]
               
               Bug Description:
               [Describe the bug you encountered]
               
               Steps to Reproduce:
               [Provide steps to reproduce the bug]
               
               Expected Behavior:
               [Describe what you expected to happen]
               
               Actual Behavior:
               [Describe what actually happened]
               
               Additional Information:
               [Provide any additional relevant information]
               
               Thank you for your attention to this matter.
               
               Regards,
               [Your Name]
               """
            if MFMailComposeViewController.canSendMail() {
                let composer = MFMailComposeViewController()
                composer.mailComposeDelegate = self
                composer.setToRecipients([Constants.contactEmail])
                composer.setSubject("Lynx Bug Report: [Brief Description]")
                
                composer.setMessageBody(body, isHTML: false)
                
                self.present(composer, animated: true)
            } else {
                let ac = UIAlertController(title: "Failed to Open Mail", message: "We were unable to open the Mail app. Please send an email to \(Constants.contactEmail). You can copy the bug report template below.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Copy Bug Report Template", style: .default) {_ in
                    UIPasteboard.general.string = body
                })
                ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                self.present(ac, animated: true)
            }
            
        default:
            break
        }
        
    }
}


extension AccountViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension AccountViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
