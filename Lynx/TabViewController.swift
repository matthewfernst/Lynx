//
//  TabViewController.swift
//  Lynx
//
//  Created by Matthew Ernst on 3/14/23.
//

import UIKit

class TabViewController: UITabBarController
{
    static let identifier = "TabController"
    static var profile: Profile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let theme = loadTheme() {
            if theme == "Dark" {
                overrideUserInterfaceStyle = .dark
            } else {
                overrideUserInterfaceStyle = .light
            }
            TabViewController.profile.appTheme = theme
        }
    }
    
    private func loadTheme() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultsKeys.theme)
    }
    
}
