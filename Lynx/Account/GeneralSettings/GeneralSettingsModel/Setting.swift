//
//  Setting.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/22/23.
//

import Foundation
import UIKit

struct Setting
{
    var id = UUID()
    let name: String
    let iconImage: UIImage!
    let backgroundColor: UIColor
}


extension Setting
{
    static let settingOptions: [Setting] = [
        .init(name: "General", iconImage: UIImage(systemName: "gear"), backgroundColor: .lightGray),
        .init(name: "Notifications", iconImage: UIImage(systemName: "bell.badge.fill"), backgroundColor: .red),
    ]
    static let inviteKeySetting: Setting = .init(name: "Share Invite Key", iconImage: .init(systemName: "person.badge.key.fill"), backgroundColor: .inviteKeyGreen)
    static let contactDevelopers: Setting = .init(name: "Contact Developers", iconImage: UIImage(systemName: "paperplane.fill"), backgroundColor: .systemIndigo)
}
