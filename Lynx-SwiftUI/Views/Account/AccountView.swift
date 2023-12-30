//
//  AccountView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/24/23.
//

import SwiftUI
import MessageUI

struct AccountView: View {
    @Environment(ProfileManager.self) private var profileManager
    @State private var refreshView = false

    @State private var showMessagesNotAvailable = false
    @State private var messagesAlertBody = ""
    @State private var copyMessageText = ""
    private let messageComposeDelegate = MessageDelegate()

    @State private var showMailNotAvailable = false
    private let mailComposeDelegate = MailDelegate()
    
    var body: some View {
        NavigationStack {
            Form {
                profileInformation
                settings
                shareInvitationKey
                showYourSupport
                contactDevelopers
            }
            .navigationTitle("Account")
            
            .alert("Failed to Open Mail", isPresented: $showMailNotAvailable) {
                Button("Copy Bug Report Template") {
                    UIPasteboard.general.string = Constants.Mail.bugReportTemplate
                }
                Button("Dismiss") {
                    showMailNotAvailable = false
                }
            } message: {
                Text("We were unable to open the Mail app. Please send an email to \(Constants.Mail.developerContactEmail). You can copy the bug report template below.")
            }
            
            .alert("Failed to Open Messages", isPresented: $showMessagesNotAvailable) {
                Button("Copy Invite Key") {
                    UIPasteboard.general.string = copyMessageText
                }
                Button("Dismiss") {
                    showMessagesNotAvailable = false
                }
            } message: {
                Text(messagesAlertBody)
            }
        }
    }
    
    private var profileInformation: some View {
        NavigationLink(destination: EditProfileView(profileManager: profileManager)) {
                if let profilePic = profileManager.profilePicture {
                    profilePic
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(
                            width: Constants.ProfileInformation.imageWidthHeight,
                            height: Constants.ProfileInformation.imageWidthHeight
                        )
                } else {
                    ProgressView()
                        .padding()
                }
                VStack(alignment: .leading) {
                    Text(profileManager.profile!.name)
                        .font(.title2)
                    Text("Edit Account & Profile")
                        .font(.caption)
                }
                .padding(.horizontal)
        }
    }
    
    private var settings: some View {
        Section {
            NavigationLink(destination: GeneralSettingsView()) {
                cell(withIconColor: .gray, andText: "General") {
                    iconView(withSystemImageName: "gear")
                }
            }
            
            NavigationLink(destination: NotificationSettingsView()) {
                cell(withIconColor: .red, andText: "Notifications") {
                    iconView(withSystemImageName: "bell.badge.fill")
                }
            }
        } header: {
            Text("Settings")
        }
    }
    
    private var shareInvitationKey: some View {
        Section {
            Button {
                presentMessageCompose()
            } label: {
                cell(withIconColor: .green, andText: "Share Invitation Key") {
                    iconView(withSystemImageName: "person.badge.key.fill")
                }
            }
        } header: {
            Text("Invitation Key")
        }
    }
    
    private var showYourSupport: some View {
        Section {
            Group {
                Link(destination: Constants.Links.gitHubURL) {
                    cell(withIconColor: .black, andText: "GitHub") {
                        iconView(withAssetImageName: "GitHubIcon")
                    }
                }
                
                
                Link(destination: Constants.Links.twitterURL) {
                    cell(withIconColor: .blue, andText: "Twitter") {
                        iconView(withAssetImageName: "TwitterIcon")
                    }
                }
                
            }
        } header: {
            Text("Show your support")
        }
        
    }
    
    private var contactDevelopers: some View {
        Section {
            Button {
                presentMailCompose()
            } label: {
                cell(withIconColor: .purple, andText: "Contact Developers") {
                    iconView(withSystemImageName: "paperplane.fill")
                }
            }
        } header: {
            Text("Found an issue or need help?")
        } footer: {
            HStack {
                Spacer()
                VStack(alignment: .center) {
                    Text("Made with ❤️ + ☕️ in San Diego, CA and Seattle, WA")
                    if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        Text("Version \(appVersion)")
                    }
                }
                .multilineTextAlignment(.center)
                .font(.system(size: Constants.Fonts.footerSize))
                .padding(.top, Constants.Fonts.footerPadding)
                
                Spacer()
            }
            
        }
        .onTapGesture {
            presentMailCompose()
        }
    }
    
    private func cell(
        withIconColor color: Color,
        andText text: String,
        iconView: () -> some View
    ) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: Constants.Cell.cornerRadius)
                .frame(
                    width: Constants.Cell.systemImageWidth,
                    height: Constants.Cell.systemImageHeight
                )
                .foregroundStyle(color)
                .overlay {
                    iconView()
                }
            
            Text(text)
                .padding(.horizontal, Constants.Cell.textToIconPadding)
        }
    }
    
    private func iconView(withSystemImageName name: String) -> some View {
        Image(systemName: name)
            .frame(
                width: Constants.Cell.systemImageWidth,
                height: Constants.Cell.systemImageWidth
            )
            .foregroundStyle(.white)
    }
    
    @ViewBuilder
    private func iconView(withAssetImageName name: String) -> some View {
        let widthAndHeight: CGFloat = (
            name == "TwitterIcon" ? Constants.Cell.twitterWidthAndHeight : Constants.Cell.gitHubWidthAndHeight
        )
        Image(name)
            .resizable()
            .frame(
                width: widthAndHeight,
                height: widthAndHeight
            )
    }
    
    private struct Constants {
        struct ProfileInformation {
            static let imageWidthHeight: CGFloat = 70
        }
        
        struct Fonts {
            static let footerSize: CGFloat = 11
            static let footerPadding: CGFloat = 25
        }
        
        struct Links {
            static let gitHubURL = URL(string: "https://www.github.com/matthewfernst")!
            static let twitterURL = URL(string: "https://twitter.com/ErnstMatthew")!
        }
        
        struct Cell {
            static let cornerRadius: CGFloat = 8
            static let systemImageWidth: CGFloat = 28
            static let systemImageHeight: CGFloat = 28
            
            static let textToIconPadding: CGFloat = 5
            
            static let gitHubWidthAndHeight: CGFloat = 25
            static let twitterWidthAndHeight: CGFloat = 20
        }
        
        struct Mail {
            static let developerContactEmail = "matthew.f.ernst@icloud.com"
            static let bugReportTemplate = """
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
        }
    }
}


// MARK: - Mail https://medium.com/@florentmorin/messageui-swiftui-and-uikit-integration-82d91159b0bd
extension AccountView {
    
    /// Delegate for view controller as `MFMailComposeViewControllerDelegate`
    private class MailDelegate: NSObject, MFMailComposeViewControllerDelegate {
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            controller.dismiss(animated: true)
        }
        
    }
    
    /// Present an mail compose view controller modally in UIKit environment
    private func presentMailCompose() {
        guard MFMailComposeViewController.canSendMail() else {
            showMailNotAvailable = true
            return
        }
        
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        let vc = window?.rootViewController
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = mailComposeDelegate
        
        composeVC.setToRecipients([Constants.Mail.developerContactEmail])
        composeVC.setSubject("Lynx Bug Report: [Brief Description]")
        composeVC.setMessageBody(Constants.Mail.bugReportTemplate, isHTML: false)
        
        vc?.present(composeVC, animated: true)
    }
}


// MARK: - Messages
extension AccountView {
    /// Delegate for view controller as `MFMessageComposeViewControllerDelegate`
    private class MessageDelegate: NSObject, MFMessageComposeViewControllerDelegate {
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            // Customize here
            controller.dismiss(animated: true)
        }

    }

    /// Present an message compose view controller modally in UIKit environment
    private func presentMessageCompose() {
        // TODO: Hook up to Apollo, update 'errorAlertMessage'
        let message = """
                      \(profileManager.profile!.name) has shared an invitation key to Lynx. Open the app and enter the key below. This invitation key will expire in 24 hours.
                      
                      Invitation Key: 123456
                      """
        
        copyMessageText = message
        guard MFMessageComposeViewController.canSendText() else {
            messagesAlertBody = "We were unable to open the Messages app. Please try again or copy the invitation key."
            showMessagesNotAvailable = true
            return
        }
        
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        let vc = window?.rootViewController

        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = messageComposeDelegate


        composeVC.body = message
        
        vc?.present(composeVC, animated: true)
    }
}

#Preview {
    AccountView()
}
