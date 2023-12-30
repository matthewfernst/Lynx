//
//  FolderConnectionHandler+ErrorAlerts.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/10/23.
//

import SwiftUI
import OSLog

extension FolderConnectionHandler {
    func showUploadError() {
        errorAlert = Alert(
            title: Text("Upload Error"),
            message: Text("Failed to upload slope files. Please try agian.")
        )
    }
    
    func showFileAccessError() {
        errorAlert = Alert(title: Text("File Permission Error"),
                           message: Text("This app does not have permission to your files on your iPhone. Please allow this app to access your files by going to Settings."),
                           primaryButton: .default(Text("Go to Settings")) {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    Logger.folderConnectionHandler.debug("Settings opened.")
                })
            }
        }, secondaryButton: .cancel())
    }
    
    func showFileExtensionNotSupported(extensions: [String]) {
        errorAlert = Alert(
            title: Text("File Extension Not Supported"),
            message: Text("Only '.slope' file extensions are supported, but recieved \(extensions.joined(separator: ", ")) extensions. Please try again.")
        )
    }
    
    func showWrongDirectorySelected(directory: String) {
        errorAlert = Alert(
            title: Text("Wrong Directory Selected"),
            message: Text("The correct directory for uploading 'Slopes', but recieved '\(directory)'. Please try again.")
        )
    }
}
