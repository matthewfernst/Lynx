//
//  SlopesHookupViewController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/23/23.
//
import ClientRuntime
import UIKit
import OSLog
import UniformTypeIdentifiers

class SlopesConnectionViewController: UIViewController, UIDocumentPickerDelegate
{
    @IBOutlet var explanationTitleLabel: UILabel!
    @IBOutlet var explanationTextView: UITextView!
    @IBOutlet var slopesFolderImageView: UIImageView!
    @IBOutlet var connectSlopesButton: UIButton!
    @IBOutlet var slopeFilesUploadProgressView: UIProgressView!
    
    private var documentPicker: UIDocumentPickerViewController!
    private let bookmarkManager = BookmarkManager()
    
    lazy private var manualUploadSlopeFilesButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Upload Slope Files"
        configuration.cornerStyle = .medium
        configuration.buttonSize = .large
        
        let button = UIButton(configuration: configuration)
        button.addSubview(manualUploadActivityIndicator)
        
        manualUploadActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.manualUploadActivityIndicator.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            self.manualUploadActivityIndicator.centerYAnchor.constraint(equalTo: button.centerYAnchor),
        ])
        
        return button
    }()
    
    private let manualUploadActivityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .white
        return activityIndicator
    }()
    
    private let thumbsUpImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "hand.thumbsup.fill")
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    private var timer: Timer!
    
    var profile: Profile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBarController = self.tabBarController as! TabViewController
        self.profile = tabBarController.profile
        
        setupInitialView()
        
        if !NetworkManager().isInternetAvailable() {
            showNoInternetConnectionView()
        } else {
            self.connectSlopesButton.isHidden = false
            
            bookmarkManager.loadAllBookmarks()
            
            if bookmarkManager.bookmarks == nil {
                showConnectToSlopesView()
            }
            else {
                Task {
                    await self.checkForNewFilesAndUpload()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let _ = bookmarkManager.bookmarks else { return }
        showAllSet()
    }
    
    private func setupInitialView() {
        self.explanationTitleLabel.text = "Connect to Slopes"
        self.explanationTextView.text = """
The Mountain-UI Companion App works together with the Slopes App by Breakpoint Studios. Slopes is able to track a skier or snowboarder while they shred it down the mountain. Slopes can track things such as average speed, total vertical feet, and more. The Mountain-UI Companion App, uses the data stored by Slopes and sends it to your Mountain-UI display. In order to get started, tap the "Connect Slopes" button and select the Slopes folder in your Files directory. The Slopes directory is shown below for reference.
"""
        self.connectSlopesButton.setTitle("Connect Slopes", for: .normal)
        self.connectSlopesButton.isHidden = false
        self.slopesFolderImageView.isHidden = true
        
        self.connectSlopesButton.addTarget(self, action: #selector(selectSlopesFiles), for: .touchUpInside)
        
        anchorSlopeFilesUploadProgressView()
        setupThumbsUpImageViewAndManualSlopeFilesButton()
    }
    
    // MARK: - Progress View Functions
    private func anchorSlopeFilesUploadProgressView() {
        self.slopeFilesUploadProgressView.isHidden = true
        
        self.slopeFilesUploadProgressView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.slopeFilesUploadProgressView.centerXAnchor.constraint(equalTo: self.slopesFolderImageView.centerXAnchor),
            self.slopeFilesUploadProgressView.centerYAnchor.constraint(equalTo: self.slopesFolderImageView.centerYAnchor),
            self.slopeFilesUploadProgressView.widthAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    private func showNoInternetConnectionView() {
        self.explanationTitleLabel.text = "You Are Not Connected to the Internet"
        self.explanationTextView.text = "This app cannot be used currently because your device is currently offline."
        
        self.connectSlopesButton.isHidden = true
        self.slopesFolderImageView.isHidden = true
        
        let arrayOfTabBarItems = self.tabBarController?.tabBar.items
        
        if let barItems = arrayOfTabBarItems, barItems.count > 0 {
            barItems[0].isEnabled = false
            barItems[1].isEnabled = false
            barItems[2].isEnabled = false
        }
    }
    
    private func setupSlopeFilesUploadingView() {
        self.thumbsUpImageView.isHidden = true
        
        self.slopeFilesUploadProgressView.progress = 0
        self.slopeFilesUploadProgressView.isHidden = false
        
        self.explanationTitleLabel.text = "Uploading New Slope Files"
        self.explanationTextView.text = nil
        self.slopesFolderImageView.image = nil
    }
    
    private func cleanUpSlopeFilesUploadView() {
        DispatchQueue.main.async { [unowned self] in
            self.slopeFilesUploadProgressView.isHidden = true
            self.manualUploadSlopeFilesButton.titleLabel?.isHidden = false
            self.manualUploadActivityIndicator.stopAnimating()
            self.slopeFilesUploadProgressView.isHidden = true
            self.showAllSet()
        }
    }
    
    private func updateSlopeFilesProgressView(fileBeingUploaded: String, progress: Float) {
        DispatchQueue.main.async {
            self.explanationTextView.text = "\(fileBeingUploaded)"
            self.slopeFilesUploadProgressView.progress = progress
        }
    }
    
    private func setupThumbsUpImageViewAndManualSlopeFilesButton() {
        let manualUploadSlopeFilesButton = manualUploadSlopeFilesButton
        let thumbsUpImageView = thumbsUpImageView
        
        self.view.addSubview(manualUploadSlopeFilesButton)
        self.view.addSubview(thumbsUpImageView)
        
        self.manualUploadSlopeFilesButton.isHidden = true
        self.manualUploadSlopeFilesButton.addTarget(self, action: #selector(checkForNewFilesAndUploadWrapper), for: .touchUpInside)
        
        
        self.thumbsUpImageView.isHidden = true
        
        self.manualUploadSlopeFilesButton.translatesAutoresizingMaskIntoConstraints = false
        self.thumbsUpImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.manualUploadSlopeFilesButton.centerXAnchor.constraint(equalTo: self.connectSlopesButton.centerXAnchor),
            self.manualUploadSlopeFilesButton.centerYAnchor.constraint(equalTo: self.connectSlopesButton.centerYAnchor),
            self.manualUploadSlopeFilesButton.widthAnchor.constraint(equalToConstant: 200),
            self.manualUploadSlopeFilesButton.heightAnchor.constraint(equalToConstant: 35),
            
            self.thumbsUpImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.thumbsUpImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.thumbsUpImageView.widthAnchor.constraint(equalToConstant: 150),
            self.thumbsUpImageView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func showConnectToSlopesView() {
        self.manualUploadSlopeFilesButton.isHidden = true
        self.thumbsUpImageView.isHidden = true
        
        self.slopesFolderImageView.isHidden = false
        
        documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder], asCopy: false)
        documentPicker.delegate = self
        documentPicker.shouldShowFileExtensions = true
        documentPicker.allowsMultipleSelection = true
        
        connectSlopesButton.addTarget(self, action: #selector(selectSlopesFiles), for: .touchUpInside)
    }
    
    @objc private func selectSlopesFiles() {
        present(documentPicker, animated: true)
    }
    
    private func showAllSet() {
        self.explanationTitleLabel.text = "You're All Set!"
        self.explanationTitleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        self.explanationTextView.text = "Your Slopes data folder is connected. Your files will be automatically uploaded when you open the app. If you would like to manually upload new files, tap the Upload Slope Files button below."
        self.explanationTextView.font = UIFont.systemFont(ofSize: 16)
        self.connectSlopesButton.isHidden = true
        self.slopesFolderImageView.isHidden = true
        
        self.manualUploadSlopeFilesButton.isHidden = false
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
            })
        })
    }
    
    
    // MARK: - Error Alert Functions
    private func showErrorUploading() {
        let ac = UIAlertController(title: "Upload Error",
                                   message: "Failed to upload slope files. Please try again.",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Try Again", style: .default) { [unowned self] _ in self.selectSlopesFiles() })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    private func showFileAccessNotAllowed() {
        let ac = UIAlertController(title: "File Permission Error",
                                   message: "This app does not have permission to your files on your iPhone. Please allow this app to access your files by going to Settings.",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Go to Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    Logger.slopesConnection.debug("Settings opened.")
                })
            }
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    private func showFileExtensionNotSupported(extensions: [String]) {
        let ac = UIAlertController(title: "File Extension Not Supported",
                                   message: "Only '.slope' file extensions are supported, but recieved \(extensions.joined(separator: ",")) extension. Please try again.",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        
        present(ac, animated: true)
    }
    
    private func showWrongDirectorySelected(directory: String) {
        let ac = UIAlertController(title: "Wrong Directory Selected",
                                   message: "The correct directory for uploading Slope files is '/Slopes/GPSLogs', but recieved '\(directory)'. Please try again.",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(ac, animated: true)
    }
    
    // MARK: - Document Picker
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
                                
                                SlopesConnectionViewController.putZipFiles(urlEndPoint: uploadURL, zipFilePath: fileURL) { [unowned self] response in
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
                        bookmarkManager.saveBookmark(for: url)
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
        guard let bookmark = bookmarkManager.bookmarks else { return nil }
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
    
    @objc private func checkForNewFilesAndUploadWrapper() {
        self.checkForNewFilesAndUpload()
    }
    
    private func checkForNewFilesAndUpload() {
        self.manualUploadSlopeFilesButton.titleLabel?.isHidden = true
        self.manualUploadActivityIndicator.startAnimating()
        
        guard let nonUploadedSlopeFiles = getNonUploadedSlopeFiles() else {
            self.cleanUpSlopeFilesUploadView()
            return
        }
        
        guard let bookmark = bookmarkManager.bookmarks else {
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
                                    SlopesConnectionViewController.putZipFiles(urlEndPoint: uploadURL, zipFilePath: fileURL) { [unowned self] result in
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
