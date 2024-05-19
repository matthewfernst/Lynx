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
    
    func picker(didPickDocumentsAt url: URL, dismissForUpload: Binding<Bool>) {
        resetUploadProgressAndFilename()
        
        BookmarkManager.shared.saveBookmark(for: url)
        
        guard url.startAccessingSecurityScopedResource() else {
            Logger.folderConnectionHandler.error(
                "Unable to start accessing security scope resource at \(url.absoluteString) in picker(didPickDocumentsAt)"
            )
            showUploadError()
            return
        }
        
        defer {
            Logger.folderConnectionHandler.debug("picker(didPickDocumentsAt) defer called")
            url.stopAccessingSecurityScopedResource()
        }
        
        Logger.folderConnectionHandler.debug("Attempting to access directory: \(url.path)")
        
        var error: NSError? = nil
        NSFileCoordinator().coordinate(readingItemAt: url, error: &error) { (url) in
            if url.lastPathComponent == "GPSLogs" {
                Logger.folderConnectionHandler.debug("Successfully accessed directory: \(url.path)")
                DispatchQueue.main.async {
                    dismissForUpload.wrappedValue = true
                }
                getNonUploadedSlopeFiles(forURL: url) { urlsForUpload in
                    if let urlsForUpload = urlsForUpload, !urlsForUpload.isEmpty {
                        self.uploadNewFiles(urlsForUpload, completion: nil)
                    } else {
                        self.currentFileBeingUploaded = "No new files!"
                        self.uploadProgress = 1.0
                    }
                }
            } else {
                Logger.folderConnectionHandler.error("Selected URL is not the correct directory: \(url.path)")
                showWrongDirectorySelected(directory: url.lastPathComponent)
            }
        }
    }
    
    private func getFileList(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]) -> [URL]? {
        var fileList: [URL] = []
        let fileManager = FileManager.default
        
        guard url.startAccessingSecurityScopedResource() else {
            Logger.folderConnectionHandler.error(
                "Unable to start accessing security scope resource at \(url.absoluteString) in getFileList(at url:)"
            )
            showUploadError()
            return nil
        }
        
        
        defer {
            Logger.folderConnectionHandler.debug("getFileList(at: keys:) defer called")
            url.stopAccessingSecurityScopedResource()
        }
        
        guard let directoryEnumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: keys,
            options: .skipsHiddenFiles,
            errorHandler: { (url, error) -> Bool in
                Logger.folderConnectionHandler.debug("getFileList")
                Logger.folderConnectionHandler.error("Failed to access file at URL: \(url), error: \(error.localizedDescription)")
                self.showFileAccessError()
                return true
            }) else {
            Logger.folderConnectionHandler.error("Unable to access the contents of \(url.path)")
            showFileAccessError()
            return nil
        }
        
        for case let fileURL as URL in directoryEnumerator {
            Logger.folderConnectionHandler.debug("fileURL: \(fileURL)")
            fileList.append(fileURL)
        }
        
        return fileList
    }
    
    private func putSlopeFiles(urlEndPoint: String, slopeFileURL: URL, completion: @escaping (Result<Int, Error>) -> Void) {
        guard let url = URL(string: urlEndPoint) else {
            let error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/zip", forHTTPHeaderField: "Content-Type")
        
        do {
            let zipFileData = try Data(contentsOf: slopeFileURL)
            request.httpBody = zipFileData
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse {
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
        
        task.resume()
    }
    
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
        
        Logger.folderConnectionHandler.debug("Starting Non-Upload Files")
        ApolloLynxClient.getUploadedLogs { [unowned self] result in
            switch result {
            case .success(let uploadedFiles):
                if url.lastPathComponent == "GPSLogs" {
                    let keys: [URLResourceKey] = [.nameKey, .isDirectoryKey, .creationDateKey]
                    if let fileList = self.getFileList(at: url, includingPropertiesForKeys: keys) {
                        let nonUploadedSlopeFiles = fileList.filter {
                            self.isSlopesFiles($0) && !uploadedFiles.contains($0.lastPathComponent)
                        }
                        completion(nonUploadedSlopeFiles.isEmpty ? nil : nonUploadedSlopeFiles)
                    } else {
                        Logger.folderConnectionHandler.debug(
                            "No fileList returned in getNonUploadedSlopeFiles(forURL:, completion:)"
                        )
                        completion(nil)
                    }
                } else {
                    Logger.folderConnectionHandler.error("Error accessing bookmarked URL")
                    completion(nil)
                }
                
            case .failure(let error):
                Logger.folderConnectionHandler.error("Error in trying to find non uploaded slope files: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    func uploadNewFiles(_ nonUploadedSlopeFiles: [URL], completion: (() -> Void)?) {
        guard let gpsLogsURL = BookmarkManager.shared.bookmark?.url else {
            return
        }
        
        guard gpsLogsURL.startAccessingSecurityScopedResource() else {
            Logger.folderConnectionHandler.error("Unable to access security scope in uploadNewFiles()")
            return
        }
        
        defer {
            Logger.folderConnectionHandler.debug("uploadNewFiles defer called")
            gpsLogsURL.stopAccessingSecurityScopedResource()
        }
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: gpsLogsURL, includingPropertiesForKeys: nil)
            if contents.allSatisfy({ $0.pathExtension == "slopes" }) {
                let totalNumberOfFiles = nonUploadedSlopeFiles.count
                let requestedPathsForUpload = nonUploadedSlopeFiles.map { $0.lastPathComponent }
                Logger.folderConnectionHandler.info("Requested Paths: \(requestedPathsForUpload)")
                
                ApolloLynxClient.createUserRecordUploadUrl(filesToUpload: requestedPathsForUpload) { [unowned self] result in
                    switch result {
                    case .success(let urlsForUpload):
                        guard gpsLogsURL.startAccessingSecurityScopedResource() else {
                            Logger.folderConnectionHandler.error("File Access Error in uploadNewFiles() createUser")
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
                            
                            let fileURL = nonUploadedSlopeFiles[currentFileNumberBeingUploaded]
                            Logger.folderConnectionHandler.info("Uploading newly found file: \(fileURL.lastPathComponent)")
                            
                            self.putSlopeFiles(urlEndPoint: urlsForUpload[currentFileNumberBeingUploaded], slopeFileURL: fileURL) { result in
                                switch result {
                                case .success(_):
                                    currentFileNumberBeingUploaded += 1
                                    
                                    DispatchQueue.main.async {
                                        withAnimation {
                                            self.uploadProgress = Double(currentFileNumberBeingUploaded) / Double(totalNumberOfFiles)
                                            let fileURLString = fileURL.lastPathComponent.replacingOccurrences(of: "%", with: " ")
                                            if let startRange = fileURLString.range(of: "-"), let endRange = fileURLString.range(of: ".slopes") {
                                                self.currentFileBeingUploaded = String(fileURLString[startRange.upperBound..<endRange.lowerBound].trimmingCharacters(in: .whitespaces))
                                                Logger.folderConnectionHandler.debug("Current file being uploaded: \(self.currentFileBeingUploaded)")
                                            }
                                        }
                                        if currentFileNumberBeingUploaded == totalNumberOfFiles {
                                            gpsLogsURL.stopAccessingSecurityScopedResource()
                                        }
                                    }
                                    
                                case .failure(let error):
                                    Logger.folderConnectionHandler.error("Failed to upload \(fileURL.lastPathComponent): \(error.localizedDescription)")
                                }
                            }
                        }
                        
                    case .failure(_):
                        self.showUploadError()
                    }
                }
            }
        } catch {
            Logger.folderConnectionHandler.error("File Access Error in uploadNewFiles(), Error: \(error.localizedDescription)")
            showFileAccessError()
            return
        }
        
    }
}
