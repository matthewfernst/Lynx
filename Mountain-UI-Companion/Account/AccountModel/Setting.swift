//
//  Setting.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/22/23.
//

import Foundation
import UIKit

struct Setting {
    var id = UUID()
    let name: String
    let iconImage: UIImage!
    let backgroundColor: UIColor
}


let settingOptions: [Setting] = [
    .init(name: "General", iconImage: UIImage(systemName: "gear"), backgroundColor: .lightGray),
    .init(name: "Notifications", iconImage: UIImage(systemName: "bell.badge.fill"), backgroundColor: .red),
]
