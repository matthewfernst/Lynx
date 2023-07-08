//
//  ConnectionViewController+Errors.swift
//  Lynx
//
//  Created by Matthew Ernst on 7/2/23.
//

import Foundation
import OSLog
import UIKit

extension FolderConnectionViewController {
    public func showErrorUploading() {
        let ac = UIAlertController(title: "Upload Error",
                                   message: "Failed to upload slope files. Please try again.",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Try Again", style: .default) { [unowned self] _ in self.selectSlopeFiles() })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    public func showFileAccessNotAllowed() {
        let ac = UIAlertController(title: "File Permission Error",
                                   message: "This app does not have permission to your files on your iPhone. Please allow this app to access your files by going to Settings.",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Go to Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    Logger.folderConnection.debug("Settings opened.")
                })
            }
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    public func showFileExtensionNotSupported(extensions: [String]) {
        let ac = UIAlertController(title: "File Extension Not Supported",
                                   message: "Only '.slope' file extensions are supported, but recieved \(extensions.joined(separator: ",")) extension. Please try again.",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        
        present(ac, animated: true)
    }
    
    public func showWrongDirectorySelected(directory: String) {
        let ac = UIAlertController(title: "Wrong Directory Selected",
                                   message: "The correct directory for uploading 'Slopes', but recieved '\(directory)'. Please try again.",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(ac, animated: true)
    }
}
