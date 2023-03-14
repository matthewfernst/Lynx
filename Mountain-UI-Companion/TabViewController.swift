//
//  TabViewController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 3/14/23.
//

import UIKit

class TabViewController: UITabBarController {
    var profileModel: Profile?
    
    var slopesConnectionViewController: SlopesConnectionViewController!
    var logbookViewController: LogBookViewController!
    var accountViewController: AccountViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.viewControllers![0].presentingViewController)
        slopesConnectionViewController = self.viewControllers![0].presentingViewController as? SlopesConnectionViewController
        logbookViewController = self.viewControllers![1] as? LogBookViewController
        accountViewController = self.viewControllers![2] as? AccountViewController
        
        slopesConnectionViewController?.profileModel = profileModel
        logbookViewController?.profileModel = profileModel
        accountViewController?.profileModel = profileModel
    }
}
