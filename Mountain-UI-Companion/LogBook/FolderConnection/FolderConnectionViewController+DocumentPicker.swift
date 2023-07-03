//
//  ConnectionViewController+DocumentPicker.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 7/2/23.
//

import Foundation
import OSLog
import UIKit

extension FolderConnectionViewController: UIDocumentPickerDelegate {
    
    private func isSlopesFiles(_ fileURL: URL) -> Bool {
        return !fileURL.hasDirectoryPath && fileURL.path.lowercased().contains("gpslogs") && fileURL.pathExtension == "slopes"
    }
    
    private func getFileList(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]) -> [URL]? {
        var fileList: [URL] = []
        let fileManager = FileManager.default
        
        guard let directoryEnumerator = fileManager.enumerator(at: url,
                                                               includingPropertiesForKeys: keys,
                                                               options: .skipsHiddenFiles,
                                                               errorHandler: { (url, error) -> Bool in
            print("Failed to access file at URL: \(url), error: \(error)")
            return true
        }) else {
            print("Unable to access the contents of \(url.path)")
            return nil
        }
        
        for case let fileURL as URL in directoryEnumerator {
            fileList.append(fileURL)
        }
        
        return fileList
    }
    
    private func setupSlopeFilesUploadingView() {
        self.continueButton.isHidden = true
        self.thumbsUpImageView.isHidden = true
        
        self.uploadProgressView.progress = 0
        self.uploadProgressView.isHidden = false
        
        self.title = "Uploading New Slope Files"
        self.explanationTextView.text = nil
        self.stepsToUploadImageView.image = nil
    }
    
    private func updateSlopeFilesProgressView(fileBeingUploaded: String, progress: Float) {
        DispatchQueue.main.async {
            self.explanationTextView.text = "\(fileBeingUploaded)"
            self.uploadProgressView.progress = progress
        }
    }
    
    private func cleanUpSlopeFilesUploadView() {
        DispatchQueue.main.async { [unowned self] in
            self.uploadProgressView.isHidden = true
            self.manualUploadActivityIndicator.stopAnimating()
            self.uploadProgressView.isHidden = true
            self.showAllSet()
        }
    }
    
    private func showAllSet() {
        self.title = "All Set!"
        
        self.explanationTextView.text = "Your Slopes folder is connected. Your files will be automatically uploaded when you open the app."
        self.explanationTextView.font = UIFont.systemFont(ofSize: 16)
        self.continueButton.isHidden = true
        self.stepsToUploadImageView.isHidden = true
        
        self.thumbsUpImageView.isHidden = false
        
        self.thumbsUpImageView.image = UIImage(systemName: "hand.thumbsup.fill")
        self.thumbsUpImageView.alpha = 0
        self.thumbsUpImageView.transform = .identity
        
        UIImageView.animate(withDuration: 1, delay: 0, animations: {
            self.thumbsUpImageView.alpha = 1
            self.thumbsUpImageView.transform = CGAffineTransform(rotationAngle: -.pi / 4)
        }, completion: {_ in
            UIImageView.animate(withDuration: 2, delay: 0,  usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, animations: {
                self.thumbsUpImageView.transform = .identity
            }, completion: {_ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.dismiss(animated: true)
                }
            })
        })
        if let tabBarController = self.presentingViewController as? TabViewController {
            // Access the desired tab's navigation controller
            if let desiredNavigationController = tabBarController.viewControllers?[0] as? UINavigationController {
                // Access the root view controller of the navigation controller
                if let logbookViewController = desiredNavigationController.viewControllers.first as? LogbookViewController {
                    // Modify the right bar button item
                    logbookViewController.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "link.icloud")
                }
            }
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        let url = urls[0] // TODO: Make sure to select only one directory
        
        guard url.startAccessingSecurityScopedResource() else {
            // Handle the failure here.
            showFileAccessNotAllowed()
            return
        }
        
        defer { url.stopAccessingSecurityScopedResource() }
        
        
        // Slopes folder doesn't come up and instead shows the App Sandbox ID for Slopes
        if url.pathComponents.contains("GPSLogs") {
            // Get the contents of the directory
            guard let contents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) else {
                // Failed to access the directory
                return
            }
            
            if contents.allSatisfy({ $0.pathExtension == "slopes" }) {
                let keys: [URLResourceKey] = [.nameKey, .isDirectoryKey]
                
                guard let totalNumberOfFiles = FileManager.default.enumerator(at: url, includingPropertiesForKeys: keys)?.allObjects.count else {
                    Logger.slopesConnection.debug("*** Unable to access the contents of \(url.path) ***\n")
                    showFileAccessNotAllowed()
                    return
                }
                
                guard let fileList = getFileList(at: url, includingPropertiesForKeys: keys) else { return }
                
                let requestedPathsForUpload = fileList.compactMap { $0.lastPathComponent }
                
                ApolloMountainUIClient.createUserRecordUploadUrl(filesToUpload: requestedPathsForUpload) { [unowned self] result in
                    switch result {
                    case .success(let urlsForUpload):
                        guard url.startAccessingSecurityScopedResource() else {
                            // Handle the failure here.
                            showFileAccessNotAllowed()
                            return
                        }
                        
                        guard let fileList = getFileList(at: url, includingPropertiesForKeys: keys) else { return }
                        
                        setupSlopeFilesUploadingView()
                        var currentFileNumberBeingUploaded = 0
                        
                        for (fileURLEnumerator, uploadURL) in zip(fileList, urlsForUpload) {
                            if case let fileURL = fileURLEnumerator {
                                Logger.slopesConnection.debug("Uploading file: \(fileURL.lastPathComponent) to \(uploadURL)")
                                
                                FolderConnectionViewController.putZipFiles(urlEndPoint: uploadURL, zipFilePath: fileURL) { [unowned self] response in
                                    switch response {
                                    case .success(_):
                                        currentFileNumberBeingUploaded += 1
                                        self.updateSlopeFilesProgressView(fileBeingUploaded: fileURL.lastPathComponent.replacingOccurrences(of: "%", with: " "),
                                                                          progress: Float(currentFileNumberBeingUploaded) / Float(totalNumberOfFiles))
                                        
                                        if currentFileNumberBeingUploaded == totalNumberOfFiles {
                                            // All files are uploaded, perform cleanup
                                            self.cleanUpSlopeFilesUploadView()
                                        }
                                    case .failure(let error):
                                        Logger.slopesConnection.debug("Failed to upload \(fileURL) with error: \(error)")
                                        showErrorUploading()
                                    }
                                }
                            }
                        }
                        url.stopAccessingSecurityScopedResource()
                        FolderConnectionViewController.bookmarkManager.saveBookmark(for: url)
                    case .failure(_):
                        showErrorUploading()
                    }
                }
            } else {
                showFileExtensionNotSupported(extensions: contents.filter({ $0.lastPathComponent != "slopes" }).map({ $0.lastPathComponent }))
            }
        } else {
            showWrongDirectorySelected(directory: url.lastPathComponent)
        }
    }
    
    private func getNonUploadedSlopeFiles() -> [String]? {
        guard let bookmark = FolderConnectionViewController.bookmarkManager.bookmark else { return nil }
        var nonUploadedSlopeFiles: [String] = []
        
        ApolloMountainUIClient.getUploadedLogs() { [unowned self] result in
            switch result {
            case .success(let uploadedFiles):
                do {
                    let resourceValues = try bookmark.url.resourceValues(forKeys: [.isDirectoryKey])
                    if resourceValues.isDirectory ?? false {
                        let keys: [URLResourceKey] = [.nameKey, .isDirectoryKey, .creationDateKey]
                        if let fileList = getFileList(at: bookmark.url, includingPropertiesForKeys: keys) {
                            for case let fileURL in fileList {
                                if self.isSlopesFiles(fileURL) {
                                    if !uploadedFiles.contains(fileURL.lastPathComponent) {
                                        nonUploadedSlopeFiles.append(fileURL.lastPathComponent)
                                    }
                                }
                            }
                        }
                    }
                } catch {
                    // Handle the error
                    self.showErrorUploading()
                    Logger.slopesConnection.error("Error accessing bookmarked URL: \(error)")
                }
                
            case .failure(_):
                showErrorUploading()
            }
        }
        
        return nonUploadedSlopeFiles.isEmpty ? nil : nonUploadedSlopeFiles
    }
    
    // TODO: Move to progress view in top of logbook.
    private func checkForNewFilesAndUpload() {
        guard let nonUploadedSlopeFiles = getNonUploadedSlopeFiles() else {
            self.cleanUpSlopeFilesUploadView()
            return
        }
        
        guard let bookmark = FolderConnectionViewController.bookmarkManager.bookmark else {
            self.cleanUpSlopeFilesUploadView()
            return
        }
        
        DispatchQueue.main.async {
            self.setupSlopeFilesUploadingView()
        }
        
        
        var currentFileNumberBeingUploaded = 0
        ApolloMountainUIClient.createUserRecordUploadUrl(filesToUpload: nonUploadedSlopeFiles) { [unowned self] result in
            switch result {
            case .success(let urlsForUpload):
                do {
                    let resourceValues = try bookmark.url.resourceValues(forKeys: [.isDirectoryKey])
                    if resourceValues.isDirectory ?? false {
                        let keys: [URLResourceKey] = [.nameKey, .isDirectoryKey, .creationDateKey]
                        if let fileList = self.getFileList(at: bookmark.url, includingPropertiesForKeys: keys) {
                            for (fileURLEnumerator, uploadURL) in zip(fileList, urlsForUpload) {
                                if case let fileURL = fileURLEnumerator, self.isSlopesFiles(fileURL), nonUploadedSlopeFiles.contains(fileURL.lastPathComponent) {
                                    FolderConnectionViewController.putZipFiles(urlEndPoint: uploadURL, zipFilePath: fileURL) { [unowned self] result in
                                        switch result {
                                        case .success(_):
                                            currentFileNumberBeingUploaded += 1
                                            let progress = Float(currentFileNumberBeingUploaded) / Float(nonUploadedSlopeFiles.count)
                                            self.updateSlopeFilesProgressView(fileBeingUploaded: fileURL.lastPathComponent.replacingOccurrences(of: "%", with: " "), progress: progress)
                                        case .failure(let error):
                                            self.showErrorUploading()
                                            Logger.slopesConnection.debug("\(error)")
                                            self.cleanUpSlopeFilesUploadView()
                                        }
                                    }
                                }
                            }
                        }
                    }
                } catch {
                    self.showErrorUploading()
                    Logger.slopesConnection.error("Error accessing bookmarked URL: \(error)")
                    self.cleanUpSlopeFilesUploadView()
                }
                
            case .failure(_):
                self.showErrorUploading()
            }
            self.cleanUpSlopeFilesUploadView()
        }
    }
    
    
    private static func putZipFiles(urlEndPoint: String, zipFilePath: URL, completion: @escaping (Result<Int, Error>) -> Void) {
        let url = URL(string: urlEndPoint)!
        
        // Create the request object
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        // Set the content type for the request
        let contentType = "application/zip" // Replace with the appropriate content type
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // Read the ZIP file data
        guard let zipFileData = try? Data(contentsOf: zipFilePath) else {
            let error = NSError(domain: "Error reading ZIP file data", code: 0, userInfo: nil)
            completion(.failure(error))
            return
        }
        
        // Set the request body to the ZIP file data
        request.httpBody = zipFileData
        
        // Create a URLSession task for the request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Handle the response
            if let response = response as? HTTPURLResponse {
                print("Response status code: \(response.statusCode)")
                
                if response.statusCode == 200 {
                    completion(.success(response.statusCode))
                } else {
                    let error = NSError(domain: "Status code is not 200", code: response.statusCode, userInfo: nil)
                    completion(.failure(error))
                }
            }
        }
        
        // Start the task
        task.resume()
    }
    
}
