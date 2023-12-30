//
//  FolderConnectionHandler.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/10/23.
//

import SwiftUI
import OSLog

@Observable final class FolderConnectionHandler: ObservableObject {
    var errorAlert: Alert? = nil {
        didSet {
            showError = true
        }
    }
    var showError = false
    var uploadProgress = 0.0
    var currentFileBeingUploaded = ""
    private var freezingPeriodActive = false
    private var uploadTimer: Timer?
    
    func picker(didPickDocumentsAt url: URL) {
        resetUploadProgressAndFilename()
        guard url.startAccessingSecurityScopedResource() else {
            // Handle the failure here.
            showUploadError()
            return
        }
        
        defer { url.stopAccessingSecurityScopedResource() }
        
        let gpsLogsURL = url.appendingPathComponent("GPSLogs")
        BookmarkManager.shared.saveBookmark(for: gpsLogsURL)
        
        if FileManager.default.fileExists(atPath: gpsLogsURL.path) {
            getNonUploadedSlopeFiles(forURL: gpsLogsURL) { urlsForUpload in
                if let urlsForUpload {
                    self.uploadNewFiles(urlsForUpload, completion: nil)
                } else { // no new files
                    self.currentFileBeingUploaded = "No new files!"
                    self.uploadProgress = 1.0
                }
            }
        } else {
            showWrongDirectorySelected(directory: url.lastPathComponent)
        }
    }
    
    // MARK: - Document Picker Helper Functions
    
    private func getFileList(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]) -> [URL]? {
        var fileList: [URL] = []
        let fileManager = FileManager.default
        
        guard let directoryEnumerator = fileManager.enumerator(at: url,
                                                               includingPropertiesForKeys: keys,
                                                               options: .skipsHiddenFiles,
                                                               errorHandler: { (url, error) -> Bool in
            Logger.folderConnectionHandler.error("Failed to access file at URL: \(url), error: \(error)")
            self.showFileAccessError()
            return true
        }) else {
            Logger.folderConnectionHandler.error("Unable to access the contents of \(url.path)")
            showFileAccessError()
            return nil
        }
        
        for case let fileURL as URL in directoryEnumerator {
            fileList.append(fileURL)
        }
        
        return fileList
    }
    
    private func putSlopeFiles(urlEndPoint: String, slopeFileURL: URL, completion: @escaping (Result<Int, Error>) -> Void) {
        let url = URL(string: urlEndPoint)!
        
        // Create the request object
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        // Set the content type for the request
        let contentType = "application/zip" // Replace with the appropriate content type
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // Read the ZIP file data
        guard let zipFileData = try? Data(contentsOf: slopeFileURL) else {
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
                    DispatchQueue.main.async {
                        completion(.success(response.statusCode))
                    }
                } else {
                    let error = NSError(domain: "Status code is not 200", code: response.statusCode, userInfo: nil)
                    completion(.failure(error))
                }
            }
        }
        
        // Start the task
        task.resume()
    }
    
    // MARK: - Post Bookmark Saved Helpers
    private func isSlopesFiles(_ fileURL: URL) -> Bool {
        return !fileURL.hasDirectoryPath && fileURL.path.lowercased().contains("gpslogs") && fileURL.pathExtension == "slopes"
    }
    
    func resetUploadProgressAndFilename() {
        uploadProgress = 0.0
        currentFileBeingUploaded = ""
    }
    
    func getNonUploadedSlopeFiles(forURL url: URL, completion: @escaping ([URL]?) -> Void) {
        guard !freezingPeriodActive else {
            Logger.folderConnectionView.info("Freezing period is active. Not uploading.")
            completion(nil)
            return
        }
        
        var nonUploadedSlopeFiles: [URL] = []
        ApolloLynxClient.getUploadedLogs { [unowned self] result in
            switch result {
            case .success(let uploadedFiles):
                do {
                    let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey])
                    if resourceValues.isDirectory ?? false {
                        let keys: [URLResourceKey] = [.nameKey, .isDirectoryKey, .creationDateKey]
                        if let fileList = self.getFileList(at: url, includingPropertiesForKeys: keys) {
                            for case let fileURL in fileList {
                                Logger.folderConnectionHandler.debug("Checking \(fileURL.lastPathComponent) for upload.")
                                if self.isSlopesFiles(fileURL) {
                                    if !uploadedFiles.contains(fileURL.lastPathComponent) {
                                        nonUploadedSlopeFiles.append(fileURL)
                                    }
                                }
                            }
                        }
                    }
                } catch {
                    // Handle the error
                    Logger.folderConnectionHandler.error("Error accessing bookmarked URL: \(error)")
                    completion(nil)
                    return
                }
                
                if nonUploadedSlopeFiles.isEmpty {
                    Logger.folderConnectionHandler.debug("No new files found.")
                    completion(nil)
                } else {
                    Logger.folderConnectionHandler.debug("New files to upload found.")
                    completion(nonUploadedSlopeFiles)
                }
                
            case .failure(let error):
                Logger.folderConnectionHandler.error("Error in trying to find non uploaded slope files: \(error)")
                completion(nil)
            }
        }
    }
    
    func uploadNewFiles(_ nonUploadedSlopeFiles: [URL], completion: (() -> Void)?) {
        guard let gpsLogsURL = BookmarkManager.shared.bookmark?.url else {
            return
        }
        
        guard let contents = try? FileManager.default.contentsOfDirectory(at: gpsLogsURL, includingPropertiesForKeys: nil) else {
            // Failed to access the directory
            showFileAccessError()
            return
        }
        
        
        if contents.allSatisfy({ $0.pathExtension == "slopes" }) {
            let totalNumberOfFiles = nonUploadedSlopeFiles.count
            
            let requestedPathsForUpload = nonUploadedSlopeFiles.map { $0.lastPathComponent }
            Logger.folderConnectionHandler.info("Requested Paths: \(requestedPathsForUpload)")
            
            ApolloLynxClient.createUserRecordUploadUrl(filesToUpload: requestedPathsForUpload ) { [unowned self] result in
                switch result {
                case .success(let urlsForUpload):
                    guard gpsLogsURL.startAccessingSecurityScopedResource() else {
                        self.showFileAccessError()
                        return
                    }
                    
                    var currentFileNumberBeingUploaded = 0
                    self.freezingPeriodActive = true
                    self.uploadTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { timer in
                        guard currentFileNumberBeingUploaded < totalNumberOfFiles else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                                self.freezingPeriodActive = false
                            }
                            timer.invalidate()
                            completion?()
                            return
                        }
                        
                        
                        if case let fileURL = nonUploadedSlopeFiles[currentFileNumberBeingUploaded] {
                            Logger.folderConnectionHandler.info("Uploading newly found file: \(fileURL.lastPathComponent)")
                            
                            self.putSlopeFiles(urlEndPoint: urlsForUpload[currentFileNumberBeingUploaded], slopeFileURL: fileURL) { result in
                                switch result {
                                case .success(_):
                                    currentFileNumberBeingUploaded += 1
                                    
                                    withAnimation {
                                        self.uploadProgress = Double(currentFileNumberBeingUploaded) / Double(totalNumberOfFiles)
                                        
                                        let fileURLString = fileURL.lastPathComponent.replacingOccurrences(of: "%", with: " ")
                                        if let startRange = fileURLString.range(of: "-"), let endRange = fileURLString.range(of: ".slopes") {
                                            self.currentFileBeingUploaded = fileURLString[startRange.upperBound..<endRange.lowerBound].trimmingCharacters(in: .whitespaces)
                                            Logger.folderConnectionHandler.debug("Current file being uploaded: \(self.currentFileBeingUploaded)")
                                        }
                                    }
                                    if currentFileNumberBeingUploaded == totalNumberOfFiles {
                                        gpsLogsURL.stopAccessingSecurityScopedResource()
                                    }
                                    
                                case .failure(let error):
                                    Logger.folderConnectionHandler.error("Failed to upload \(fileURL.lastPathComponent): \(error)")
                                }
                            }
                        }
                        
                    }
                    
                case .failure(let error):
                    self.showUploadError()
                    Logger.folderConnectionHandler.error("Upload new files error: \(error)")
                }
            }
            
        }
        
    }

    
    
}

